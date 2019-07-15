defmodule COS.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :cos,
      version: "0.7.1",
      elixir: "~> 1.7",
      description: "COS China Ocean Shipping Protocol",
      package: package(),
      deps: deps()
    ]
  end

  def package do
    [
      files: ~w(doc include priv src mix.exs LICENSE),
      licenses: ["ISC"],
      maintainers: ["Namdak Tonpa"],
      name: :cos,
      links: %{"GitHub" => "https://github.com/enterprizing/cos"}
    ]
  end

  def application() do
    [mod: {:cos, []}]
  end

  def deps() do
    [
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end
end
