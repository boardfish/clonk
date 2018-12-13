# frozen_string_literal: true

module Clonk
  ##
  # This class represents a client within SSO. A client allows a user to
  # authenticate against SSO with their credentials.
  class Client
    attr_accessor :id
    attr_reader :name

    def initialize(clients_response)
      @id = clients_response['id']
      @name = clients_response['clientId']
    end
  end

  class Connection
    def clients
      objects(type: 'Client')
    end

    def create_client(**data)
      create_object(type: 'Client', data: { fullScopeAllowed: false }.merge(data))
    end

    ##
    # Maps the given role into the scope of the client. If a user has that role,
    # it will be visible in tokens given by this client during authentication.
    # FIXME: Write test!

    def map_scope(client:, role:)
      response(
        method: :post,
        data: [config(role)],
        path: "#{url_for(client)}/scope-mappings/clients/#{role.container_id}"
      )
    end

    ##
    # Lists the client's permission IDs, if permissions are enabled.
    # These will be returned as either a boolean (false) if disabled,
    # or a hash of permission types and IDs.
    # FIXME: Move to RHSSO so that permissions can actually be used!
    # FIXME: Write test!

    def permissions(client:)
      parsed_response(
        path: "#{url_for(client)}/management/permissions"
      )['scopePermissions'] || false
    end

    ##
    # Enables or disables permissions for some object
    # FIXME: Write test!

    def set_permissions(object:, enabled: true)
      parsed_response(
        method: :put,
        path: "#{url_for(object)}/management/permissions",
        data: {
          enabled: enabled
        }
      )
    end

    ##
    # Returns the client's secret
    # FIXME: Write test!

    def secret(client:)
      parsed_response(
        path: "#{url_for(client)}/client-secret"
      )['value']
    end
  end
end
