require 'em-websocket'
require 'json'
require 'logger'
require 'sequel'
require 'faker'

Log = Logger.new($stdout)
DB = Sequel.sqlite(logger: Log)

class User < Sequel::Model
  plugin :schema

  set_schema do
    primary_key :id

    String :name
    Integer :hits
  end

  create_table?

  class << self
    def ws_create(attributes)
      instance = create(attributes)
      return {id: instance.id}
    end

    def ws_read(id = nil)
    end

    def ws_update(id, attributes)
      return unless instance = self[id: id]
      allowed = attributes.reject{|k,v| k == 'id' }
      instance.update(allowed)
      return {id: instance.id}
    end

    def ws_delete(id)
      return unless instance = self[id: id]
      instance.delete
      return {id: instance.id}
    end
  end

  def to_json(*args)
    {id: id, name: name, hits: hits}.to_json(*args)
  end
end

rand(5..10).times do
  User.create name: Faker::Name.name, hits: rand(0..10)
  User.create name: Faker::Name.name, hits: rand(0..10)
end

module Users
  class << self
    def ws_create(attributes)
    end

    def ws_read(id = nil)
      User.all
    end

    def ws_update(id, attributes)
    end

    def ws_delete(id)
    end
  end
end

EM.run do
  ws_options = {
    host: '127.0.0.1',
    port: 33331,
    debug: false,
  }

  EventMachine::WebSocket.start ws_options do |ws|
    say = lambda{|obj|
      Log.info say: obj
      ws.send(obj.to_json)
    }

    ws.onopen do
      Log.info "onopen"
    end

    ws.onclose do
      Log.info "onclose"
    end

    urls = {
      'User' => User,
      'Users' => Users,
    }

    ws.onmessage do |json|
      begin
        msg = JSON.parse(json)
        Log.debug onmessage: msg

        frame = msg['frame']
        method, url, id, attributes =
          msg['body'].values_at('method', 'url', 'id', 'attributes')

        handler = urls.fetch(url)
        response =
          case method
          when 'create'; handler.ws_create(attributes)
          when 'read'; handler.ws_read(id)
          when 'update'; handler.ws_update(id, attributes)
          when 'delete'; handler.ws_delete(id)
          else; raise "Unknown method %p in %p" % [method, msg]
          end

        say.(frame: frame, ok: response)
      rescue => error
        Log.error(error)
        say.(frame: frame, error: error.to_s)
      end
    end

    ws.onerror do |error|
      Log.error error
    end
  end
end
