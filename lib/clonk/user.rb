# frozen_string_literal: true

module Clonk
  ##
  # Represents a user in SSO.
  class User
    attr_accessor :id
    attr_reader :username

    def initialize(user_response)
      @username = user_response['username']
      @id = user_response['id']
    end
  end

  # Defines a connection to SSO.
  class Connection
    # Lists all users in the realm.
    def users
      objects(type: 'User')
    end

    # Creates a new user in SSO and returns its representation as a Clonk::User.
    def create_user(**data)
      create_object(type: 'User', data: { enabled: true }.merge(data))
    end

    # Sets the password for a user.
    def set_password_for(user:, password: nil, temporary: false)
      response(
        method: :put,
        data: {
          type: 'password',
          value: password,
          temporary: temporary
        },
        path: "#{url_for(user)}/reset-password"
      )
    end
  end
end
