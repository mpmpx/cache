defmodule CacheWeb.CacheController do
  use CacheWeb, :controller

  def index(conn, _params) do
    json conn, %{:message => "hello"}
  end

  def get(conn, %{"key" => key}) do
    {message, content} = LruCache.get(key)
    json conn, %{:message => message, :content => content}
  end

  def get_history(conn, _) do
    {message, content} = LruCache.get_history()
    json conn, %{:message => message, :content => content}
  end

  def put(conn, %{"key" => key, "value" => value}) do
    res = LruCache.put(key, value)
    json conn, %{:message => res}
  end
end
