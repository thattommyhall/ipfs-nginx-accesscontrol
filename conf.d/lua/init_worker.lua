local helpers = require "helpers"

local function refresh_acl()
    ngx.log(ngx.INFO, "REFRESHING")
    local client = helpers.apiclient("http://app:5000")
    local acl = client.get("/acl")
    if client and acl then
        helpers.update_acl(acl)
    end
end

ngx.timer.at(0, refresh_acl)
ngx.timer.every(10, refresh_acl)
