defmodule CacheWeb.CacheControllerTest do
  use CacheWeb.ConnCase

  test "#basic test", %{conn: conn} do
    conn = get(conn, "/")
    assert json_response(conn, 200) == %{"message" => "hello"}
  end

  test "#put a key-value pair in the cache and retrieve the value via key", %{conn: conn} do
    put(conn, "/flush")
    conn = put(conn, "/put", [key: "key1", value: "value1"])
    assert json_response(conn, 200) == %{"message" => "ok"}
    conn = get(conn, "/get?key=key1")
    assert json_response(conn, 200) == %{"message" => "ok", "content" => "value1"}
  end

  test "#retrieve a valid value and an invalid value from the cache", %{conn: conn} do
    put(conn, "/flush")
    put(conn, "/put", [key: "key1", value: "value1"])
    conn = get(conn, "/get?key=key1")
    assert json_response(conn, 200) == %{"message" => "ok", "content" => "value1"}
    conn = get(conn, "/get?key=key2")
    assert json_response(conn, 200) == %{"message" => "not_found", "content" => nil}
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
    assert json_response(conn, 200) == %{"message" => "not_found", "content" => nil}
    conn = get(conn, "/get?key=key2")
    assert json_response(conn, 200) == %{"message" => "not_found", "content" => nil}
    conn = get(conn, "/get_history")
    assert json_response(conn, 200) == %{"content" => ["key3", "key4", "key5", "key6", "key7"], "message" => "ok"}
  end

  test "#update order of keys in the cache", %{conn: conn} do
    put(conn, "/flush")
    put(conn, "/put", [key: "key1", value: "value1"])
    put(conn, "/put", [key: "key2", value: "value2"])
    put(conn, "/put", [key: "key3", value: "value3"])
    put(conn, "/put", [key: "key4", value: "value4"])
    put(conn, "/put", [key: "key5", value: "value5"])
    conn = get(conn, "/get_history")
    assert json_response(conn, 200) == %{"content" => ["key1", "key2", "key3", "key4", "key5"], "message" => "ok"}
    put(conn, "/put", [key: "key1", value: "value11"])
    conn = get(conn, "/get_history")
    assert json_response(conn, 200) == %{"content" => ["key2", "key3", "key4", "key5", "key1"], "message" => "ok"}
    conn = get(conn, "/get?key=key3")
    assert json_response(conn, 200) == %{"message" => "ok", "content" => "value3"}
    conn = get(conn, "/get_history")
    assert json_response(conn, 200) == %{"content" => ["key2", "key4", "key5", "key1", "key3"], "message" => "ok"}
  end

  test "#flush the cache", %{conn: conn} do
    put(conn, "/flush")
    put(conn, "/put", [key: "key1", value: "value1"])
    put(conn, "/put", [key: "key2", value: "value2"])
    put(conn, "/flush")
    conn = get(conn, "/get?key=key1")
    assert json_response(conn, 200) == %{"message" => "not_found", "content" => nil}
    conn = get(conn, "/get?key=key2")
    assert json_response(conn, 200) == %{"message" => "not_found", "content" => nil}
    conn = get(conn, "/get_history")
    assert json_response(conn, 200) == %{"content" => [], "message" => "ok"}
  end
end
