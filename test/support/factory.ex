defmodule Awesome.Factory do
  use ExMachina.Ecto, repo: Awesome.Repo

  def section_factory(attrs) do
    colletion = Map.get(attrs, :colletion, %{more_zero: 1})
    packages = Enum.reduce(colletion, [], fn x, acc -> generate_packages(x) ++ acc end) |> Enum.reject(&is_nil/1)
    %AwesomeWeb.Section{
      name: sequence(:name, &"Section name #{&1}"),
      description: "some Section description",
      packages: packages
    }
  end

  def package_factory(attrs) do
    stars = Map.get(attrs, :stars, 0)
    updated_days_ago = Map.get(attrs, :updated_days_ago, 0)
    %AwesomeWeb.Package{
      name: sequence(:name, &"Package Name #{&1}"),
      description: "some Package description",
      stars:  stars,
      updated_days_ago: 33,
      link: "some Package link"
    }
  end

  defp generate_packages(item) do
    case item do
      {more_zero, stars} when stars > 0 -> build_list(stars, :package, stars: 9)
      {more_10, stars} when stars > 0 -> build_list(stars, :package, stars: 49)
      {more_50, stars} when stars > 0 -> build_list(stars, :package, stars: 99)
      {more_100, stars} when stars > 0 -> build_list(stars, :package, stars: 400)
      {more_500, stars} when stars > 0 -> build_list(stars, :package, stars: 800)
      {more_1000, stars} when stars > 0 -> build_list(stars, :package, stars: 1500)
      _ -> nil
    end
  end
end