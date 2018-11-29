module Clonk
  class Realm

    attr_reader :name

    def initialize(realm_response)
      @name = realm_response['id'] || realm_response['realm']
    end

    ##
    # Creates a realm with the given name, returning it as a Realm object
    def self.create(name: nil)
      Clonk.parsed_response(
        method: :post,
        path: '/auth/admin/realms',
        data: { id: name, realm: name, enabled: true }
      )
      new_from_id(id: name)
    end

    ##
    # Returns all realms in this instance of SSO.

    def self.all
      Clonk.parsed_response(
        path: '/auth/admin/realms'
      ).map { |realm| new_from_id(id: realm['id'])}
    end

    ##
    # Returns the realm with the given name.

    def self.find_by(name: nil)
      Clonk.parsed_response(
        path: "/auth/admin/realms/#{name}"
      )
    end

    ##
    # Gets the config for this realm in SSO.

    def config
      Clonk.parsed_response(
        path: "/auth/admin/realms/#{@name}"
      )
    end

    ##
    # Creates a new Realm object from a given realm ID.

    def self.new_from_id(id: nil)
      new(find_by(name: id))
    end

    ##
    # Returns the admin API root for the realm.

    def realm_admin_root(realm = @realm)
      "#{@base_url}/auth/admin/realms/#{realm.id}"
    end

    ##
    # Lists clients in the realm

    def clients
      Clonk.parsed_response(path: "#{realm_admin_root}/clients")
    end

    ##
    # Lists groups in the realm

    def groups
      Clonk.parsed_response(path: "#{realm_admin_root}/groups")
    end

    ##
    # Lists users in the realm

    def users
      Clonk.parsed_response(path: "#{realm_admin_root}/users")
    end
  end
end
