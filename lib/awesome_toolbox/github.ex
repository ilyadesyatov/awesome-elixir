defmodule AwesomeToolbox.Github do
  require Logger

  @default_headers [{"Authorization", "Bearer #{Application.get_env(:awesome, :github_token)}"}]

  def readme(repo_name) do
    with {:ok, %HTTP.Response{status_code: 200} = resp} <-
           HTTP.get("https://api.github.com/repos/#{repo_name}/readme", @default_headers),
         {:ok, json} <- Jason.decode(resp.body),
         {:ok, readme} <- Base.decode64(json["content"], ignore: :whitespace) do
      {:ok, readme}
    else
      err -> {:error, err}
    end
  end

  def stars_count(repo_name) do
    with {:ok, %{"stargazers_count" => stargazers_count} = repo_info} <- repo_info(repo_name) do
      {:ok, stargazers_count}
    else
      err -> {:error, err}
    end
  end

  def repo_info(repo_name) do
    with {:ok, %HTTP.Response{status_code: 200} = resp} <-
           HTTP.get("https://api.github.com/repos/#{repo_name}", @default_headers),
         {:ok, repo_info} <- Jason.decode(resp.body) do
      {:ok, repo_info}
    else
      err -> {:error, err}
    end
  end

  def repo_last_commit_ago(repo_name) do
    with {:ok, first_commit} <- repo_last_commit_info(repo_name) do
      {:ok, date, 0} = DateTime.from_iso8601(first_commit["commit"]["author"]["date"])
      days = Date.diff(Date.utc_today(), DateTime.to_date(date))
      {:ok, days}
    else
      err -> {:error, err}
    end
  end

  def repo_last_commit_info(repo_name) do
    with {:ok, %HTTP.Response{status_code: 200} = resp} <-
           HTTP.get("https://api.github.com/repos/#{repo_name}/commits", @default_headers),
         {:ok, json} <- Jason.decode(resp.body),
         first_commit <- Enum.at(json, 0) do
      {:ok, first_commit}
    else
      err -> {:error, err}
    end
  end
end
