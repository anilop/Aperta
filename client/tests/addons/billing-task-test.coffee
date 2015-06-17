`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import { paperWithTask, addUserAsParticipant } from '../helpers/setups'`
`import setupMockServer from '../helpers/mock-server'`
`import Factory from '../helpers/factory'`
`import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';`

app = null
server = null
fakeUser = null
currentPaper = null

module 'Integration: Billing',
  teardown: ->
    server.restore()
    Ember.run(app, app.destroy)
  setup: ->
    app = startApp()
    server = setupMockServer()
    fakeUser = window.currentUserData.user
    TestHelper.handleFindAll('discussion-topic', 1)

    billingTaskId = 94139

    records = paperWithTask('BillingTask'
      id: billingTaskId
      role: "author"
    )

    [currentPaper, billingTask, journal, phase] = records

    paperPayload = Factory.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()
    paperResponse.participations = [addUserAsParticipant(billingTask, fakeUser)]

    taskPayload = Factory.createPayload('task')
    taskPayload.addRecords([billingTask, fakeUser])
    billingTaskResponse = taskPayload.toJSON()

    collaborators = [
      id: "35"
      full_name: "Aaron Baker"
      info: "testroles2, collaborator"
    ]

    server.respondWith 'GET', "/api/papers/#{currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]
    server.respondWith 'GET', "/api/tasks/#{billingTaskId}", [
      200, {"Content-Type": "application/json"}, JSON.stringify billingTaskResponse
    ]
    server.respondWith 'PUT', /\/api\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]
    server.respondWith 'GET', /\/api\/filtered_users\/users\/\d+/, [
      200, {"Content-Type": "application/json"}, JSON.stringify []
    ]

test 'Viewing card', ->
  visit "/papers/#{currentPaper.id}/edit"
  click ':contains(Billing)'
  .then ->
    equal find('.overlay-main-work h1').text().trim(), 'Publication Fees'
  click '.select2-choice'
  .then ->
    ok Ember.$('.select2-result').length > 0
