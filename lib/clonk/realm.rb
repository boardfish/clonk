# frozen_string_literal: true

module Clonk
  # Represents a realm within SSO.
  class Realm
    attr_reader :name

    def initialize(realm_response)
      @name = realm_response['realm'] || realm_response['id']
    end

    def id
      name
    end
  end

  # Defines a connection to SSO.
  class Connection
    # Lists all realms in SSO.
    def realms
      objects(type: 'Realm', path: '', root: realm_admin_root(nil))
    end

    # Creates a new realm with the given data.
    def create_realm(**data)
      create_object(
        type: 'Realm',
        path: '',
        root: realm_admin_root(nil),
        data: { enabled: true, id: data['realm'] }.merge(data)
      )
    end
  end
end
