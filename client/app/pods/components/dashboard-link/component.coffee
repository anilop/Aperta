`import Ember from 'ember'`

DashboardLinkComponent = Ember.Component.extend

  unreadCommentsCount: (->
    @get('model.commentLooks.length')
  ).property('model.commentLooks.@each')

  refreshTooltips: ->
    Ember.run.scheduleOnce 'afterRender', @, =>
      if @$()
        @$('.link-tooltip').tooltip('destroy').tooltip({placement: 'bottom'})

  setupTooltips: (->
    @addObserver('model.unreadCommentsCount', @, @refreshTooltips)
    @refreshTooltips()
  ).on('didInsertElement')

  teardownTooltips: (->
    @removeObserver('model.unreadCommentsCount', @, @refreshTooltips)
  ).on('willDestroyElement')

  badgeTitle: (->
    "#{@get('unreadCommentsCount')} new posts"
  ).property('unreadCommentsCount')

`export default DashboardLinkComponent`
