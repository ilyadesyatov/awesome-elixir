defmodule AwesomeWeb.PageController do
  use AwesomeWeb, :controller
  alias Awesome.Repo
  alias AwesomeWeb.Section

  def index(conn, params) do
    %{"min_stars" => min_stars} = Map.merge(%{"min_stars" => 0}, params)

    sections = Repo.all(Section.minimum_stars(min_stars))
    render(conn, "index.html", sections: sections)
  end
end
