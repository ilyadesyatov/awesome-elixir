defmodule AwesomeToolbox do
  alias AwesomeToolbox.Github
  alias AwesomeToolbox.GithubParser
  alias AwesomeWeb.Section
  alias AwesomeWeb.Package
  alias Awesome.Repo
  require Logger

  def annotate_readme(link) do
    with  {:ok, tuple_readme, html_readme} <- GithubParser.parse_readme(link),
          {:ok, sections_in_readme} <- GithubParser.parse_sections(html_readme) do
          results = Enum.map(sections_in_readme, fn(section) ->
              {:ok, packages, description} = GithubParser.section_info(section, tuple_readme)
              {:ok, section_item} = create_section(section, description)
              Enum.map(packages, fn(package) ->
                {:ok, package} = create_package(%{description: package[:description],
                  name: package[:name],
                  link: package[:link],
                  section_id: section_item.id
                })
                package
              end)
          end)
          |> List.flatten
      {:ok, results}
    else
      err -> {:error, err}
    end
  end

  def create_section(name, description) do
    changes = %{description: description}
    {:ok, result} =
      case Repo.get_by(Section, name: name) do
        nil  -> %Section{name: name, description: description}
        section -> section
      end
      |> Section.changeset(changes)
      |> Repo.insert_or_update
    {:ok, result}
  end

  def create_package(changes) do
    %{link: link, name: name, section_id: section_id, description: description} = changes
    {:ok, result} =
      case Repo.get_by(Package, link: link) do
        nil  -> %Package{
                  name: name,
                  description: description,
                  link: link,
                  section_id: section_id
                }
        package -> package
      end
      |> Package.changeset(changes)
      |> Repo.insert_or_update
    {:ok, result}
  end

  def update_package(object, changes) do
    result = object
      |> Ecto.Changeset.change(changes)
      |> Repo.update
    {:ok, result}
  end
end
