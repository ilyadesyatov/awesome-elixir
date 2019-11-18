defmodule AwesomeWeb.Section do
  use AwesomeWeb, :model

  schema "sections" do
    field :name, :string
    field :description, :string
    has_many :packages, AwesomeWeb.Package, foreign_key: :section_id, on_delete: :delete_all
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def minimum_stars(number) do
    from s in AwesomeWeb.Section,
        join: p in assoc(s, :packages),
        on: p.section_id == s.id,
        where: p.stars >= ^number,
        order_by: s.name,
        preload: [packages: p]
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
  end
end
