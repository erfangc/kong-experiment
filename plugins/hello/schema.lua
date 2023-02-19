local typedefs = require "kong.db.schema.typedefs"

return {
  name = "hello",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { who = { type = "string" }, },
    }, }, },
  },
}
