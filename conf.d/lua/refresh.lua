local http = require "resty.http"
local json = require "cjson.safe"
local helpers = require "helpers"

local httpc = http.new()

local client = helpers.apiclient(httpc, "http://app")

local allowed = client.get("/allowed")
local denied = client.get("/denied")

for cid, _ in pairs(allowed) do
    ngx.shared.allowed:set(cid, true, 180)
end

local result = {}
result.allowed = {}
for _, cid in ipairs(ngx.shared.allowed:get_keys()) do
    result["allowed"][cid] = true
end
ngx.log(ngx.INFO, "HELLO")

result.denied = denied

ngx.header["Content-Type"] = "application/json"
ngx.say(json.encode(result))
