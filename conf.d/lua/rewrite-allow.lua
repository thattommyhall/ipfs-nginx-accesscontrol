local string = require "string"
local helpers = require "helpers"

local uri = ngx.var.uri
ngx.log(ngx.INFO, uri)
ngx.log(ngx.INFO, string.match(uri, "/ipfs/(%a+)/"))
local cid = string.match(uri, "/ipfs/(%w+)/")

if not helpers.allowed(cid) then
    ngx.exit(410)
end

local denied_code = helpers.denied(cid, path)
if denied_code then
    ngx.exit(denied_code)
end
