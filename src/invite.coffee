request = require "request-promise"
config = require "./config"
filters = require "./filters"
updater = require "./update"
require "array.prototype.find"

emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i

# Singleton instance
instance = null

class InviteApi
  constructor: (@robot) ->
    @error = null
    null

  send: (invitee, inviter) ->
    postPromise = request.post
      url: "https://#{config.team}.slack.com/api/users.admin.invite"
      form:
        token: config.token
        set_active: true
        email: invitee

    promise = postPromise.finally ->
      updater @robot

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
        sender: inviter
      @robot.brain.set config.brainKey, invites

      true

  find: (invitee) ->
    updater @robot

    key = "name"
    key = "email_address" if invitee.match emailRegex

    invites = @robot.brain.get config.brainKey
    theInvite = invites.find filters.inviteByField key, invitee

    theInvite?.sender.name

  findBySender: (inviter) ->
    updater @robot

    key = "name"
    key = "email_address" if inviter.match emailRegex

    invites = @robot.brain.get config.brainKey
    sentInvites = invites.filter filters.senderByField key, inviter
    invitedUsers = []
    invitedUsers = sentInvites.map filters.reduceInvite if sentInvites.length

    invitedUsers

module.exports = (robot) ->
  instance ?= new InviteApi robot
  instance
