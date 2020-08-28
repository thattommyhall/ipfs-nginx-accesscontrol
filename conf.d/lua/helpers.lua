local helpers = {}
local json = require "cjson.safe"

function helpers.apiclient(httpc, api_root, auth)
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
