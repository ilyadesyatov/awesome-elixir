defmodule AwesomeWeb.PageController do
  use AwesomeWeb, :controller
#  import Plug.Conn
  alias Awesome.Repo
  alias AwesomeWeb.Section
#  alias AwesomeWeb.Package
  require Ecto.Query

  def index(conn, params) do
    %{"min_stars" => min_stars } = Map.merge(%{ "min_stars" => 0 }, params)

    query = Ecto.Query.from s in Section,
                            join: p in assoc(s, :packages),
                            on: p.section_id == s.id,
                            where: p.stars >= ^min_stars,
                            order_by: s.name,
                            preload: [packages: p]


    sections = Repo.all(query)

    render conn, "index.html", sections: sections
  end
end
