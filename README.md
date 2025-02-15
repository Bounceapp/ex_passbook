# Passbook for Elixir [![Hex pm](https://img.shields.io/hexpm/v/passbook.svg?style=flat)](https://hex.pm/packages/passbook) [![hex.pm downloads](https://img.shields.io/hexpm/dt/passbook.svg?style=flat)](https://hex.pm/packages/passbook)

Elixir library to create Apple Wallet (.pkpass) files (Apple Wallet has previously been known as Passbook in iOS 6 to iOS 8).

See the [Wallet Topic Page](https://developer.apple.com/wallet/) and the
[Wallet Developer Guide](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/PassKit_PG/index.html#//apple_ref/doc/uid/TP40012195) for more information about Apple Wallet.

## Installation

This package can be installed by adding `passbook` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:passbook, "~> 0.1.8"}
  ]
end
```

## Getting Started

1. Get a Pass Type Id

- Visit the iOS Provisioning Portal -> Pass Type IDs -> New Pass Type ID
- Select pass type id -> Configure (Follow steps and download generated pass.cer file)
- You will get a .cer file, which you can convert to .pem file with `openssl`

```shell
openssl x509 -in pass.cer -inform DER -outform PEM -out certificate.pem
```

- Convert your private key to encrypted .pem file with `openssl`

```shell
openssl rsa -in key.pem -des3 -out private_key.pem
```

- Convert your wwdr.cer to .pem file with `openssl`

```shell
openssl x509 -in wwdr.cer -inform DER -outform PEM -out wwdr.pem
```

## Usage

See doctests in `lib/passbook.ex`
