local helpers = require "helpers"

local cid, path = helpers.get_cid_path()

local denied_code = helpers.denied(cid, path)
if denied_code then
    ngx.exit(denied_code)
end
