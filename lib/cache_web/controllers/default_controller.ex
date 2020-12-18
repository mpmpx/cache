defmodule CacheWeb.DefaultController do
  use CacheWeb, :controller

  def index(conn, _params) do
    json conn, %{:message => "hello"}
  end
end
