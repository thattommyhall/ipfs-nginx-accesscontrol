local http = require "resty.http"
local helpers = require "helpers"
local httpc = http.new()

local client = helpers.apiclient(httpc, "http://app")

local acl = client.get("/acl")

helpers.flush_acl()
-- helpers.update_acl(acl)
ngx.header["Content-Type"] = "application/json"
ngx.say("OK")
