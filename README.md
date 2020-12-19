# LRU Cache

To start the cache server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
Note:
  * The capacity of cache is set to 5 by default. You can modify the configuration in /config/config.exs and modify the max_size

# APIs
  - [Update Cache](#Update-cache)
  - [Get Value](Get-value)
  - [Show History](Show-history)
  - [Flush Cache](Flush-cache)
---
## Update cache
Updates cache with a key-value pair. When the cache capacity has been reached, inserting a new key results in the least used key
being evicted.

* **URL**

  /put

* **Method**

  `PUT`

* **URL Params**

  None

* **Data Params**

  * **Required:**

  `key=[string]`
  `value=[any]`

* **Success Response:**
  * **Code:** 200

    **Content:** `{ message: "ok"}`

* **Error Response:**
  * **Code:** 400 Bad request

    **Content:** `{error: "data parameters key and value are invalid"}`

---
## Get value
Gets the value of the key that exists in the cache.

* **URL**

  /get

* **Method**

  `GET`

* **URL Params**

  * **Required:**

  `key=[string]`

* **Data Params**

  None

* **Success Response:**
  * **Code:** 200

    **Content:** `{ value: [any]}`

* **Error Response:**
  * **Code:** 400 Bad request

    **Content:** `{error: "query parameter key is invalid"}`

  * **Code:** 404 Not found

    **Content:** `{value: "not_found"}`

---
## Show history
Gets a list of keys stored in the cache. The leftmost key in the list represents
the least recently used one and the rightmost key is the most recently used.

* **URL**

  /get_history

* **Method**

  `GET`

* **URL Params**

  None

* **Data Params**

  None

* **Success Response:**
  * **Code:** 200

    **Content:** `{ history: [list]}`

* **Error Response:**
  * **Code:** 400 Bad request

    **Content:** `{error: "failed to get history of keys in the cache"}`

---
## Flush cache
Removes all records in the cache.

* **URL**

  /flush

* **Method**

  `PUT`

* **URL Params**

  None

* **Data Params**

  None

* **Success Response:**
  * **Code:** 200

    **Content:** `{ message: "ok"}`

* **Error Response:**
  * **Code:** 400 Bad request

    **Content:** `{error: "failed to flush the cache"}`
