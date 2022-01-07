# ExplainTimeout

Reproduction Repo got Ecto.SQL.Adapter.explain seemingly not respecting `timeout` settings.

It is reproduced here with a lower timeout for the intent of showcasing it, the real use case is of course increasing the timeout while running with `analyze: true` to understand those slow queries :) As shown [in the docs](https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.html#explain/4-examples):

```
Ecto.Adapters.SQL.explain(Repo, :all, Post, analyze: true, timeout: 20_000)
```

Used versions, see `.tool-versions`

Here are the steps to reproduce:


```bash
git clone ...
cd explain_timeout
mix deps.get
# adjust config.exs for Postgres config or set POSTGRES_USER and POSTGRES_PASSWORD
mix ecto.setup

iex -S mix
# does not blow up as using default timeout which is 15_000
iex(4)> Repo.all(Thing); nil

16:05:40.695 [debug] QUERY OK source="things" db=13.5ms decode=0.6ms idle=1745.2ms
SELECT t0."id", t0."content" FROM "things" AS t0 []
nil


# blows up, this is expected
iex(5)> Repo.all(Thing, timeout: 1); nil
16:05:43.831 [error] Postgrex.Protocol (#PID<0.250.0>) disconnected: ** (DBConnection.ConnectionError) client #PID<0.259.0> timed out because it queued and checked out the connection for longer than 1ms

#PID<0.259.0> was at location:

    :prim_inet.recv0/3
    (postgrex 0.15.13) lib/postgrex/protocol.ex:2996: Postgrex.Protocol.msg_recv/4
    (postgrex 0.15.13) lib/postgrex/protocol.ex:2042: Postgrex.Protocol.recv_bind/3
    (postgrex 0.15.13) lib/postgrex/protocol.ex:1934: Postgrex.Protocol.bind_execute/4
    (db_connection 2.4.1) lib/db_connection/holder.ex:354: DBConnection.Holder.holder_apply/4
    (db_connection 2.4.1) lib/db_connection.ex:1333: DBConnection.run_execute/5
    (db_connection 2.4.1) lib/db_connection.ex:1428: DBConnection.run/6
    (db_connection 2.4.1) lib/db_connection.ex:650: DBConnection.execute/4


16:05:43.831 [debug] QUERY ERROR source="things" db=3.9ms idle=1892.8ms
SELECT t0."id", t0."content" FROM "things" AS t0 []
** (DBConnection.ConnectionError) tcp recv: closed (the connection was closed by the pool, possibly due to a timeout or because the pool has been terminated)
    (ecto_sql 3.7.1) lib/ecto/adapters/sql.ex:760: Ecto.Adapters.SQL.raise_sql_call_error/1
    (ecto_sql 3.7.1) lib/ecto/adapters/sql.ex:693: Ecto.Adapters.SQL.execute/5
    (ecto 3.7.1) lib/ecto/repo/queryable.ex:219: Ecto.Repo.Queryable.execute/4
    (ecto 3.7.1) lib/ecto/repo/queryable.ex:19: Ecto.Repo.Queryable.all/3


# Also blos up, also expected
iex(5)> Ecto.Adapters.SQL.query!(Repo, "SELECT * FROM things'", [], timeout: 1)

16:05:49.520 [error] Postgrex.Protocol (#PID<0.253.0>) disconnected: ** (DBConnection.ConnectionError) client #PID<0.259.0> timed out because it queued and checked out the connection for longer than 1ms

#PID<0.259.0> was at location:

    (kernel 8.0.1) code_server.erl:139: :code_server.call/1
    (kernel 8.0.1) error_handler.erl:40: :error_handler.undefined_function/3
    (postgrex 0.15.13) lib/postgrex/protocol.ex:1412: Postgrex.Protocol.recv_parse/3
    (postgrex 0.15.13) lib/postgrex/protocol.ex:1374: Postgrex.Protocol.recv_parse_describe/4
    (postgrex 0.15.13) lib/postgrex/protocol.ex:1188: Postgrex.Protocol.parse_describe_flush/3
    (db_connection 2.4.1) lib/db_connection/holder.ex:354: DBConnection.Holder.holder_apply/4
    (db_connection 2.4.1) lib/db_connection.ex:1318: DBConnection.prepare/4
    (db_connection 2.4.1) lib/db_connection.ex:1311: DBConnection.run_prepare/4

** (DBConnection.ConnectionError) tcp send: closed (the connection was closed by the pool, possibly due to a timeout or because the pool has been terminated)
    (ecto_sql 3.7.1) lib/ecto/adapters/sql.ex:760: Ecto.Adapters.SQL.raise_sql_call_error/1

16:05:49.524 [debug] QUERY ERROR db=0.0ms queue=5.4ms idle=1440.7ms
SELECT * FROM things' []


# does not blow up as it does not respect the timeout
iex(5)> Ecto.Adapters.SQL.explain(Repo, :all, Thing, analyze: true, timeout: 1)

16:05:54.094 [debug] QUERY OK db=1.0ms idle=1013.6ms
begin []

16:05:54.105 [debug] QUERY OK db=9.3ms
EXPLAIN ANALYZE SELECT t0."id", t0."content" FROM "things" AS t0 []

16:05:54.106 [debug] QUERY OK db=0.3ms
rollback []
"Seq Scan on things t0  (cost=0.00..521.00 rows=30000 width=28) (actual time=0.031..5.135 rows=30000 loops=1)\nPlanning Time: 0.851 ms\nExecution Time: 7.714 ms"

```
