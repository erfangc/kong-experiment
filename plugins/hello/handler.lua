local HelloWorldHandler = {
  VERSION = "1.0.0",
}

function HelloWorldHandler:access(conf)
  ngx.log(ngx.ERR, "Hello, " .. conf.who .. " ........ I am a far bar bar fooo foo !")
end

HelloWorldHandler.PRIORITY = 1000

return HelloWorldHandler
