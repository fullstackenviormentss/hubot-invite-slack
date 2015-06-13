# Actual API

request = require "request-promise"
config = require "./config"
filters = require "./filters"
updater = require "./update"

# Singleton instance
instance = null

class InviteApi
  constructor: (@robot) ->
    @error = null
    null

  send: (invitee, inviter) ->
    promise = request.post
      url: "https://#{config.team}.slack.com/api/users.admin.invite"
      formData:
        email: invitee
        set_active: true
        token: config.token

    promise.then (responseBody) =>
      body = JSON.parse responseBody

      unless body.ok
        @error = body.error
        return false

      # Save invitation
      invites = @robot.brain.get config.brainKey
      invites = invites or []
      invites.push
        time: new Date
        email_address: invitee
        id: null
        name: null
        sender: @robot.brain.userForName inviter or inviter
      @robot.brain.set config.brainKey, invites

      updater @robot

      true

  find: (invitee, msg) ->
    updater @robot

    key = "name"
    key = "email" if invitee.match /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i

    invites = @robot.brain.get config.brainKey
    theInvite = invites.find filters.inviteByField key, invitee

    theInvite?.sender.name

  findBySender: (inviter, msg) ->
    updater @robot

    key = "name"
    key = "email" if inviter.match /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i

    invites = @robot.brain.get config.brainKey
    sentInvites = invites.filter filters.senderByKey key, inviter
    invitedUsers = []
    invitedUsers = sentInvites.map filters.reduceInvite if sentInvites.length

    invitedUsers

module.exports = (robot) ->
  instance ?= new InviteApi robot
  instance
