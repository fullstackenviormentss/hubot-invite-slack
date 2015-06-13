chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
rewire = require "rewire"
expect = chai.expect

describe "invite api", ->
  target = rewire "../src/invite"
  robot =
    brain:
      get: sinon.stub()
      set: sinon.spy()
      userForName: sinon.stub()

  beforeEach ->
    @robot = robot

    @updater = sinon.spy()
    @request =
      post: sinon.stub()
    @api = target @robot
    target.__set__
      "request": @request
      "updater": @updater

  it "sends and handles errors from Slack", ->
    promisePlaceholder = "returned-promise"
    errorMessage = "This is an error"
    invitee = "invitee@email.com"
    sender = "existing-user"
    response =
      ok: false
      error: errorMessage

    promiseChain = sinon.stub()
    promiseChain.returns promisePlaceholder

    @request.post.returns
      then: promiseChain

    returnedPromise = @api.send invitee, sender
    result = promiseChain.args[0][0] JSON.stringify response

    expect(returnedPromise).to.equal promisePlaceholder
    expect(@request.post).to.have.been.calledWith sinon.match.object
      .and(sinon.match.has("url", sinon.match.string))
      .and sinon.match.has "formData", sinon.match.object
    expect(promiseChain).to.have.been.calledWith sinon.match.func

    expect(result).to.be.false
    expect(@api.error).to.equal errorMessage

  it "sends successfully and saves new invite in brain", ->
    invitee = "invitee@email.com"
    sender = "existing-user"
    promisePlaceholder = "returned-promise"

    promiseChain = sinon.stub()
    promiseChain.returns promisePlaceholder

    @robot.brain.get.returns []
    @robot.brain.userForName.returns "user"
    @request.post.returns
      then: promiseChain

    returnedPromise = @api.send invitee, sender
    result = promiseChain.args[0][0] JSON.stringify {ok: true}

    expect(returnedPromise).to.equal promisePlaceholder
    expect(@request.post).to.have.been.calledWith sinon.match.object
      .and(sinon.match.has("url", sinon.match.string))
      .and sinon.match.has "formData", sinon.match.object
    expect(promiseChain).to.have.been.calledWith sinon.match.func

    expect(result).to.be.true
    expect(@robot.brain.get).to.have.been.calledWith sinon.match.string
    expect(@robot.brain.userForName).to.have.been.calledWith sender
    expect(@robot.brain.set).to.have.been.calledWith @robot.brain.get.args[0][0],
      sinon.match.array

    expect(@robot.brain.set.args[0][1][0]).to.have.property "email_address", invitee
    expect(@robot.brain.set.args[0][1][0]).to.have.property "sender", "user"

    expect(@updater).to.be.calledWith @robot

  it "finds invites by username", ->
    null

  it "finds invites by email", ->
    null

  it "finds invites by sender username", ->
    null

  it "finds invites by sender email", ->
    null
