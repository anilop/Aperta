`import Ember from 'ember'`

StyleguideRoute = Ember.Route.extend

  renderTemplate: (controller, model) ->
    @render('styleguide', {
      into: 'application',
      controller: 'styleguide'
    })

    # TODO: Render overlays manually below

    # @render('overlays/activity', {
    #   into: 'styleguide',
    #   outlet: "white-overlay",
    #   controller: 'application'
    # })

  setupController: (controller, model) ->
    upload = {
      id: 1
      file: {
        name: "Manuscript.docx"
        # preview:
      }
      error: "Errrrs"
      dataLoaded: 5000
      dataTotal: 10000
    }

    uploads = {
      id: 1
      title: 'Learn Ember.js'
      isCompleted: true
    }

    user = {
      id: 1
      fullName: "Charlotte Jones"
      firstName: "Charlotte"
      avatarUrl: "/images/profile-no-image.png"
      username: "charlotte"
      email: "charlotte.jones@example.com"
      siteAdmin: true
      affiliationIds: [
        2
      ]
    }

    user2 = {
      id: 2
      fullName: "Ruby Twosday"
      firstName: "Ruby"
      avatarUrl: "/images/profile-no-image.png"
      username: "ruby"
      email: "ruby.jones@example.com"
      siteAdmin: false
      affiliationIds: [
        2
      ]
    }

    newAuthor = {
      firstName: "Albert"
      middleInitial: "E"
      lastName: "Einstein"
      email: "al@lvh.me"
      title: 'Patent Clerk'
      department: "Somewhere"
      deceased: true
      errors: {
        'uno': 'oops'
      }
    }

    fullAuthor = {
      model: {
        firstName: "Albert"
        middleInitial: "E"
        lastName: "Einstein"
        fullName: "Albert Einstein"
        email: "al@lvh.me"
        title: 'Patent Clerk'
        department: "Somewhere"
        deceased: true
        errors: {
          'uno': 'oops'
        }
      }
    }

    flash = {
      messages: [
        {
          text: 'Just Lettin Ya Know'
        },
        {
          text: 'Whoa Nelly'
          type: 'error'
        },
        {
          text: 'Awww Ya'
          type: 'success'
        },
        {
          text: 'Be Aware'
          type: 'alert'
        }
      ]
    }

    paper = @store.createRecord("paper", {
      title: 'Long Paper Title of Amazingness'
      shortTitle: 'Short Paper Title'
    })

    paper2 = @store.find("paper", 1)

    taskIncomplete2 = @store.createRecord "task",
      title: "Ethics"

    phase1 = @store.createRecord 'phase',
      name: 'Submission Data'
      paper: paper

    phase2 = @store.createRecord 'phase',
      name: 'Phase 2'
      paper: paper

    taskIncomplete =
      title: "Ethics"

    taskComplete =
      title: "Add Author"
      completed: true

    supportedDownloadFormats = [
      {
        format: "docx",
        url: "https://tahi.example.com/export/docx",
        description: "This converts from docx to HTML"
      }
    ]

    fakeQuestion = Ember.Object.create
      ident: "foo"
      save: -> null
      additionalData: [{}]
      question: "Test Question"
      answer: true

    task = Ember.Object.create(
      title: "Styleguide Card",
      questions: [fakeQuestion]
    )

    arrayOfOptions = [
      { id: 1, text: 'Text 1'},
      { id: 2, text: 'Text 2'},
      { id: 3, text: 'Text 3'}
    ]

    cities = [
      {
        id: 1,
        text: "New York"
      },
      {
        id: 2,
        text: "Chicago"
      },
      {
        id: 3,
        text: "San Francisco"
      },
      {
        id: 4,
        text: "Dallas"
      },
      {
        id: 5,
        text: "Atlanta"
      }
    ]

    comment = @store.createRecord 'comment', {
      body: "test comment"
    }

    # Ember-data versions of Users
    user3 = @store.createRecord 'user', user
    user4 = @store.createRecord 'user', user2
    users = @store.find 'user'

    flow = @store.find 'flow', 1

    controller.set('arrayOfOptions', arrayOfOptions)
    controller.set('cities', cities)
    controller.set('comment', comment)
    controller.set('flash', flash)
    controller.set('flow', flow)
    controller.set('fullAuthor', fullAuthor)
    controller.set('newAuthor', newAuthor)
    controller.set('paper', paper)
    controller.set('paper2', paper2)
    controller.set('phases', [phase1, phase2])
    controller.set('supportedDownloadFormats', supportedDownloadFormats)
    controller.set('task', task)
    controller.set('taskComplete', taskComplete)
    controller.set('taskIncomplete', taskIncomplete)
    controller.set('upload', upload)
    controller.set('user', user)
    controller.set('user2', user2)
    controller.set('user3', user3)
    controller.set('user4', user4)
    controller.set('users', users)

`export default StyleguideRoute`
