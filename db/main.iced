module.exports = main = (require 'mongoskin').db "mongodb://localhost/blog", (safe: true)

main.bind 'users'