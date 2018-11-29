module Clonk
  class User
    attr_accessor :id
    attr_reader :username

    def initialize(user_response)
      @username = user_response['username']
      @id = user_response['id']
    end

    ##
    # Gets config inside SSO for user with ID in realm

    def self.get_config(id, realm = REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/users/#{id}"
      )
    end

    ##
    # Gets config inside SSO for this user

    def config
      self.class.get_config(@id, @realm)
    end

    ##
    # Creates a new User instance from a user that exists in SSO

    def self.new_from_id(id, realm = REALM)
      new(get_config(id, realm), realm)
    end

    ##
    # Creates a user in SSO, returning a User instance with their ID and
    # username

    def self.create(realm: REALM, username: nil, enabled: true)
      response = Clonk.response(method: :post,
                      path: "#{Clonk.realm_admin_root(realm)}/users",
                      data: { username: username, enabled: enabled }
                      )
      self.new_from_id(response.headers[:location].split('/')[-1], realm)
    end

    ##
    # Returns all users in the given realm

    def self.all(realm: REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/users"
      ).map { |user| new_from_id(user['id'], realm) }
    end

    ##
    # Returns all users in the given realm with the given username

    def self.where(username: nil, realm: REALM)
      all(realm: realm).select { |user| user.username == username }
    end

    ##
    # returns a user in the given realm with the given username

    def self.find_by(username: nil, realm: REALM)
      where(username: username, realm: realm)&.first
    end

    ##
    # Returns the API URL from which the user is accessible.

    def url
      "#{Clonk.realm_admin_root(@realm)}/users/#{@id}"
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