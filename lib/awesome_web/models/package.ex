defmodule AwesomeWeb.Package do
  use AwesomeWeb, :model

  schema "packages" do
    field :name, :string
    field :description, :string
    field :stars, :integer
    field :link, :string
    field :updated_days_ago, :integer
    belongs_to :section, AwesomeWeb.Section
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :stars, :updated_days_ago])
    |> validate_required([:name, :description, :stars, :updated_days_ago])
  end
end
