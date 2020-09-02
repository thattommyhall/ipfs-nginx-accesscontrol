local helpers = {}
local json = require "cjson.safe"
local resty_sha256 = require "resty.sha256"
local str = require "resty.string"

function helpers.sha256(s)
    local hash_lookup = ngx.shared.sha256:get(s)
    if hash_lookup then
        ngx.log(ngx.INFO, "CACHED")
        return hash_lookup, nil
    end

    local hash, err = resty_sha256:new()
    if not hash then
        return nil, err
    end

    hash:update(s)
    local digest = hash:final()
    local hexdigest = str.to_hex(digest)
    if digest and hexdigest then
        ngx.shared.sha256:set(s, hexdigest)
        ngx.log(ngx.INFO, "CALCULATED!")
        return hexdigest
    end
end

function helpers.get_cid_path()
    local uri = ngx.var.uri
    local cid, path = string.match(uri, "/ipfs/(%w+)(/?.*)")
    return cid, path
end

function helpers.istable(t)
    return type(t) == "table"
end

function helpers.isnumber(n)
    return type(n) == "number"
end

function helpers.flush_acl()
    ngx.shared.allowed:flush_all()
    ngx.shared.denied:flush_all()
end

function helpers.update_acl(acl)
    if acl.allowed then
        for cid, _ in pairs(acl.allowed) do
            ngx.shared.allowed:set(cid, true)
        end
    end

    if acl.denied then
        for cid, denyspec in pairs(acl.denied) do
            if helpers.istable(denyspec) then
                for uri, returncode in pairs(denyspec) do
                    ngx.log(ngx.INFO, uri .. returncode)
                    ngx.shared.denied:set(cid .. uri, returncode)
                end
            elseif helpers.isnumber(denyspec) then
                local returncode = denyspec
                ngx.shared.denied:set(cid, returncode)
            end
        end
    end
end

function helpers.denied(cid, path)
    local cid_lookup = ngx.shared.denied:get(cid)
    if cid_lookup then
        return cid_lookup
    end
    if cid and path then
        local cidpath_lookup = ngx.shared.denied:get(cid .. path)
        if cidpath_lookup then
            return cidpath_lookup
        end
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
