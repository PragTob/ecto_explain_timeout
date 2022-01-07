import Config

config :explain_timeout, ExplainTimeout.Repo,
  database: "explain_timeout_repo",
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  hostname: "localhost"

config :explain_timeout, ecto_repos: [ExplainTimeout.Repo]
