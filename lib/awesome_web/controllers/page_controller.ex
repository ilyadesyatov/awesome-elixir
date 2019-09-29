defmodule AwesomeWeb.PageController do
  use AwesomeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
