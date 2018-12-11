# frozen_string_literal: true

module Clonk
  ##
  # This class represents a client within SSO. A client allows a user to authenticate against SSO with their credentials.

  class Client
    attr_accessor :id
    attr_reader :name

    def initialize(clients_response)
      @id = clients_response['id']
      @name = clients_response['clientId']
    end

    ##
    # Maps the given role into the scope of the client. If a user has that role,
    # it will be visible in tokens given by this client during authentication.

    def map_scope(client: nil, role: nil, realm: REALM)
      Clonk.parsed_response(
        method: :post,
        data: [role.config],
        path: "#{url}/scope-mappings/clients/#{client.id}"
      )
    end

    ##
    # Lists the client's permission IDs, if permissions are enabled.
    # These will be returned as either a boolean (false) if disabled,
    # or a hash of permission types and IDs.

    def permissions
      Clonk.parsed_response(
        path: "#{url}/management/permissions"
      )['scopePermissions'] || false
    end

    ##
    # Enables or disables permissions for a client

    def set_permissions(enabled: true)
      Clonk.parsed_response(
        method: :put,
        path: "#{url}/management/permissions",
        data: {
          enabled: enabled
        }
      )
    end

    ##
    # Returns the client's secret

    def secret
      Clonk.parsed_response(
        path: "#{url}/client-secret"
      )['value']
    end

    def delete
      Clonk.response(
        method: :delete,
        path: url
      )
    end
  end
end
