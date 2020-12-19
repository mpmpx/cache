defmodule CacheWeb.CacheController do
  use CacheWeb, :controller

  def index(conn, _params) do
    json conn, %{:message => "hello"}
  end

  def get(conn, params) do
    case params do
      %{"key" => key} ->
        {status_code, value} = LruCache.get(key)
        respond(conn, status_code, %{:value => value})
      _error->
        respond(conn, :bad_request, %{:error => "query parameter key is invalid"})
    end
  end

  def get_history(conn, _params) do
    case LruCache.get_history() do
      {:ok, history} ->
        respond(conn, :ok, %{:history => history})
      _error ->
        respond(conn, :bad_request, %{:error => "failed to get history of keys in the cache"})
    end

  end

  def put(conn, params) do
    case params do
      %{"key" => key, "value" => value} ->
        case LruCache.put(key, value) do
          :ok ->
            respond(conn, :ok, %{:message => :ok})
          _error ->
            respond(conn, :bad_request, %{:error => "failed to put value in the cache"})
        end
      _error->
        respond(conn, :bad_request, %{:error => "data parameters key and value are invalid"})
    end
  end

  def flush(conn, _) do
    case LruCache.flush() do
      :ok ->
        respond(conn, :ok, %{:message => :ok})
      _error ->
        respond(conn, :bad_request, %{:error => "failed to flush the cache"})
    end
  end

  defp respond(conn, status_code, res_message) do
    conn
    |> put_status(status_code)
    |> json(res_message)
  end
end
