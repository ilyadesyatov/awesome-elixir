defmodule AwesomeWeb.Section do
  use AwesomeWeb, :model

  schema "sections" do
    field :name, :string
    field :description, :string
    has_many :packages, AwesomeWeb.Package, foreign_key: :section_id, on_delete: :delete_all, on_replace: :delete
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
  end
end
