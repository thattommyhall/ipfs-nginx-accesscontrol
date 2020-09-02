local helpers = require "helpers"

local cid, path = helpers.get_cid_path()

if helpers.allowed(cid) then
    return
end

local denied_code = helpers.denied(cid, path)
if denied_code then
    ngx.exit(denied_code)
end

if cid then
    ngx.log(ngx.INFO, "updating " .. cid)
    local client = helpers.apiclient("http://app:5000")
    local acl_update = client.get("/check_cid/" .. cid)
    helpers.update_acl(acl_update)
end

if not helpers.allowed(cid) then
    ngx.exit(410)
end
