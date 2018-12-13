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

  class Connection
    def users
      objects(type: 'User')
    end

    def create_user(**data)
      create_object(type: 'User', data: { enabled: true }.merge(data))
    end

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
