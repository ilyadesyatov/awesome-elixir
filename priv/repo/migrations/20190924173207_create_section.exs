defmodule Funbox.Repo.Migrations.CreateSection do
  use Ecto.Migration

  def change do
    create table(:sections) do
      add :name, :string
      add :description, :text
    end
  end
end
