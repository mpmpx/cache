defmodule CacheWeb.CacheControllerTest do
  use CacheWeb.ConnCase

  test "#basic test", %{conn: conn} do
    conn = get(conn, "/")
    assert json_response(conn, :ok) == %{"message" => "hello"}
  end

  test "#put a key-value pair in the cache and retrieve the value via key", %{conn: conn} do
    put(conn, "/flush")
    conn = put(conn, "/put", [key: "key1", value: "value1"])
    assert json_response(conn, :ok) == %{"message" => "ok"}
    conn = get(conn, "/get?key=key1")
    assert json_response(conn, :ok) == %{"value" => "value1"}
  end

  test "#retrieve a valid value and an invalid value from the cache", %{conn: conn} do
    put(conn, "/flush")
    put(conn, "/put", [key: "key1", value: "value1"])
    conn = get(conn, "/get?key=key1")
    assert json_response(conn, :ok) == %{"value" => "value1"}
    conn = get(conn, "/get?key=key2")
    assert json_response(conn, :not_found) == %{"value" => "not_found"}
  end

  test "#evict least recently used key when put a new key and the capacity of the cache is full", %{conn: conn} do
    put(conn, "/flush")
    put(conn, "/put", [key: "key1", value: "value1"])
    put(conn, "/put", [key: "key2", value: "value2"])
    put(conn, "/put", [key: "key3", value: "value3"])
    put(conn, "/put", [key: "key4", value: "value4"])
    put(conn, "/put", [key: "key5", value: "value5"])
    put(conn, "/put", [key: "key6", value: "value6"])
    put(conn, "/put", [key: "key7", value: "value7"])
    conn = get(conn, "/get?key=key1")
    assert json_response(conn, :not_found) == %{"value" => "not_found"}
    conn = get(conn, "/get?key=key2")
    assert json_response(conn, :not_found) == %{"value" => "not_found"}
    conn = get(conn, "/get_history")
    assert json_response(conn, :ok) == %{"history" => ["key3", "key4", "key5", "key6", "key7"]}
  end

  test "#update order of keys in the cache", %{conn: conn} do
    put(conn, "/flush")
    put(conn, "/put", [key: "key1", value: "value1"])
    put(conn, "/put", [key: "key2", value: "value2"])
    put(conn, "/put", [key: "key3", value: "value3"])
    put(conn, "/put", [key: "key4", value: "value4"])
    put(conn, "/put", [key: "key5", value: "value5"])
    conn = get(conn, "/get_history")
    assert json_response(conn, :ok) == %{"history" => ["key1", "key2", "key3", "key4", "key5"]}
    put(conn, "/put", [key: "key1", value: "value11"])
    conn = get(conn, "/get_history")
    assert json_response(conn, :ok) == %{"history" => ["key2", "key3", "key4", "key5", "key1"]}
    conn = get(conn, "/get?key=key3")
    assert json_response(conn, :ok) == %{"value" => "value3"}
    conn = get(conn, "/get_history")
    assert json_response(conn, :ok) == %{"history" => ["key2", "key4", "key5", "key1", "key3"]}
  end

  test "#flush the cache", %{conn: conn} do
    put(conn, "/flush")
    put(conn, "/put", [key: "key1", value: "value1"])
    put(conn, "/put", [key: "key2", value: "value2"])
    put(conn, "/flush")
    conn = get(conn, "/get?key=key1")
    assert json_response(conn, :not_found) == %{"value" => "not_found"}
    conn = get(conn, "/get?key=key2")
    assert json_response(conn, :not_found) == %{"value" => "not_found"}
    conn = get(conn, "/get_history")
    assert json_response(conn, :ok) == %{"history" => []}
  end

  test "#bad request to the server", %{conn: conn} do
    put(conn, "/flush")
    conn = get(conn, "/get?")
    assert json_response(conn, :bad_request) == %{"error" => "query parameter key is invalid"}
    conn = put(conn, "/put")
    assert json_response(conn, :bad_request) == %{"error" => "data parameters key and value are invalid"}
  end
end
