module Clonk
  class Realm
    def initialize(realm_response)
      @name = realm_response['id']
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
  end
end
