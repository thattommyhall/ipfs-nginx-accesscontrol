local helpers = require "helpers"

local client = helpers.apiclient("http://app:5000")

local acl = client.get("/acl")

helpers.flush_acl()
helpers.update_acl(acl)
ngx.header["Content-Type"] = "application/json"
ngx.say("OK")
