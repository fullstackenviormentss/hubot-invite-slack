# Description:
#   Send an invitation.
#
# Dependencies:
#   hubot-auth
#
# Configuration:
#   None
#
# Commands:
#   hubot invite [email]
#   hubot who invited [email]
#   hubot who was invited by [email]
#
# Author:
#   impleri

InviteApi = require "./invite"

module.exports = (robot) ->
  robot.inviteSlack = api = InviteApi robot

  robot.respond /invite\s+(.*)/i, (msg) ->
    unless robot.auth.hasRole msg.envelope.user, ["admin", "inviter"]
      return msg.reply "You must have the inviter role to send invitations."

    invitee = msg.match[1]
    sender = msg.envelope.user

    promise = api.send invitee, sender
    promise.then (success) ->
      reply = "Invitation sent to #{invitee} for you"
      reply = "I could not invite #{invitee} for you: #{api.error}" unless success
      msg.reply reply

    null

  robot.respond /who\s+invited\s+(.*)\??/i, (msg) ->
    unless robot.auth.hasRole msg.envelope.user, ["admin", "invite-admin", "inviter"]
      return msg.reply "You must have the inviter or invite-admin role to see who invited a user."

    invitee = msg.match[1]
    inviter = api.find invitee
    reply = "I don't know who invited #{invitee}"
    reply = "#{invitee} was invited by #{inviter}" if inviter?

    msg.reply reply
    null

  robot.respond /who\s+was\s+invited\s+by\s+(.*)\??/i, (msg) ->
    unless robot.auth.hasRole msg.envelope.user, ["admin", "invite-admin"]
      return msg.reply "You must have the invite-admin role to see what invitations were sent by a user."


    sender = msg.match[1]
    invited = api.findBySender sender
    reply = "I don't see anyone invited by #{sender}"
    reply = "#{sender} has invited: " + invited.join(", ") + "." if invited.length

    msg.reply reply
    null

  null
