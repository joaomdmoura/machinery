defmodule Machinery.Mixfile do
  use Mix.Project

  @source_url "https://github.com/joaomdmoura/machinery"
  @version "1.1.0"

  def project do
    [
      app: :machinery,
      version: @version,
      elixir: "~> 1.14",
      compilers: Mix.compilers(),
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      mod: {Machinery, []}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      description:
        "Machinery is a State Machine library for structs in general. " <>
          "It supports guard clauses, callbacks and integrate out of the box " <>
          "with Phoenix apps.",
      maintainers: ["João M. D. Moura"],
      licenses: ["Apache-2.0"],
      links: %{
        "Changelog" => "https://hexdocs.pm/machinery/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "CONTRIBUTING.md": [],
        "CODE_OF_CONDUCT.md": [title: "Code of Conduct"],
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      assets: "assets",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end
