defmodule UniLoggerBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :uni_logger_backend,
      aliases: aliases(),
      package: package(),
      deps: deps(),
      elixir: "~> 1.7",
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.1.0",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["Apache 2.0"],
      maintainers: ["Kristopher Bredemeier"],
      files: ["lib", "mix.exs", "LICENSE", "README.md"],
      links: %{
        "GitHub" => "https://github.com/kbredemeier/uni_logger_backend",
        "Docs" => "https://hexdocs.pm/uni_logger_backend/index.html"
      },
      description: "A logger backend that logs to processes or functions"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp aliases do
    [
      test: ["credo", "test"]
    ]
  end
end
