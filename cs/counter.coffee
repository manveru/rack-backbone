p = -> window.console?.debug?(arguments ...)

Backbone.sync = Rubyists.BackboneWebSocketSync

class User extends Backbone.Model
  url: 'User'

class Users extends Backbone.Collection
  url: 'Users'
  model: User

class UserList extends Backbone.View
  tagName: 'table'
  className: 'user-list'
  events: {}

  template: _.template("""
    <thead>
      <tr>
        <th>Name</th>
        <th>Hits</th>
        <th>Delete</th>
      </tr>
    </thead>
    """)

  initialize: () ->
    _.bindAll(this, 'addOne', 'addAll', 'render')

    @users = @options.users
    @users.bind('reset', @addAll)
    @users.bind('change', @addAll)

    @users.bind('save', -> p('save'))
    @users.bind('destroy', @addAll)
    @users.bind('add', -> p('add'))
    @users.bind('create', -> p('create'))

    @users.fetch()

  addAll: ->
    p 'addAll'
    $(@el).html('')
    @users.each(@addOne)

  addOne: (user) ->
    view = new UserRow(user: user)
    $(@el).append(view.render().el)

  render: ->
    $(@el).html(@template(users: @users))
    this

class UserRow extends Backbone.View
  tagName: "tr"
  className: "user-row"
  events: {
    'click .name': 'hit'
    'click .delete': 'delete'
  }

  template: _.template("""
    <td class="name"><%- name %></td>
    <td class="hits"><%- hits %></td>
    <td class="delete">Delete</td>
    """)

  initialize: () ->
    _.bindAll(this, 'render')
    @user = @options.user
    @user.bind('change', @render)

  render: ->
    $(@el).html(@template(name: @user.get('name'), hits: @user.get('hits')))
    this

  hit: ->
    @user.save(hits: @user.get('hits') + 1)

  delete: ->
    @user.destroy()

class Socket extends Rubyists.Socket
  onopen: ->
    list = new UserList(users: new Users)
    $('#counter').html(list.render().el)

$ ->
  Rubyists.syncSocket = new Socket(server: 'ws://localhost:33331')
