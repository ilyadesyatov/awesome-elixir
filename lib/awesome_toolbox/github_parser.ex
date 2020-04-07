defmodule AwesomeToolbox.GithubParser do
  alias AwesomeToolbox.Github

  @github_repo_rx ~r/https:\/\/github.com\/(?<repo_name>[0-9a-zA-Z._-]+\/[0-9a-zA-Z._-]+)/
  @github_repo_text ~r/[0-9a-zA-Z._-]+ \- |\n/

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
    result =
      html_readme
      |> Floki.find("ul li ul")
      |> hd
      |> Floki.find("li a")
      |> Enum.map(fn s -> hd(elem(s, 2)) end)

    {:ok, result}
  end

  def section_info(section, tuple) do
    number = Enum.find_index(tuple, fn x -> x == {"h2", [], [section]} end)
    packages = Enum.at(tuple, number + 2) |> Floki.find("li") |> parse_packages
    description = Enum.at(tuple, number + 1) |> Floki.text()
    {:ok, packages, description}
  end

  def parse_packages(packages) do
    Enum.map(packages, fn package ->
      [
        name: package_name(package),
        description: package_description(package),
        link: package_link(package)
      ]
    end)
  end

  def package_info(repo_link_name) do
    link_name = repo_link(repo_link_name)

    with {:ok, stars} <- Github.stars_count(link_name),
         {:ok, update_ago} <- Github.repo_last_commit_ago(link_name) do
      {:ok, stars, update_ago}
    else
      err -> {:error, err}
    end
  end

  defp package_name(element) do
    element |> Floki.find("a") |> Floki.text()
  end

  defp package_link(element) do
    element |> Floki.find("a") |> Floki.attribute("href") |> hd
  end

  defp package_description(element) do
    repo_text(element |> Floki.text())
  end

  defp repo_text(text) do
    Regex.replace(@github_repo_text, text, "")
  end

  defp repo_link(link) do
    result = Regex.named_captures(@github_repo_rx, link)
    result["repo_name"]
  end
end
