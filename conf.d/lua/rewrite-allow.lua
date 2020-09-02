local helpers = require "helpers"

local cid, path = helpers.get_cid_path()

if not helpers.allowed(cid) then
    ngx.exit(410)
end

local denied_code = helpers.denied(cid, path)
if denied_code then
    ngx.exit(denied_code)
end
