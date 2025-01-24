defmodule Passbook do
  @moduledoc """
  Documentation for `Passbook`.
  """

  @doc """
  Generates a signed .pkpass file from a Pass struct and required files.

  ## Parameters

    * `pass` - A Pass struct containing the pass data
    * `files` - A keyword list of required image files (e.g. `[{"icon.png", "path/to/icon.png"}]`)
    * `credentials` - A SigningCredentials struct containing signing certificates and keys
    * `opts` - Optional keyword list of settings

  ## Options

    * `:target_path` - Directory where the .pkpass file will be generated (defaults to system temp dir)
    * `:pass_name` - Name of the generated .pkpass file (defaults to random string)
    * `:delete_raw_pass` - Whether to delete intermediate files after generation (defaults to `true`)

  ## Returns

    * `{:ok, path}` - Path to the generated .pkpass file
    * `{:error, reason}` - If generation fails

  ## Examples

      # Comprehensive example with all fields
      iex> pass = %Passbook.Pass{
      ...>   background_color: "rgb(23, 187, 82)",
      ...>   foreground_color: "rgb(100, 10, 110)",
      ...>   barcode: %Passbook.LowerLevel.Barcode{
      ...>     format: :qr,
      ...>     alt_text: "1234",
      ...>     message: "qr-code-content"
      ...>   },
      ...>   description: "This is a pass description",
      ...>   organization_name: "My Organization",
      ...>   pass_type_identifier: "123",
      ...>   serial_number: "serial-number-123",
      ...>   team_identifier: "team-identifier",
      ...>   generic: %Passbook.PassStructure{
      ...>     transit_type: :train,
      ...>     primary_fields: [
      ...>       %Passbook.LowerLevel.Field{
      ...>         key: "my-key",
      ...>         value: "my-value"
      ...>       }
      ...>     ]
      ...>   }
      ...> }
      iex> files = [{"icon.png", "test/fixtures/icon.png"}, {"icon@2x.png", "test/fixtures/icon.png"}]
      iex> credentials = Passbook.SigningCredentials.new(
      ...>   {:file, "test/fixtures/wwdr.pem"},
      ...>   {:file, "test/fixtures/cert.pem"},
      ...>   {:file, "test/fixtures/key.pem"},
      ...>   "password"
      ...> )
      iex> {:ok, pkpass} = Passbook.generate(pass, files, credentials,
      ...>   target_path: "./test/tmp",
      ...>   pass_name: "mypass"
      ...> )
      iex> String.ends_with?(pkpass, "mypass.pkpass")
      true

      # Basic successful case
      iex> pass = %Passbook.Pass{
      ...>   description: "Test Pass",
      ...>   organization_name: "Test Org",
      ...>   pass_type_identifier: "pass.test",
      ...>   serial_number: "123",
      ...>   team_identifier: "ABC123"
      ...> }
      iex> files = [{"icon.png", "test/fixtures/icon.png"}]
      iex> credentials = Passbook.SigningCredentials.new(
      ...>   {:file, "test/fixtures/wwdr.pem"},
      ...>   {:file, "test/fixtures/cert.pem"},
      ...>   {:file, "test/fixtures/key.pem"},
      ...>   "password"
      ...> )
      iex> {:ok, pkpass} = Passbook.generate(pass, files, credentials)
      iex> String.ends_with?(pkpass, ".pkpass")
      true

      # With custom options
      iex> pass = %Passbook.Pass{
      ...>   description: "Test Pass",
      ...>   organization_name: "Test Org",
      ...>   pass_type_identifier: "pass.test",
      ...>   serial_number: "123",
      ...>   team_identifier: "ABC123"
      ...> }
      iex> files = [{"icon.png", "test/fixtures/icon.png"}]
      iex> credentials = Passbook.SigningCredentials.new(
      ...>   {:file, "test/fixtures/wwdr.pem"},
      ...>   {:file, "test/fixtures/cert.pem"},
      ...>   {:file, "test/fixtures/key.pem"},
      ...>   "password"
      ...> )
      iex> {:ok, pkpass} = Passbook.generate(pass, files, credentials,
      ...>   target_path: "./test/tmp",
      ...>   pass_name: "custom_pass",
      ...>   delete_raw_pass: false
      ...> )
      iex> String.ends_with?(pkpass, "custom_pass.pkpass")
      true
      iex> dir = Path.dirname(pkpass)
      iex> signature_path = Path.join(dir, "signature")
      iex> signature_size = File.stat!(signature_path).size
      iex> File.rm_rf!(dir)
      iex> signature_size > 0
      true

      # Error case - invalid credentials
      iex> pass = %Passbook.Pass{
      ...>   description: "Test Pass",
      ...>   organization_name: "Test Org",
      ...>   pass_type_identifier: "pass.test",
      ...>   serial_number: "123",
      ...>   team_identifier: "ABC123"
      ...> }
      iex> files = [{"icon.png", "test/fixtures/icon.png"}]
      iex> credentials = Passbook.SigningCredentials.new(
      ...>   "invalid",
      ...>   {:file, "test/fixtures/cert.pem"},
      ...>   {:file, "test/fixtures/key.pem"}
      ...> )
      iex> Passbook.generate(pass, files, credentials)
      {:error, {:invalid_source, "invalid"}}

      # Error case - missing required file
      iex> pass = %Passbook.Pass{
      ...>   description: "Test Pass",
      ...>   organization_name: "Test Org",
      ...>   pass_type_identifier: "pass.test",
      ...>   serial_number: "123",
      ...>   team_identifier: "ABC123"
      ...> }
      iex> files = [{"icon.png", "test/fixtures/missing.png"}]
      iex> credentials = Passbook.SigningCredentials.new(
      ...>   {:file, "test/fixtures/wwdr.pem"},
      ...>   {:file, "test/fixtures/cert.pem"},
      ...>   {:file, "test/fixtures/key.pem"},
      ...>   "password"
      ...> )
      iex> {:error, %File.Error{
      ...>   reason: :enoent,
      ...>   path: "test/fixtures/missing.png",
      ...>   action: "read file"
      ...> }} = Passbook.generate(pass, files, credentials)
  """
  @spec generate(
          Passbook.Pass.t(),
          list({String.t(), String.t()}),
          Passbook.SigningCredentials.t(),
          keyword()
        ) :: {:ok, binary()} | {:error, term()}
  def generate(
        %Passbook.Pass{} = pass,
        files,
        %Passbook.SigningCredentials{} = credentials,
        opts \\ []
      ) do
    case Passbook.SigningCredentials.prepare(credentials) do
      {:ok, prepared_credentials} ->
        try do
          case do_generate(pass, files, prepared_credentials, opts) do
            {:ok, pkpass} ->
              Passbook.SigningCredentials.cleanup(prepared_credentials)
              {:ok, pkpass}

            error ->
              Passbook.SigningCredentials.cleanup(prepared_credentials)
              error
          end
        rescue
          e ->
            Passbook.SigningCredentials.cleanup(prepared_credentials)
            {:error, e}
        end

      error ->
        error
    end
  end

  defp do_generate(pass, files, credentials, opts) do
    # Options setup
    default = [
      target_path: get_tmp_dir(),
      pass_name: :crypto.strong_rand_bytes(16) |> Base.encode16(),
      delete_raw_pass: true
    ]

    opts = Keyword.merge(default, opts)

    # Make sure target path is created and available
    random = :crypto.strong_rand_bytes(16) |> Base.encode16()
    target_path = Path.join([opts[:target_path], random]) <> "/"
    File.mkdir_p(Path.dirname(target_path))

    with :ok <- generate_pass_json(pass, target_path),
         :ok <- generate_manifest_json(files, target_path),
         {:ok, wwdr_path} <- Passbook.SigningCredentials.get_path(credentials.wwdr),
         {:ok, cert_path} <- Passbook.SigningCredentials.get_path(credentials.certificate),
         {:ok, key_path} <- Passbook.SigningCredentials.get_path(credentials.private_key),
         :ok <-
           create_signature(
             Path.join(target_path, "manifest.json"),
             Path.join(target_path, "signature"),
             cert_path,
             key_path,
             wwdr_path,
             credentials.key_password
           ),
         :ok <- copy_pass_files(files, target_path),
         {:ok, pkpass} <- create_pkpass(target_path, opts) do
      if opts[:delete_raw_pass] do
        cleanup_raw_files(target_path)
      end

      {:ok, pkpass}
    end
  end

  defp generate_pass_json(pass, target_path) do
    pass_json = Passbook.Pass.generate_json(pass)
    File.write(target_path <> "pass.json", pass_json)
  end

  defp generate_manifest_json(files, target_path) do
    manifest_json = create_manifest(["pass.json": target_path <> "pass.json"] ++ files)
    File.write(target_path <> "manifest.json", manifest_json)
  end

  defp create_manifest(files) do
    for(
      {filename, path} <- files,
      into: %{},
      do: {filename, hash(File.read!(path))}
    )
    |> Jason.encode!()
  end

  defp hash(file_content), do: :crypto.hash(:sha, file_content) |> Base.encode16(case: :lower)

  defp create_signature(
         manifest_path,
         signature_path,
         certificate_path,
         key_path,
         wwdr_certificate_path,
         password
       ) do
    result =
      case :os.type() do
        {:win32, _} ->
          openssl = "C:/Program Files/Git/usr/bin/openssl.exe"

          args = [
            "smime",
            "-sign",
            "-signer",
            certificate_path,
            "-inkey",
            key_path,
            "-certfile",
            wwdr_certificate_path,
            "-in",
            manifest_path,
            "-out",
            signature_path,
            "-outform",
            "der",
            "-binary",
            "-passin",
            "pass:#{password}"
          ]

          case System.cmd(openssl, args, stderr_to_stdout: true) do
            {_, 0} -> :ok
            {output, _} -> {:error, output}
          end

        _ ->
          command =
            [
              "openssl smime",
              "-sign",
              "-signer #{certificate_path}",
              "-inkey #{key_path}",
              "-certfile #{wwdr_certificate_path}",
              "-in #{manifest_path}",
              "-out #{signature_path}",
              "-outform der",
              "-binary",
              "-passin pass:#{password}"
            ]
            |> Enum.join(" ")

          case :os.cmd(String.to_charlist(command)) do
            [] -> :ok
            error -> {:error, List.to_string(error)}
          end
      end

    with :ok <- result,
         {:ok, %File.Stat{size: size}} when size > 0 <- File.stat(signature_path) do
      :ok
    else
      {:ok, %File.Stat{size: 0}} -> {:error, "Signature file is empty"}
      {:error, reason} -> {:error, reason}
    end
  end

  defp copy_pass_files(files, target_path) do
    Enum.each(files, fn {filename, path} ->
      File.copy(path, target_path <> filename)
    end)

    :ok
  rescue
    e -> {:error, e}
  end

  defp create_pkpass(target_path, opts) do
    pkpass_path = Path.join(target_path, "#{opts[:pass_name]}.pkpass")
    files = File.ls!(target_path) |> Enum.map(&String.to_charlist/1)

    # Erlang's :zip module expects paths as charlists
    case :zip.create(to_charlist(pkpass_path), files, cwd: to_charlist(target_path)) do
      {:ok, _} -> {:ok, pkpass_path}
      error -> error
    end
  rescue
    e -> {:error, e}
  end

  defp cleanup_raw_files(target_path) do
    File.ls!(target_path)
    |> Enum.each(&File.rm(target_path <> &1))
  rescue
    _ -> :ok
  end

  defp get_tmp_dir() do
    tmp_dir = System.tmp_dir!()

    cond do
      String.slice(tmp_dir, -1..-1) == "/" -> tmp_dir
      true -> tmp_dir <> "/"
    end
  end
end
