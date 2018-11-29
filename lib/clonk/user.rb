module Clonk
  class User
    attr_accessor :id
    attr_reader :username

    def initialize(user_response)
      @username = user_response['username']
      @id = user_response['id']
    end

    ##
    # Maps a role to a user.

    def map_role(role: nil)
      client_path = role.container_id == @realm ? 'realm' : "clients/#{role.container_id}"
      response = Clonk.parsed_response(
        method: :post,
        data: [role.config],
        path: "#{url}/role-mappings/#{client_path}"
      )
    end

    ##
    # Sets the user's password.
    #--
    # FIXME: Currently always a permanent password Make that temporary flag do things.
    #++

    def set_password(password: nil, temporary: false)
      Clonk.parsed_response(
        method: :put,
        data: {
          type: 'password',
          value: password,
          temporary: false
        },
        path: "#{url}/reset-password"
      )
    end

    def delete
      Clonk.response(
        method: :delete,
        path: url
      )
    end
  end
end