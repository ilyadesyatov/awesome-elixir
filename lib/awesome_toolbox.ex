defmodule AwesomeToolbox do
  alias AwesomeToolbox.Github
  alias AwesomeWeb.Section
  alias AwesomeWeb.Package
  alias Awesome.Repo
  require Logger

  @github_repo_rx   ~r/https:\/\/github.com\/(?<repo_name>[0-9a-zA-Z._-]+\/[0-9a-zA-Z._-]+)/
  @github_repo_text ~r/[0-9a-zA-Z._-]+ \- |\n/

  def annotate_readme(link) do
    with  {:ok, tuple_readme, html_readme} <- AwesomeToolbox.parse_readme(link),
          {:ok, sections_parse_result} <- AwesomeToolbox.parse_sections(html_readme) do
      {:ok, tuple_readme, sections_parse_result}
    else
      err -> {:error, err}
    end
  end

  def parse_readme(repo_name) do
    with {:ok, readme} <- Github.readme(repo_name),
         {:ok, html_readme, []} <- Earmark.as_html(readme) do
            tuple_readme = Floki.parse(html_readme)
            {:ok, tuple_readme, html_readme}
    else
      err -> {:error, err}
    end
  end

  def parse_sections(html_readme) do
    result = html_readme
      |> Floki.find("ul li ul")
      |> hd
      |> Floki.find("li a")
    {:ok, result}
  end

  def create_section(element_name, tuple_readme) do
    with {:ok, element_description} <- section_description(element_name, tuple_readme) do
      changes = %{description: element_description}
      {:ok, result} =
        case Repo.get_by(Section, name: element_name) do
          nil  -> %Section{name: element_name, description: element_description}
          section -> section
        end
        |> Section.changeset(changes)
        |> Repo.insert_or_update
      {:ok, result}
    else
      err -> {:error, err}
    end
  end

  def section_packages(section, tuple) do
    number = Enum.find_index(tuple, fn x -> x == {"h2", [], [section]} end)
    result = Enum.at(tuple, number + 2) |> Floki.find("li")
    {:ok, result}
  end

  def package(element, section_id) do
    repo_link_name = repo_link(Floki.find(element, "a") |> Floki.attribute("href") |> hd)
    with {:ok, repo_info, update_ago} <- package_info(repo_link_name) do
            repo_text_name = element |> Floki.find("a") |> Floki.text
            repo_description = repo_text(element |> Floki.text)
            %{"stargazers_count" => stargazers_count} = repo_info

            changes = %{stars: stargazers_count, updated_days_ago: update_ago}
            {:ok, result} =
              case Repo.get_by(Package, link: repo_link_name) do
                nil  -> %Package{
                          name: repo_text_name,
                          description: repo_description,
                          stars: stargazers_count,
                          link: repo_link_name,
                          section_id: section_id,
                          updated_days_ago: update_ago
                        }
                package -> package
              end
              |> Package.changeset(changes)
              |> Repo.insert_or_update
            {:ok, result}
    else
      err -> {:error, err}
    end
  end

  def package_info(repo_link_name) do
    with {:ok, repo_info} <- Github.repo_info(repo_link_name),
         {:ok, update_ago} <- Github.repo_last_commit_ago(repo_link_name) do
      {:ok, repo_info, update_ago}
    else
      err -> {:error, err}
    end
  end

  def section_description(section, tuple) do
    number = Enum.find_index(tuple, fn x -> x == {"h2", [], [section]} end)
    result = Enum.at(tuple, number + 1) |> Floki.text
    {:ok, result}
  end

  defp repo_text(text) do
    Regex.replace(@github_repo_text, text, "")
  end

  defp repo_link(link) do
    result = Regex.named_captures(@github_repo_rx, link)
    result["repo_name"]
  end
end
