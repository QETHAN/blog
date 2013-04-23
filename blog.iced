app = require './app'
http = require 'http'

process.env.APP_ADDRESS ?= "0.0.0.0"
process.env.APP_PORT ?= 3000

process.env.SYSNAME ?= 'ethan\'s blog'
process.env.ADMINIPS ?= '127.0.0.1'

appserver = http.createServer app
await appserver.listen (Number process.env.APP_PORT), process.env.APP_ADDRESS, defer err
throw next err if err
app.set 'server', appserver
console.log "APP正在 #{appserver.address().address}:#{appserver.address().port} 上运行"
console.log "配置环境: #{app.get 'env'}"
if 'development'==app.get 'env'
  console.warn "警告: 程序正在开发环境下运行"
# console.log "主数据库：#{db.main._dbconn.databaseName}"