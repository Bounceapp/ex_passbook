# Passbook for Elixir [![Hex pm](https://img.shields.io/hexpm/v/passbook.svg?style=flat)](https://hex.pm/packages/passbook) [![hex.pm downloads](https://img.shields.io/hexpm/dt/passbook.svg?style=flat)](https://hex.pm/packages/passbook)

Elixir library to create Apple Wallet (.pkpass) files (Apple Wallet has previously been known as Passbook in iOS 6 to iOS 8).

See the [Wallet Topic Page](https://developer.apple.com/wallet/) and the
[Wallet Developer Guide](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/PassKit_PG/index.html#//apple_ref/doc/uid/TP40012195) for more information about Apple Wallet.

## Installation

This package can be installed by adding `passbook` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:passbook, "~> 0.1.7"}
  ]
end
```

## Getting Started

1. Get a Pass Type Id

- Visit the iOS Provisioning Portal -> Pass Type IDs -> New Pass Type ID
- Select pass type id -> Configure (Follow steps and download generated pass.cer file)
- Use Keychain tool to export a Certificates.p12 file (need Apple Root Certificate installed)

2. Make sure you have open ssl installed, and generate the necessary certificate

```shell
    $ openssl pkcs12 -in "Certificates.p12" -clcerts -nokeys -out certificate.pem
```

3. Generate the key.pem

```shell
    $ openssl pkcs12 -in "Certificates.p12" -nocerts -out key.pem
```

You will be asked for an export password (or export phrase), which you need to use when generating the `.pkpass` files.

## Usage

```elixir

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
        }}, ["icon.png": "path/to/file.png", "icon@2x.png": "path/to/file.png"], "path/to/wwdr.pem", "path/to/certificate.pem", "path/to/key.pem", "password", target_path: System.tmp_dir!(), pass_name: "mypass")
      {:ok, "path/to/generated/mypass.pkpass"}
```
