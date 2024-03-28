"https://weather-proxy.freecodecamp.rocks/api/current?lat=50.93414&lon=6.93147"
| open-http(accept="application/json")
| as-lines
| decode-json
| encode-yaml(prettyprinting="True")
| print
;