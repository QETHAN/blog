express = require 'express'
path = require 'path'
MongoStore = (require 'connect-mongo')(express)
db = require './db/index'

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
  res.locals.user = req.session.user || null
  return res.render 'dashboard'

app.get '/signin', (req, res, next)->
  unless req.session.user
    res.locals.referer = req.get('Referer') || '/'
    return res.render 'signin'
  res.redirect 'back'

app.post '/signin', (req, res, next)->
  await db.users.findOne ('email': req.body.email,'password': req.body.password), defer e, item
  return next e if e 
  return next new Error '用户名或密码错误!' unless item
  req.session.user = item.email 
  res.locals.user = req.session.user

  if req.body.remember is 'remember-me'
	  res.cookie('user',item.email) 

  return res.redirect req.body.referer

app.get '/logout', (req, res, next)->
	req.session.user = undefined
	return res.redirect '/'

app.get '/signup', (req, res)->
	return res.render 'signup'

app.post '/signup', (req, res, next)->
	await db.users.findOne 'email':req.body.email, defer e, item
	return next e if e
	return next new Error '用户邮箱已经注册!' if item?

	if req.body.password != req.body.repassword
		return next new Error '两次密码输入不一致!'

	await db.users.insert ('email':req.body.email, 'password':req.body.password), defer e, result
	return next e if e
	req.session.user = result.email if result?

	return res.redirect '/'

app.get '/about', (req, res, next)->
  sabout = md.toHTML '> 在痛苦和挣扎中奔跑在通往美好的大路上' 
  res.locals.sabout = sabout
  res.locals.user = req.session.user
  return res.render 'about'

app.get '/write', (req, res, next)->
  return res.render 'write'

app.post '/write', (req, res, next)->

  res.locals.article = 
    title: req.body.title.replace(/<[^>].*?>?/g,""),
    data: req.body.data
  res.locals.user = req.session.user 
  res.render 'article'

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
    res.locals.user = req.session.user || null
    res.render 'error', 
      message: err.stack
  
app.configure 'production', ->
  app.use (err, req, res, n)->
    console.error err.message
    res.locals.user = req.session.user || null
    res.render 'error', 
      message: err.message