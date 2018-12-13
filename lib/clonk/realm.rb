# frozen_string_literal: true

module Clonk
  class Realm
    attr_reader :name

    def initialize(realm_response)
      @name = realm_response['realm'] || realm_response['id']
    end
  end

  class Connection
    def realms
      objects(type: 'Realm', path: '', root: realm_admin_root(nil))
    end

    def create_realm(**data)
      create_object(type: 'Realm', path: '', root: realm_admin_root(nil), data: { enabled: true, id: data['realm'] }.merge(data))
    end
  end
end
