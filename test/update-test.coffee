chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect

UpdateClass = require "../src/update"

robot =
  brain:
    data: {}
    get: sinon.stub()
    set: sinon.stub()
    users: sinon.stub()

users = [
  {
    id: 20
    name: "existing-user"
    email_address: "existing@example.org"
  }
  {
    id: 40
    name: "found-user"
    email_address: "found@example.org"
  }
  {
    id: 50
    name: "new-user"
    email_address: "newb@example.com"
  }
]

describe "updater", ->
  @updater = null

  beforeEach ->
    @robot = robot

  it "constructs", ->
    @robot.brain.get.returns []

    @updater = UpdateClass @robot
    expect(@robot.brain.get).to.have.been.calledWith sinon.match.string
    expect(@robot.brain.set).to.have.been.calledWith sinon.match.string, []


  it "runs for every existing entry", ->
    oldInvite = "old-invite"
    newInvite = "new-invite"
    updateInvite = sinon.stub @updater, "invitation"
    updateInvite.returns newInvite

    response = @updater.run [oldInvite]
    expect(updateInvite).to.have.been.calledWith oldInvite
    expect(response).to.have.members [newInvite]
    updateInvite.restore()

  it "updates an invitation", ->
    oldSender = "old-sender"
    newSender = "new-sender"
    oldInvite =
      name: "old-invite"
      time: "old"
      sender: oldSender
    newInvite =
      name: "new-invite"
      time: "new"
      sender: newSender

    updateUser = sinon.stub @updater, "user"
    updateUser.onFirstCall().returns newInvite
    updateUser.onSecondCall().returns newSender

    response = @updater.invitation oldInvite

    expect(updateUser).to.have.been.calledWith oldInvite
    expect(updateUser).to.have.been.calledWith oldSender
    expect(response).to.deep.equal newInvite
    updateUser.restore()

  it "does not update user if missing name, email, and id", ->
    testUser =
      blah: false

    response = @updater.user testUser
    expect(response).to.equal testUser

  it "updates user by name", ->
    expectedUser =
      id: 30
      name: "username"
      email_address: "differnt@example.com"

    users.push expectedUser
    @robot.brain.users.returns users

    testUser =
      name: "username"
      email_address: null
      id: null

    response = @updater.user testUser
    expect(response).to.deep.equal expectedUser

  it "updates user by string", ->
    expectedUser =
      id: 70
      name: "another-user"
      email_address: "another@example.org"

    users.push expectedUser
    @robot.brain.users.returns users

    testUser = "another-user"

    response = @updater.user testUser
    expect(response).to.deep.equal expectedUser

  it "updates user by email", ->
    expectedUser =
      id: 60
      name: "different-person"
      email_address: "user@example.com"

    users.push expectedUser
    @robot.brain.users.returns users

    testUser =
      name: "username"
      email_address: "user@example.com"
      id: null

    response = @updater.user testUser
    expect(response).to.deep.equal expectedUser

  it "updates user by id", ->
    expectedUser =
      id: 10
      name: "invited-person"
      email_address: "person@example.com"

    users.push expectedUser
    @robot.brain.users.returns users

    testUser =
      name: "username"
      email_address: "user@example.com"
      id: 10

    response = @updater.user testUser
    expect(response).to.deep.equal expectedUser
