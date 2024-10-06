from(bucket: "mybucket")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "file")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["category"] == "latency")

-- ---------------------------
-- see what columns you have
import "strings"

from(bucket: "mybucket")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "file")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX.EX1"))
  |> filter(fn: (r) => strings.containsStr(v: r.metric, substr: "jvm.memory.used"))
  |> columns()

-- ---------------------------
-- see what values you have in a column
import "strings"

from(bucket: "mybucket")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "file")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX.EX1"))
  |> filter(fn: (r) => strings.containsStr(v: r.metric, substr: "jvm.memory.used"))
  |> keep(columns: ["_measurement", "_field", "filename", "host", "metric"])
  |> limit(n: 10)

-- ----------------------------
import "strings"

from(bucket: "mybucket")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "file")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX.EX1"))
  |> filter(fn: (r) => strings.containsStr(v: r.metric, substr: "jvm.memory.used"))

-- ----------------------------
import "strings"

from(bucket: "mybucket")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r["_measurement"] == "file")
|> filter(fn: (r) => r["_field"] == "value")
|> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX.EX1"))
|> filter(fn: (r) => strings.containsStr(v: r.metric, substr: "jvm.memory.used"))
|> group(columns: ["filename"])
|> aggregateWindow(every: 1s, fn: sum)


-- |> group(columns: ["filename"])
-- |> aggregateWindow(every: 1s, fn: sum)
-- |> pivot(rowKey:["_time"], columnKey: ["_measurement"], valueColumn: "_value")

-- ----------------------------

-- ----------------------------
-- client metrics analysis
-- ----------------------------

-- Align the data based on EX.EX1

import "strings"

t1Start = from(bucket: "mybucket")
  |> range(start: -10y)
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX1"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "client"))
  |> filter(fn: (r) => r.metric == "read")
  |> first()
  |> findRecord(fn: (key) => key._field == "value", idx: 0)

t2Start = from(bucket: "mybucket")
  |> range(start: -10y)
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX2"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "client"))
  |> filter(fn: (r) => r.metric == "read")
  |> first()
  |> findRecord(fn: (key) => key._field == "value", idx: 0)

diff = uint(v: t2Start._time) - uint(v: t1Start._time)

t1Data = from(bucket: "mybucket")
  |> range(start: -10y)
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX1"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "client"))
  |> filter(fn: (r) => r.metric != "cleanup")
  |> yield(name: "t1Data")

t2Data = from(bucket: "mybucket")
  |> range(start: -10y)
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "EX2"))
  |> filter(fn: (r) => strings.containsStr(v: r.filename, substr: "client"))
  |> filter(fn: (r) => r.metric != "cleanup")
  |> map(fn: (r) => ({r with _time: time(v: uint(v: r._time) - diff)}))
  |> yield(name: "t2Data")
