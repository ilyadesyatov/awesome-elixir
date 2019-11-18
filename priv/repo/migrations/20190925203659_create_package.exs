defmodule Funbox.Repo.Migrations.CreatePackage do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :name, :string
      add :description, :text
      add :stars, :integer
      add :link, :string
      add :updated_days_ago, :integer
      add :section_id, references(:sections)
    end

    create index(:packages, [:section_id])
  end
end
