module Clonk
  class Realm
    def initialize(realm_response)
      @name = realm_response['id']
    end

    def self.create(name: nil)
      Clonk.parsed_response(
        protocol: :post,
        path: '/auth/admin/realms',
        data: { id: name, realm: name, enabled: true }
      )
      new_from_id(id: name)
    end

    def self.all
      Clonk.parsed_response(
        path: '/auth/admin/realms'
      ).map { |realm| new_from_id(id: realm['id'])}
    end

    def self.find_by(name: nil)
      Clonk.parsed_response(
        path: "/auth/admin/realms/#{name}"
      )
    end

    def config
      Clonk.parsed_response(
        path: "/auth/admin/realms/#{@name}"
      )
    end

    def self.new_from_id(id: nil)
      new(find_by(name: id))
    end
  end
end
