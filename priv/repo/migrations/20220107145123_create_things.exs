defmodule ExplainTimeout.Repo.Migrations.CreateThings do
  use Ecto.Migration

  def change do
    create table(:things) do
      add :content, :string
    end
  end
end
