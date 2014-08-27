createPaperWithOneTask = (taskType, taskAttrs) ->
  ef = ETahi.Factory
  journal = ef.createRecord('Journal', id: 1)
  paper = ef.createRecord('Paper', journal_id: journal.id)
  litePaper = ef.createLitePaper(paper)
  phase = ef.createPhase(paper)
  task = ef.createTask(taskType, paper, phase, taskAttrs)

  [paper, task, journal, litePaper, phase]

module 'Integration: Super AdHoc Card',
  teardown: -> ETahi.reset()
  setup: ->
    setupApp integration: true
    ef = ETahi.Factory
    records = createPaperWithOneTask('Task'
      id: 1
      title: "Super Ad-Hoc"
    )
    ETahi.Test = {}
    ETahi.Test.currentPaper = records[0]

    paperPayload = ef.createPayload('paper')
    paperPayload.addRecords(records.concat([fakeUser]))
    paperResponse = paperPayload.toJSON()

    server.respondWith 'GET', /\/papers\/\d+\/manuscript_manager/, [
      200
      'Tahi-Authorization-Check': 'true'
      JSON.stringify {}
    ]

    server.respondWith 'GET', "/papers/#{ETahi.Test.currentPaper.id}", [
      200, {"Content-Type": "application/json"}, JSON.stringify paperResponse
    ]

    server.respondWith 'PUT', /\/tasks\/\d+/, [
      204, {"Content-Type": "application/json"}, JSON.stringify {}
    ]

test "Adding a text block to an AdHoc Task", ->
  visit "/papers/#{ETahi.Test.currentPaper.id}/manage"
  .then -> ok exists find '.card-content:contains("Super Ad-Hoc")'

  click '.card-content:contains("Super Ad-Hoc")'
  click '.adhoc-content-toolbar .glyphicon-plus'
  click '.adhoc-content-toolbar .adhoc-toolbar-item--text'
  andThen ->
    ok exists find '.inline-edit-form div[contenteditable]'
    ok exists find '.button--disabled:contains("Save")'
    Em.$('.inline-edit-form div[contenteditable]')
    .html("New contenteditable, yahoo!")
    .trigger('keyup')
    click '.task-body .inline-edit-form .button--green:contains("Save")'
  andThen ->
    ok Em.$.trim(find('.inline-edit').text()).indexOf('yahoo') isnt -1
    click '.inline-edit .glyphicon-trash'
  andThen ->
    ok Em.$.trim(find('.inline-edit').text()).indexOf('Are you sure?') isnt -1
    click '.inline-edit .delete-button'
  andThen ->
    ok Em.$.trim(find('.inline-edit').text()).indexOf('yahoo') is -1
    click '.overlay-close-button:first'

test "Adding and removing a checkbox item to an AdHoc Task", ->
  visit "/papers/#{ETahi.Test.currentPaper.id}/manage"

  click '.card-content:contains("Super Ad-Hoc")'
  click '.adhoc-content-toolbar .glyphicon-plus'
  click '.adhoc-content-toolbar .adhoc-toolbar-item--list'
  andThen ->
    ok exists find '.inline-edit-form input[type=checkbox]:disabled'
    ok exists find '.inline-edit-form label[contenteditable]'
    ok exists find '.button--disabled:contains("Save")'
    Em.$('.inline-edit-form label[contenteditable]')
    .html("Here is a checkbox list item")
    .trigger('keyup')
    click '.task-body .inline-edit-form .button--green:contains("Save")'
  andThen ->
    ok Em.$.trim(find('.inline-edit').text()).indexOf('checkbox list item') isnt -1
    ok exists find '.inline-edit-form input[type=checkbox]'
    click '.inline-edit .glyphicon-trash'
  andThen ->
    ok Em.$.trim(find('.inline-edit').text()).indexOf('checkbox list item') is -1
    click '.overlay-close-button:first'
