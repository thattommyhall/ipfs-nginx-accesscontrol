local ngx = ngx
local json = require "cjson.safe"
local http = require "resty.http"
local helpers = require "helpers"
local httpc = http.new()

local result = {}
result["test"] = "hello"

ngx.say(json.encode(result))
