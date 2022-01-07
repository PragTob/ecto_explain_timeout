defmodule ExplainTimeout.Thing do
  use Ecto.Schema

  schema "things" do
    field(:content, :string)
  end
end
