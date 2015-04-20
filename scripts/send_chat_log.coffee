# Description:
#   Toggle configuration to send user's chat data to specified server
#   To use this function, user need server for logging.
#   Server can get data through TCP socket.
# 
# Commands:
#   zerobot send_chat_log on <host:port>
#   zerobot send_chat_log off
#
# Example:
#   zerobot send_chat_log on example.com:3000

net = require 'net'

module.exports = (robot) ->
  robot.respond /send_chat_log on (.*)/i, (res) ->
    user = res.envelope.user.id
    [host, port] = res.match[1].split ':'
    if not port?
      res.send 'port is missing'
      return
    if robot.socketFor is undefined
      robot.socketFor = []
    robot.socketFor[user] = net.createConnection port, host, () ->
      res.send 'connected to server'
    robot.socketFor[user].on 'error', () ->
      res.send 'server is off'
      robot.socketFor[user].end()
      delete robot.socketFor[user]

  robot.respond /send_chat_log off/i, (res) ->
    user = res.envelope.user.id
    if robot.socketFor? and robot.socketFor[user]?
      robot.socketFor[user].end()
      delete robot.socketFor[user]

  robot.hear /.*/i, (res) ->
    user = res.envelope.user.id
    if robot.socketFor? and robot.socketFor[user]?
      # res.send 'send_log content:', res.envelope.message.text # for debugging
      robot.socketFor[user].write res.envelope.message.text
