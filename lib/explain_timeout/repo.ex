defmodule ExplainTimeout.Repo do
  use Ecto.Repo,
    otp_app: :explain_timeout,
    adapter: Ecto.Adapters.Postgres
end
