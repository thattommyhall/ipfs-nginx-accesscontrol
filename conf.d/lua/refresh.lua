local http = require "resty.http"
local json = require "cjson.safe"
local helpers = require "helpers"
local istable = helpers.istable
local isnumber = helpers.isnumber
local httpc = http.new()

local client = helpers.apiclient(httpc, "http://app")

local allowed = client.get("/allowed")
local denied = client.get("/denied")

for cid, _ in pairs(allowed) do
    ngx.shared.allowed:set(cid, true)
end

for cid, denyspec in pairs(denied) do
    if istable(denyspec) then
        for uri, returncode in pairs(denyspec) do
            ngx.log(ngx.INFO, uri .. returncode)
            ngx.shared.denied:set(cid .. uri, returncode)
        end
    elseif isnumber(denyspec) then
        local returncode = denyspec
        ngx.shared.denied:set(cid, returncode)
    end
end

-- onwards would usually be in /status
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
