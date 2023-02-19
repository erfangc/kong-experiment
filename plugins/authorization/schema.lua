local typedefs = require "kong.db.schema.typedefs"


return {
  name = "authorization",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { authorization_server_url = { type = "string", required = true }, },
    }, }, },
  },
}
