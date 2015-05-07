`import DS from 'ember-data'`

a = DS.attr

CommentLook = DS.Model.extend

  paper: DS.belongsTo('paper')
  task: DS.belongsTo('task', polymorphic: true, inverse: 'commentLooks')
  comment: DS.belongsTo('comment', inverse: 'commentLook')
  user: DS.belongsTo('user')

  readAt: a('date')

`export default CommentLook`
