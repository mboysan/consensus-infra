import "strings"

testGroupToUse="EX"
sourceToUse="client"

allData = from(bucket: "clientmetrics")
  |> range(start: -10y)
  |> map(fn: (r) => ({
    r with
    testGroup: strings.split(v: r.filename, t: ".")[0],
    testName: strings.split(v: r.filename, t: ".")[1],
    testId: strings.split(v: r.filename, t: ".")[0] + "." + strings.split(v: r.filename, t: ".")[1],
    source: strings.split(v: r.filename, t: ".")[2]
  }))
  |> filter(fn: (r) => r.testGroup == testGroupToUse and r.source == sourceToUse)

t1Start = allData
  |> filter(fn: (r) => r.testName == "EX1")
  |> filter(fn: (r) => r.metric == "read")
  |> first()
  |> findRecord(fn: (key) => key._field == "value", idx: 0)

t2Start = allData
  |> filter(fn: (r) => r.testName == "EX2")
  |> filter(fn: (r) => r.metric == "read")
  |> first()
  |> findRecord(fn: (key) => key._field == "value", idx: 0)

diff = uint(v: t2Start._time) - uint(v: t1Start._time)

t1Data = allData
  |> filter(fn: (r) => r.testName == "EX1")

t2Data = allData
  |> filter(fn: (r) => r.testName == "EX2")
  |> map(fn: (r) => ({r with _time: time(v: uint(v: r._time) - diff)}))


unionedData = union(tables: [t1Data, t2Data])
  |> filter(fn: (r) => r.metric != "cleanup")
  |> yield(name: "unionedData")
