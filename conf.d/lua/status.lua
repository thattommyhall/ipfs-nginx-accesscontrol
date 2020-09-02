local ngx = ngx
local json = require "cjson.safe"

local result = {}

result.allowed = {}
for _, cid in ipairs(ngx.shared.allowed:get_keys()) do
    result["allowed"][cid] = true
end
ngx.log(ngx.INFO, "HELLO")

result.denied = {}
for _, blocked in ipairs(ngx.shared.denied:get_keys()) do
    result["denied"][blocked] = ngx.shared.denied:get(blocked)
end

ngx.header["Content-Type"] = "application/json"
ngx.say(json.encode(result))
