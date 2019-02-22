# frozen_string_literal: true

module Clonk
  # Represents a permission in SSO. Methods on Clonk::Connection can be used to
  # index its policies, resources and associated scopes
  class Permission
    attr_reader :id
    attr_reader :name

    def initialize(permission_response)
      @id = permission_response['id']
      @name = permission_response['name']
    end
  end

  # Defines a connection to SSO.
  class Connection
    ##
    # Lists the permissions associated with an object.
    # If an object is not provided, all permissions in the realm-management
    # client are returned.
    def permissions(object: nil)
      # list all permissions from realm-management
      realm_management = clients.find { |client| client.name == 'realm-management' }
      all_permissions = objects(
        type: 'Permission',
        path: "#{url_for(realm_management)}/authz/resource-server/permission".delete_prefix(realm_admin_root)
      )
      return all_permissions unless object
      # map the scopePermissions hash to a new one with the permission objects
      object_permissions = parsed_response(path: "#{url_for(object)}/management/permissions")
      object_permissions['scopePermissions'].to_h { |name, id| 
        [name, all_permissions.find { |permission| permission.id == id }]
      }
    end

    ##
    # Returns the policy IDs associated with a permission.
    # FIXME: untested!
    def policies_for(permission)
      objects(type: 'Policy', path: "#{url_for_permission(permission, prefix: 'policy')}/associatedPolicies", root: '')
    end

    ##
    # Returns the resource IDs associated with this permission.
    # FIXME: untested!
    def resources_for(permission)
      parsed_response(
        path: "#{url_for_permission(permission, prefix: 'policy')}/resources"
      )
    end

    ##
    # Returns the scope IDs associated with this permission.
    # FIXME: untested
    def scopes_for(permission)
      parsed_response(
        path: "#{url_for_permission(permission, prefix: 'policy')}/scopes"
      )
    end

    ##
    # Adds the given policy/resource/scope IDs to this permission in SSO.
    # FIXME: untested
    def update_permission(
      permission:, policies: [], resources: [], scopes: []
    )
      data = config(permission).merge(
        "policies" => (policies_for(permission) + policies).map(&:id).compact,
        "resources" => (resources_for(permission) + resources).map { |r| r['_id'] }.compact,
        "scopes" => (scopes_for(permission) + scopes).map { |s| s['id'] }.compact
      )
      response(
        path: url_for(permission),
        data: data,
        method: :put
      )
    end
  end
end
