local helpers = {}
local json = require "cjson.safe"

function helpers.get_cid_path()
    local uri = ngx.var.uri
    local _, _, cid, path = string.find(uri, "/ipfs/(%w+)(/.*)$")
    return cid, path
end

function helpers.istable(t)
    return type(t) == "table"
end

function helpers.isnumber(n)
    return type(n) == "number"
end

function helpers.denied(cid, path)
    local cid_lookup = ngx.shared.denied:get(cid)
    if cid_lookup then
        return cid_lookup
    end
    local cidpath_lookup = ngx.shared.denied:get(cid .. path)
    if cidpath_lookup then
        return cidpath_lookup
    end
end

function helpers.allowed(cid)
    return ngx.shared.allowed:get(cid)
end

function helpers.apiclient(httpc, api_root)
    local client = {}

    function client.get(path, params)
        local full_url = api_root .. path

        local request_params = {
            method = "GET",
            query = params
        }

        local res, err = httpc:request_uri(full_url, request_params)
        if res then
            local body = res.body
            local table = json.decode(body)
            if table then -- It was JSON
                return table
            else
                return body
            end
        else
            return res, err
        end
    end

    return client
end

return helpers
