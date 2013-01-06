module Sinatra
  module Authorization
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def unauthorized!(realm = "WTP?")
      headers 'WWW-Authenticate' => %(Basic realm="#{realm}")
      throw :halt, [ 401, 'Authorization Required' ]
    end

    def bad_request!
      throw :halt, [ 400, 'Bad Request' ]
    end

    def authorized?
      request.env['REMOTE_USER']
    end

    def authorize(username, password)
      User.authorized? username, password
    end

    def authenticate!
      return if authorized?
      unauthorized! unless auth.provided?
      bad_request! unless auth.basic?
      unauthorized! unless authorize(*auth.credentials)
      request.env['REMOTE_USER'] = auth.username
    end

    def current_user
      return nil unless login = authorized?
      User.find_by_login login
    end
  end
end
