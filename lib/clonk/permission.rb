# frozen_string_literal: true

module Clonk
  # Represents a permission in SSO. Methods on Clonk::Connection can be used to
  # index its policies, resources and associated scopes
  class Permission
    def initialize(permission_response, realm)
      @id = permission_response['id']
      @realm = realm
    end
  end

  # Defines a connection to SSO.
  class Connection
    def permissions
      clients.find { |client| client.name == 'realm-management' }
    end

    ##
    # Returns the policy IDs associated with a permission.
    # FIXME: untested!
    def policies(permission)
      parsed_response(
        path: "#{url_for(permission, prefix: 'policy')}/associatedPolicies"
      )
    end

    ##
    # Returns the resource IDs associated with this permission.
    # FIXME: untested!
    def resources(permission)
      parsed_response(
        path: "#{url_for(permission, prefix: 'policy')}/resources"
      )
    end

    ##
    # Returns the scope IDs associated with this permission.
    # FIXME: untested
    def scopes(permission)
      parsed_response(
        path: "#{url_for(permission, prefix: 'policy')}/scopes"
      )
    end

    ##
    # Adds the given policy/resource/scope IDs to this permission in SSO.
    # FIXME: untested
    def update_permission(
      permission:, policies: [], resources: [], scopes: []
    )
      data = config(permission).merge(
        policies: policies(permission) + policies,
        resources: resources(permission) + resources,
        scopes: scopes(permission) + scopes
      )
      parsed_response(
        path: url_for(permission),
        data: data,
        method: :put
      )
    end
  end
end
