defmodule Funbox.Repo.Migrations.CreatePackage do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :name, :string
      add :description, :text
      add :stars, :integer
      add :updated_days_ago, :integer
      add :section_id, references(:sections)
      timestamps()
    end
  end
end
