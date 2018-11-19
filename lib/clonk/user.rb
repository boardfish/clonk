module Clonk
  class User
    attr_accessor :id
    attr_reader :username

    def initialize(user_response, realm)
      @username = user_response['username']
      @id = user_response['id']
      @realm = realm
    end

    # Gets config inside SSO for group with ID in realm
    def self.get_config(id, realm = REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/users/#{id}"
      )
    end

    def config
      self.class.get_config(@id, @realm)
    end

    # Creates a new User instance from a user that exists in SSO
    def self.new_from_id(id, realm = REALM)
      new(get_config(id, realm), realm)
    end

    def self.create(realm: REALM, username: nil, enabled: true)
      response = Clonk.response(protocol: :post,
                      path: "#{Clonk.realm_admin_root(realm)}/users",
                      data: { username: username, enabled: enabled }
                      )
      self.new_from_id(response.headers[:location].split('/')[-1], realm)
    end

    def self.all(realm: REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/users"
      ).map { |user| new_from_id(user['id'], realm) }
    end

    def self.where(username: nil, realm: REALM)
      all(realm: realm).select { |user| user.username == username }
    end

    def self.find_by(username: nil, realm: REALM)
      where(username: username, realm: realm)&.first
    end

    def url
      "#{Clonk.realm_admin_root(@realm)}/users/#{@id}"
    end

    def map_role(role: nil)
      client_path = role.container_id == @realm ? 'realm' : "clients/#{role.container_id}"
      response = Clonk.parsed_response(
        protocol: :post,
        data: [role.config],
        path: "#{url}/role-mappings/#{client_path}"
      )
    end

    def set_password(password: nil, temporary: false)
      Clonk.parsed_response(
        protocol: :put,
        data: {
          type: 'password',
          value: password,
          temporary: false
        },
        path: "#{url}/reset-password"
      )
    end
  end
end