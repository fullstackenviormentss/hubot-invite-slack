chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect

InviteApiClass = require "../src/invite"
target = require "../src/listeners"

user =
  name: "user"
  id: "U123"
robot =
  respond: sinon.spy()
  hear: sinon.spy()
  auth:
    hasRole: sinon.stub()
  brain:
    data: {}
    get: sinon.stub()
    set: sinon.stub()
msg =
  send: sinon.spy()
  reply: sinon.spy()
  envelope:
    user: user
  message:
    user: user

describe "hubot listeners", ->
  beforeEach ->
    @user = user
    @robot = robot
    @data = @robot.brain.data
    @msg = msg

  InviteApi = InviteApiClass robot
  target robot

  it "registers an invite listener", ->
    expect(@robot.respond).to.have.been.calledWith /invite\s+(.*)/i,
      sinon.match.func

  it "invite listener checks for auth", ->
    @robot.auth.hasRole.returns false
    @robot.respond.args[0][1](@msg)
    expect(@robot.auth.hasRole).to.have.been.calledWith @user, sinon.match.array
    expect(@robot.auth.hasRole.args[0][1]).to.include.members ["inviter"]
    expect(@msg.reply).to.have.been.calledWithMatch /^.*must have.*role.*$/i

  it "invite listener responds after promised response", ->
    sinon.stub InviteApi, "send"
    promise =
      then: sinon.stub()
    InviteApi.send.returns promise
    @robot.auth.hasRole.returns true
    InviteApi.error = "error-msg"

    invitee = "send-to"
    @msg.match = [0, invitee]
    @robot.respond.args[0][1](@msg)
    expect(InviteApi.send).to.have.been.calledWith invitee, @user
    expect(promise.then).to.have.been.calledWith sinon.match.func

    promise.then.args[0][0](false)
    expect(@msg.reply).to.have.been.calledWithMatch /^.*could not invite.*$/i

    promise.then.args[0][0](true)
    expect(@msg.reply).to.have.been.calledWithMatch /^Invitation sent.*$/i
    InviteApi.send.restore()

  # Invited command
  it "registers an invited listener", ->
    expect(@robot.respond).to.have.been.calledWith /who\s+invited\s+(.*)\??/i,
      sinon.match.func

  it "invited listener checks for auth", ->
    @robot.auth.hasRole.returns false
    @robot.respond.args[1][1](@msg)
    expect(@robot.auth.hasRole).to.have.been.calledWith @user, sinon.match.array
    expect(@robot.auth.hasRole.args[2][1]).to.include.members ["invite-admin", "inviter"]
    expect(@msg.reply).to.have.been.calledWithMatch /^.*must have.*role.*$/i

  it "invited listener responds negatively if invite not found", ->
    sinon.stub InviteApi, "find"
    InviteApi.find.returns null
    @robot.auth.hasRole.returns true

    sender = "inviter-name"
    @msg.match = [0, sender]
    @robot.respond.args[1][1](@msg)

    expect(InviteApi.find).to.have.been.calledWith sender
    expect(@msg.reply).to.have.been.calledWithMatch /^.*don't know.*invited.*$/i
    InviteApi.find.restore()

  it "invited listener responds positively if invite is found", ->
    sinon.stub InviteApi, "find"
    InviteApi.find.returns "sender-name"
    @robot.auth.hasRole.returns true

    sender = "inviter-name"
    @msg.match = [0, sender]
    @robot.respond.args[1][1](@msg)

    expect(InviteApi.find).to.have.been.calledWith sender
    expect(@msg.reply).to.have.been.calledWithMatch /^.*was invited by.*$/i
    InviteApi.find.restore()

  # Invited By command
  it "registers an invited by listener", ->
    expect(@robot.respond).to.have.been.calledWith /who\s+was\s+invited\s+by\s+(.*)\??/i, sinon.match.func

  it "invited by listener checks for auth", ->
    @robot.auth.hasRole.returns false
    @robot.respond.args[2][1](@msg)
    expect(@robot.auth.hasRole).to.have.been.calledWith @user, sinon.match.array
    expect(@robot.auth.hasRole.args[5][1]).to.include.members ["invite-admin"]
    expect(@robot.auth.hasRole.args[5][1]).to.not.include.members ["inviter"]
    expect(@msg.reply).to.have.been.calledWithMatch /^.*must have.*role.*$/i

  it "invited by listener responds negatively if no invites found", ->
    sinon.stub InviteApi, "findBySender"
    InviteApi.findBySender.returns []
    @robot.auth.hasRole.returns true

    sender = "inviter-name"
    @msg.match = [0, sender]
    @robot.respond.args[2][1](@msg)

    expect(InviteApi.findBySender).to.have.been.calledWith sender
    expect(@msg.reply).to.have.been.calledWithMatch /^.*don't see.*invited by.*$/i
    InviteApi.findBySender.restore()

  it "invited by listener responds positively if one or more invites found", ->
    sinon.stub InviteApi, "findBySender"
    InviteApi.findBySender.returns ['someone', 'another-person', 'whynot@example.com']
    @robot.auth.hasRole.returns true

    sender = "inviter-name"
    @msg.match = [0, sender]
    @robot.respond.args[2][1](@msg)

    expect(InviteApi.findBySender).to.have.been.calledWith sender
    expect(@msg.reply).to.have.been.calledWithMatch /^.*has invited:.*$/i
    InviteApi.findBySender.restore()

