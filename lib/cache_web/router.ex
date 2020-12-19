defmodule CacheWeb.Router do
  use CacheWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CacheWeb do
    pipe_through :api
    get "/", CacheController, :index
    get "/get", CacheController, :get
    get "/get_all", CacheController, :get_all
    put "/put", CacheController, :put
  end
end
