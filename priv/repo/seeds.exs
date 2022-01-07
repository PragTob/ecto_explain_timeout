# Just create some data so queries take more than 1ms

content = [%{content: "some string content"}]
|> Stream.cycle()
|> Enum.take(30_000)

ExplainTimeout.Repo.insert_all(ExplainTimeout.Thing, content)
