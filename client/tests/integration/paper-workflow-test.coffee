`import Ember from 'ember'`
`import { test } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import setupMockServer from '../helpers/mock-server'`
`import { paperWithParticipant } from '../helpers/setups'`
`import Factory from '../helpers/factory'`
`import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';`

app = null
server = null

module 'Integration: Paper Workflow page',

  afterEach: ->
    server.restore()
    Ember.run(app, app.destroy)

  beforeEach: ->
    Factory.resetFactoryIds()
    app = startApp()
    server = setupMockServer()
    TestHelper.handleFindAll('discussion-topic', 1)

    taskPayload =
      task:
        id: 1
        title: "New Ad-Hoc Task"
        type: "Task"
        phase_id: 1
        paper_id: 1
        lite_paper_id: 1

    # let us see the manuscript manager
    server.respondWith 'GET', /\/api\/papers\/\d+\/manuscript_manager/, [
      204, {}, ""
    ]

    server.respondWith 'GET', "/api/papers/1", [
      200, {"Content-Type": "application/json"}, JSON.stringify(paperWithParticipant().toJSON())
    ]

    server.respondWith 'POST', "/api/tasks", [
      200, {"Content-Type": "application/json"}, JSON.stringify(taskPayload)
    ]

    server.respondWith 'DELETE', "/api/tasks/1", [
      200, {"Content-Type": "application/json"}, '{}'
    ]

test 'show delete confirmation overlay on deletion of a Task', (assert) ->
  visit '/papers/1/workflow'
  andThen ->
    $(".card .card-remove").show()
    click(".card .card-remove")
  andThen ->
    assert.equal(find('h1:contains("about to delete this card forever")').length, 1)
    assert.equal(find('h2:contains("Are you sure?")').length, 1)
    assert.equal(find('.overlay-x button:contains("cancel")').length, 1)
    assert.equal(find('.overlay-x button:contains("Yes, Delete this Card")').length, 1)

test 'click delete confirmation overlay cancel button', (assert) ->
  visit '/papers/1/workflow'
  andThen ->
    equal find(".card-content").length, 1
    $(".card .card-remove").show()
    click(".card .card-remove")
    click('.overlay-x button:contains("cancel")')
    assert.equal find(".card-content").length, 1

test 'click delete confirmation overlay submit button', (assert) ->
  visit '/papers/1/workflow'
  andThen ->
    assert.equal(find(".card-content").length, 1, "card exists")
    $(".card .card-remove").show()
    click(".card .card-remove")
    click('.overlay-x button:contains("Yes, Delete this Card")')
  andThen ->
    assert.equal(find(".card-content").length, 0, "card deleted")
    req = _.findWhere(server.requests, {method: "DELETE", url: "/api/tasks/1"})
    assert.equal(req.status, 200, "It sends DELETE request to the server")
