defmodule SignatureTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  @temp_dir "test_temp"
  @priv_dir "priv"

  setup do
    File.mkdir_p!(@temp_dir)
    on_exit(fn -> File.rm_rf!(@temp_dir) end)
    :ok
  end

  describe "create_signature/6" do
    test "successfully creates a signature with correct password" do
      {
        manifest_path,
        signature_path,
        certificate_path,
        key_path,
        wwdr_certificate_path,
        correct_password
      } = setup_test_files()

      result =
        Passbook.Helpers.create_signature(
          manifest_path,
          signature_path,
          certificate_path,
          key_path,
          wwdr_certificate_path,
          correct_password
        )

      assert result == :ok
      assert File.exists?(signature_path)
      signature_content = File.read!(signature_path)
      assert byte_size(signature_content) > 0, "Generated signature file is empty"
    end

    test "fails to create signature with incorrect password" do
      {
        manifest_path,
        signature_path,
        certificate_path,
        key_path,
        wwdr_certificate_path,
        _correct_password
      } = setup_test_files()

      incorrect_password = "incorrect_password"

      result =
        Passbook.Helpers.create_signature(
          manifest_path,
          signature_path,
          certificate_path,
          key_path,
          wwdr_certificate_path,
          incorrect_password
        )

      assert {:error, _} = result
      assert File.exists?(signature_path)
      signature_content = File.read!(signature_path)
      assert byte_size(signature_content) == 0, "Generated signature file is not empty"
    end
  end

  # Helper function to set up test files
  defp setup_test_files do
    manifest_path = Path.join(@temp_dir, "manifest.json")
    signature_path = Path.join(@temp_dir, "signature")
    certificate_path = Path.join(@temp_dir, "certificate.pem")
    key_path = Path.join(@temp_dir, "private_key.pem")
    wwdr_certificate_path = Path.join(@priv_dir, "wwdr.pem")
    password = "correct_password"

    # Create a dummy manifest file
    File.write!(manifest_path, ~s({"test": "manifest"}))

    # Generate a password-protected private key and certificate
    System.cmd("openssl", [
      "req",
      "-x509",
      "-newkey",
      "rsa:2048",
      "-keyout",
      key_path,
      "-out",
      certificate_path,
      "-days",
      "365",
      "-subj",
      "/C=US/ST=State/L=City/O=Organization/CN=Test",
      "-passout",
      "pass:#{password}"
    ])

    {manifest_path, signature_path, certificate_path, key_path, wwdr_certificate_path, password}
  end
end
