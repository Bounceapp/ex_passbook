defmodule Passbook.MixProject do
  use Mix.Project

  def project do
    [
      app: :passbook,
      version: "0.1.8",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      description: "Elixir library to create Apple Wallet (.pkpass) files.",
      package: package(),
      deps: deps(),
      # Docs
      name: "Passbook",
      source_url: "https://github.com/Bounceapp/ex_passbook",
      homepage_url: "https://github.com/Bounceapp/ex_passbook",
      docs: [
        # The main page in the docs
        main: "Passbook",
        extras: ["README.md"]
      ],
      xref: [exclude: [:crypto]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:nested_filter, "~> 1.2.2"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Bounceapp/ex_passbook"}
    ]
  end
end
