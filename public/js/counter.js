(function() {
  var Socket, User, UserList, UserRow, Users, p;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  p = function() {
    var _ref;
    return (_ref = window.console) != null ? typeof _ref.debug === "function" ? _ref.debug.apply(_ref, arguments) : void 0 : void 0;
  };
  Backbone.sync = Rubyists.BackboneWebSocketSync;
  User = (function() {
    __extends(User, Backbone.Model);
    function User() {
      User.__super__.constructor.apply(this, arguments);
    }
    User.prototype.url = 'User';
    return User;
  })();
  Users = (function() {
    __extends(Users, Backbone.Collection);
    function Users() {
      Users.__super__.constructor.apply(this, arguments);
    }
    Users.prototype.url = 'Users';
    Users.prototype.model = User;
    return Users;
  })();
  UserList = (function() {
    __extends(UserList, Backbone.View);
    function UserList() {
      UserList.__super__.constructor.apply(this, arguments);
    }
    UserList.prototype.tagName = 'ul';
    UserList.prototype.className = 'user-list';
    UserList.prototype.events = {};
    UserList.prototype.template = _.template("Users:");
    UserList.prototype.initialize = function() {
      _.bindAll(this, 'addOne', 'addAll', 'render');
      this.users = this.options.users;
      this.users.bind('reset', this.addAll);
      this.users.bind('change', this.addAll);
      this.users.bind('save', function() {
        return p('save');
      });
      this.users.bind('add', function() {
        return p('add');
      });
      this.users.bind('create', function() {
        return p('create');
      });
      return this.users.fetch();
    };
    UserList.prototype.addAll = function() {
      $(this.el).html('');
      return this.users.each(this.addOne);
    };
    UserList.prototype.addOne = function(user) {
      var view;
      view = new UserRow({
        user: user
      });
      return $(this.el).append(view.render().el);
    };
    UserList.prototype.render = function() {
      $(this.el).html(this.template({
        users: this.users
      }));
      return this;
    };
    return UserList;
  })();
  UserRow = (function() {
    __extends(UserRow, Backbone.View);
    function UserRow() {
      UserRow.__super__.constructor.apply(this, arguments);
    }
    UserRow.prototype.tagName = "li";
    UserRow.prototype.className = "user-row";
    UserRow.prototype.events = {
      'click': 'hit'
    };
    UserRow.prototype.template = _.template('name: <%- name %>, hits: <%- hits %>');
    UserRow.prototype.initialize = function() {
      _.bindAll(this, 'render');
      this.user = this.options.user;
      return this.user.bind('change', this.render);
    };
    UserRow.prototype.render = function() {
      $(this.el).html(this.template({
        name: this.user.get('name'),
        hits: this.user.get('hits')
      }));
      return this;
    };
    UserRow.prototype.hit = function() {
      return this.user.save({
        hits: this.user.get('hits') + 1
      });
    };
    return UserRow;
  })();
  Socket = (function() {
    __extends(Socket, Rubyists.Socket);
    function Socket() {
      Socket.__super__.constructor.apply(this, arguments);
    }
    Socket.prototype.onopen = function() {
      var list;
      list = new UserList({
        users: new Users
      });
      return $('#counter').html(list.render().el);
    };
    return Socket;
  })();
  $(function() {
    return Rubyists.syncSocket = new Socket({
      server: 'ws://localhost:33331'
    });
  });
}).call(this);
