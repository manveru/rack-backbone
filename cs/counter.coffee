p = -> window.console?.debug?(arguments ...)

Backbone.sync = Rubyists.BackboneWebSocketSync

class User extends Backbone.Model
  url: 'User'

class Users extends Backbone.Collection
  url: 'Users'
  model: User

class UserList extends Backbone.View
  tagName: 'ul'
  className: 'user-list'
  events: {}

  template: _.template("Users:")

  initialize: () ->
    _.bindAll(this, 'addOne', 'addAll', 'render')

    @users = @options.users
    @users.bind('reset', @addAll)
    @users.bind('change', @addAll)

    @users.bind('save', -> p('save'))
    @users.bind('add', -> p('add'))
    @users.bind('create', -> p('create'))

    @users.fetch()

  addAll: ->
    $(@el).html('')
    @users.each(@addOne)

  addOne: (user) ->
    view = new UserRow(user: user)
    $(@el).append(view.render().el)

  render: ->
    $(@el).html(@template(users: @users))
    this

class UserRow extends Backbone.View
  tagName: "li"
  className: "user-row"
  events: {
    'click': 'hit'
  }

  template: _.template('name: <%- name %>, hits: <%- hits %>')

  initialize: () ->
    _.bindAll(this, 'render')
    @user = @options.user
    @user.bind('change', @render)

  render: ->
    $(@el).html(@template(name: @user.get('name'), hits: @user.get('hits')))
    this

  hit: ->
    @user.save(hits: @user.get('hits') + 1)

class Socket extends Rubyists.Socket
  onopen: ->
    list = new UserList(users: new Users)
    $('#counter').html(list.render().el)

$ ->
  Rubyists.syncSocket = new Socket(server: 'ws://localhost:33331')
