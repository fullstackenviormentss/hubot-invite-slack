# Update user mappings

request = require "request-promise"
config = require "./config"
filters = require "./filters"

class InviteUpdate
  constructor: (@robot) ->
    invites = @robot.brain.get config.brainKey
    newInvites = []
    newInvites.push @invitation invite for invite of invites
    @robot.brain.set config.brainKey, newInvites
    null

  invitation: (invite) ->
    newInvite = @user invite
    newInvite.time = invite.time
    newInvite.sender = @user invite.sender
    newInvite

  user: (user) ->
    user = {name: user} if user typeof "string"

    field = false
    field = "name" if user.name
    field = "email_address" if user.email
    field = "id" if user.id

    return user unless field

    realUser = @robot.brain.users().find filters.userByField field, user[field]
    user = realUser if realUser

    user

module.exports = (robot) ->
  new InviteUpdate robot
