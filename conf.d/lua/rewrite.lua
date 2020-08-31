local string = require "string"
local helpers = require "helpers"

local cid, path = helpers.get_cid_path()

ngx.log(ngx.INFO, cid)
ngx.log(ngx.INFO, path)

local denied_code = helpers.denied(cid, path)
if denied_code then
    ngx.exit(denied_code)
end
