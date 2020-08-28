local string = require "string"

local uri = ngx.var.uri
ngx.log(ngx.INFO, uri)
ngx.log(ngx.INFO, string.match(uri, "/ipfs/(%a+)/"))
local cid = string.match(uri, "/ipfs/(%w+)/")

if not ngx.shared.allowed:get(cid) then
    ngx.exit(410)
end
