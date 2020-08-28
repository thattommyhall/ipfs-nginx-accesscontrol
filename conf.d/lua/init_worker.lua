local ngx = ngx
local http = require "resty.http"
local helpers = require "helpers"

local function refresh(httpc, hostname)
end

local function refresh_all()
end

-- ngx.timer.at(0, refresh_all)
ngx.timer.every(15, refresh_all)
