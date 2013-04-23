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
  return res.render 'layout'
