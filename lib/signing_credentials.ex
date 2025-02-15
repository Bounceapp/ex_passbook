defmodule Passbook.SigningCredentials do
  @moduledoc """
  Struct containing the required certificates, keys, and credentials for pass signing.
  Each certificate/key source can be either a file path or content.
  """

  @typedoc """
  Represents either a file path or direct content string for a certificate/key.
  - `{:file, path}` - Path to the certificate/key file
  - `{:content, string}` - The actual certificate/key content as a string
  """
  @type source :: {:file, Path.t()} | {:content, binary()}

  @typedoc """
  SigningCredentials struct containing:
  - `wwdr` - Apple Worldwide Developer Relations (WWDR) certificate
  - `certificate` - Your signing certificate
  - `private_key` - Your private key for signing
  - `key_password` - Password for the private key
  - `temp_files` - List of temporary files created (for internal use)
  """
  @type t :: %__MODULE__{
          wwdr: source(),
          certificate: source(),
          private_key: source(),
          key_password: String.t() | nil,
          temp_files: list(Path.t())
        }

  defstruct [:wwdr, :certificate, :private_key, :key_password, temp_files: []]

  @doc """
  Creates a new SigningCredentials struct with the required sources.

  ## Parameters
    * `wwdr` - WWDR certificate source
    * `certificate` - Signing certificate source
    * `private_key` - Private key source
    * `key_password` - Password for the private key (optional)

  ## Examples

      iex> Passbook.SigningCredentials.new(
      ...>   {:file, "path/to/wwdr.pem"},
      ...>   {:file, "path/to/certificate.pem"},
      ...>   {:file, "path/to/key.pem"},
      ...>   "secret_password"
      ...> )
      %Passbook.SigningCredentials{
        wwdr: {:file, "path/to/wwdr.pem"},
        certificate: {:file, "path/to/certificate.pem"},
        private_key: {:file, "path/to/key.pem"},
        key_password: "secret_password"
      }

      # Without password
      iex> Passbook.SigningCredentials.new(
      ...>   {:content, "-----BEGIN CERTIFICATE-----\\n..."},
      ...>   {:content, "-----BEGIN CERTIFICATE-----\\n..."},
      ...>   {:content, "-----BEGIN RSA PRIVATE KEY-----\\n..."}
      ...> )
      %Passbook.SigningCredentials{
        wwdr: {:content, "-----BEGIN CERTIFICATE-----\\n..."},
        certificate: {:content, "-----BEGIN CERTIFICATE-----\\n..."},
        private_key: {:content, "-----BEGIN RSA PRIVATE KEY-----\\n..."},
        key_password: nil
      }
  """
  @spec new(source(), source(), source(), String.t() | nil) :: t()
  def new(wwdr, certificate, private_key, key_password \\ nil) do
    %__MODULE__{
      wwdr: wwdr,
      certificate: certificate,
      private_key: private_key,
      key_password: key_password
    }
  end

  @doc """
  Prepares the credentials for use by ensuring all sources are available as files.
  Returns updated credentials with paths to all required files.

  For file sources, uses the original path.
  For content sources, creates temporary files that will be cleaned up later.

  ## Examples

      # File sources remain unchanged
      iex> credentials = Passbook.SigningCredentials.new(
      ...>   {:file, "test/fixtures/wwdr.pem"},
      ...>   {:file, "test/fixtures/cert.pem"},
      ...>   {:file, "test/fixtures/key.pem"}
      ...> )
      iex> {:ok, prepared} = Passbook.SigningCredentials.prepare(credentials)
      iex> prepared.temp_files
      []

      # Content sources create temporary files
      iex> credentials = Passbook.SigningCredentials.new(
      ...>   {:content, "wwdr content"},
      ...>   {:content, "cert content"},
      ...>   {:content, "key content"}
      ...> )
      iex> {:ok, prepared} = Passbook.SigningCredentials.prepare(credentials)
      iex> length(prepared.temp_files)
      3

      # Invalid sources return error
      iex> credentials = Passbook.SigningCredentials.new(
      ...>   "invalid",
      ...>   {:file, "test/fixtures/cert.pem"},
      ...>   {:file, "test/fixtures/key.pem"}
      ...> )
      iex> Passbook.SigningCredentials.prepare(credentials)
      {:error, {:invalid_source, "invalid"}}
  """
  @spec prepare(t()) :: {:ok, t()} | {:error, term()}
  def prepare(%__MODULE__{} = credentials) do
    with {:ok, wwdr, temp_files1} <- ensure_file_exists(credentials.wwdr),
         {:ok, cert, temp_files2} <- ensure_file_exists(credentials.certificate),
         {:ok, key, temp_files3} <- ensure_file_exists(credentials.private_key) do
      prepared = %__MODULE__{
        credentials
        | wwdr: {:file, wwdr},
          certificate: {:file, cert},
          private_key: {:file, key},
          temp_files: temp_files1 ++ temp_files2 ++ temp_files3
      }

      {:ok, prepared}
    end
  end

  @doc """
  Cleans up any temporary files created during preparation.

  ## Example

      iex> credentials = Passbook.SigningCredentials.new(
      ...>   {:content, "wwdr content"},
      ...>   {:content, "cert content"},
      ...>   {:content, "key content"}
      ...> )
      iex> {:ok, prepared} = Passbook.SigningCredentials.prepare(credentials)
      iex> length(prepared.temp_files) > 0
      true
      iex> Passbook.SigningCredentials.cleanup(prepared)
      :ok
      iex> Enum.all?(prepared.temp_files, &(!File.exists?(&1)))
      true
  """
  @spec cleanup(t()) :: :ok
  def cleanup(%__MODULE__{temp_files: temp_files}) do
    Enum.each(temp_files, &File.rm/1)
    :ok
  end

  @doc """
  Returns the file path for a given source.

  ## Examples

      iex> Passbook.SigningCredentials.get_path({:file, "/path/to/cert.pem"})
      {:ok, "/path/to/cert.pem"}

      iex> Passbook.SigningCredentials.get_path({:content, "certificate content"})
      {:error, {:invalid_source, {:content, "certificate content"}}}

      iex> Passbook.SigningCredentials.get_path("invalid source")
      {:error, {:invalid_source, "invalid source"}}
  """
  @spec get_path(source()) :: {:ok, Path.t()} | {:error, term()}
  def get_path({:file, path}), do: {:ok, path}
  def get_path(source), do: {:error, {:invalid_source, source}}

  # Private functions

  defp ensure_file_exists({:file, path}), do: {:ok, path, []}

  defp ensure_file_exists({:content, content}) do
    tmp_path = Path.join(System.tmp_dir!(), random_filename())

    case File.write(tmp_path, content) do
      :ok -> {:ok, tmp_path, [tmp_path]}
      error -> error
    end
  end

  defp ensure_file_exists(source), do: {:error, {:invalid_source, source}}

  defp random_filename do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
    |> Kernel.<>(".pem")
  end
end
