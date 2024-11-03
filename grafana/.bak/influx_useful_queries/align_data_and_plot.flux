import "strings"

t1Start = from(bucket: "client_metrics_raw")
  |> range(start: -10y)
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX1"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "client"))
  |> filter(fn: (r) => r.metric == "read")
  |> first()
  |> findRecord(fn: (key) => key._field == "value", idx: 0)

t2Start = from(bucket: "client_metrics_raw")
  |> range(start: -10y)
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX2"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "client"))
  |> filter(fn: (r) => r.metric == "read")
  |> first()
  |> findRecord(fn: (key) => key._field == "value", idx: 0)

diff = uint(v: t2Start._time) - uint(v: t1Start._time)

t1Data = from(bucket: "client_metrics_raw")
  |> range(start: -10y)
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX1"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "client"))
  |> filter(fn: (r) => r.metric != "cleanup")

t2Data = from(bucket: "client_metrics_raw")
  |> range(start: -10y)
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX2"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "client"))
  |> filter(fn: (r) => r.metric != "cleanup")
  |> map(fn: (r) => ({r with _time: time(v: uint(v: r._time) - diff)}))

unionedData = union(tables: [t1Data, t2Data])
  |> yield(name: "unionedData")
