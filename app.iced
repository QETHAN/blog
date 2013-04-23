express = require 'express'
path = require 'path'
MongoStore = (require 'connect-mongo')(express)
module.exports = app = express()


app.use express.static path.join __dirname, 'components'
app.use express.static path.join __dirname, 'public'

# moment = require 'moment'
# moment.lang 'zh-cn'
# app.locals.moment = moment
app.locals.version = (require './package.json').version
app.set 'view engine', 'jade'
app.set 'views', path.join __dirname, 'views'
app.use express.bodyParser()
app.use (req, res, next)->
  req.body[k] = v for k, v of req.query
  next()
app.use express.methodOverride()

app.use express.cookieParser()
app.use express.session
  key: 'ethan\'s blog'
  secret: 'ethan\'s blog'
  store: new MongoStore
     db: 'blog'
  maxAge: 365 * 24 * 60 * 60 * 1000

app.get '/', (req, res)->
  return res.render 'dashboard'

app.get '/signin', (req, res)->
	return res.render 'signin'

app.post '/signin', (req, res, next)->
	console.log '----->signin'
	next()

app.get '/signup', (req, res)->
	return res.render 'signup'

app.post '/signup', (req, res, next)->
	next()

app.get '*', (req, res, n)->
  n 404

messages = 
  '404': '找不到该项，该功能暂不可用或数据不存在'
  '500': '服务器错误'

app.use (err, req, res, n)->
  return res.send 500, err.message + '\n' if (req.get 'user-agent').match /curl/ 
  if err.constructor == Number
    res.statusCode = err
    return n new Error messages[String err]
  res.statusCode = 500 if res.statusCode==200
  n err
  
app.configure 'development', ->
  app.use (err, req, res, n)->
    res.render 'error', 
      message: err.stack
  
app.configure 'production', ->
  app.use (err, req, res, n)->
    console.error err.message
    res.render 'error', 
      message: err.message