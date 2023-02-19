local http = require "socket.http"
local ltn12 = require "ltn12"
local cjson = require "cjson"

local AuthorizationHandler = {
  PRIORITY = 1000,
  VERSION = "1.0.0",
}

function AuthorizationHandler:access(conf)
  -- local user_id = ngx.var.http_authorization
  local user_id = "chen"
  if not user_id then
    ngx.log(ngx.ERR, "Missing Authorization header")
    return kong.response.exit(401, { message = "Unauthorized" })
  end

  local url = ngx.var.uri
  local method = ngx.req.get_method()

  local request_body = cjson.encode({})

  local request_headers = {
    ["Host"] = conf.authorization_server_host,
    ["X-Forwarded-UserId"] = user_id,
    ["X-Forwarded-URL"] = url,
    ["X-Forwarded-Method"] = method,
    ["Content-Type"] = "application/json",
    ["Content-Length"] = tostring(#request_body),
  }

  local response_body = {}
  local _, response_status, response_headers = http.request{
    url = conf.authorization_server_url .. "/api/v2/authorizations",
    method = "POST",
    headers = request_headers,
    source = ltn12.source.string(request_body),
    sink = ltn12.sink.table(response_body),
  }
  
  ngx.log(ngx.ERR, response_status)
  if response_status == 401 then
    ngx.log(ngx.ERR, "Authorization failed: ", table.concat(response_body))
    return kong.response.exit(401, { message = "Unauthorized" })
  end

  if response_status >= 400 then
    ngx.log(ngx.ERR, "Authorization request failed: ", table.concat(response_body))
    return kong.response.exit(500, { message = "Internal Server Error" })
  end
end

function AuthorizationHandler:init_worker()
  kong.log.debug("Authorization plugin initialized")
end

return AuthorizationHandler
