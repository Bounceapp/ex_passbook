defmodule Passbook do
  @moduledoc """
  Documentation for `Passbook`.
  """

  @doc """
  Generates a signed .pkpass file.

  Options:
  - `target_path`: Where to generate the .pkpass file. Defaults to tmp folder.
  - `pass_name`: The name of the .pkpass file. Defaults to a random 8 char string.
  - `delete_raw_pass` - If the raw pass files should be deleted, leaving only the .pkpass file. Defaults to `true`.

  ## Examples

      iex> Passbook.generate(%Passbook.Pass{
        background_color: "rgb(23, 187, 82)",
        foreground_color: "rgb(100, 10, 110)",
        barcode: %Passbook.LowerLevel.Barcode{
          format: :qr,
          alt_text: "1234",
          message: "qr-code-content"
        },
        description: "This is a pass description",
        organization_name: "My Organization",
        pass_type_identifier: "123",
        serial_number: "serial-number-123",
        team_identifier: "team-identifier",
        generic: %Passbook.PassStructure{
          transit_type: :train,
          primary_fields: [
            %Passbook.LowerLevel.Field{
              key: "my-key",
              value: "my-value"
            }
          ]
        }}, ["icon.png": "path/to/file.png", "icon@2x.png": "path/to/file.png"], "path/to/certificate.pem", "path/to/key.pem", "password", target_path: System.tmp_dir!(), pass_name: "mypass")
      {:ok, "path/to/generated/mypass.pkpass"}

  """
  def generate(%Passbook.Pass{} = pass, files, certificate_path, key_path, password, opts \\ []) do
    # Options setup
    default = [
      target_path: System.tmp_dir!(),
      pass_name: :crypto.strong_rand_bytes(16) |> Base.encode16(),
      delete_raw_pass: true
    ]

    opts = Keyword.merge(default, opts)

    # Make sure target path is created and available
    random = :crypto.strong_rand_bytes(16) |> Base.encode16()
    target_path = opts[:target_path] <> random <> "/"
    File.mkdir_p(Path.dirname(target_path))

    # Generate pass.json
    pass_json = Passbook.Pass.generate_json(pass)
    File.write(target_path <> "pass.json", pass_json)

    # Generate manifest.json
    manifest_json = create_manifest(["pass.json": target_path <> "pass.json"] ++ files)
    File.write(target_path <> "manifest.json", manifest_json)

    # Generate signature
    create_signature(
      target_path <> "manifest.json",
      target_path <> "signature",
      certificate_path,
      key_path,
      Application.app_dir(:passbook, "priv/wwdr.pem"),
      password
    )

    # Copy all the files to the target folder
    Enum.each(files, fn {filename, path} ->
      File.copy(path, target_path <> Atom.to_string(filename))
    end)

    # Zip the files on a .pkpass, and optionally delete them
    files =
      File.ls!(target_path)
      |> Enum.map(&String.to_charlist/1)

    :zip.create(target_path <> "#{opts[:pass_name]}.pkpass", files, cwd: target_path)
    if opts[:delete_raw_pass], do: Enum.map(files, &File.rm/1)
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
       ),
       do:
         :os.cmd(
           'openssl smime -sign -signer #{certificate_path} -inkey #{key_path} -certfile #{wwdr_certificate_path} -in #{manifest_path} -out #{signature_path} -outform der -binary -passin pass:"#{password}"'
         )
end
