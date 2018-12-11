# frozen_string_literal: true

module Clonk
  class Permission
    def initialize(permission_response, realm)
      @id = permission_response['id']
      @realm = realm
    end

    ##
    # Returns the API URL for this permission.
    # Argument is necessary as permissions are sometimes treated as policies
    # within SSO for some reason, especially when fetching scopes, resources and
    # policies.

    def url(prefix: 'permission/scope')
      client_url = Clonk::Client.find_by(realm: @realm, name: 'realm-management').url
      "#{client_url}/authz/resource-server/#{prefix}/#{@id}"
    end

    ##
    # Creates a new Permission instance from a given permission ID and realm.

    def self.new_from_id(id: nil, realm: REALM)
      client_url = Clonk::Client.find_by(realm: realm, name: 'realm-management').url
      response = Clonk.parsed_response(
        path: "#{client_url}/authz/resource-server/permission/scope/#{id}"
      )
      new(response, realm)
    end

    ##
    # Returns the config within SSO for this permission.

    def config
      Clonk.parsed_response(
        path: url.to_s
      )
    end

    ##
    # Returns the policy IDs associated with this permission.

    def policies
      Clonk.parsed_response(
        path: "#{url(prefix: 'policy')}/associatedPolicies"
      ).map { |policy| policy['id'] }
    end

    ##
    # Returns the resource IDs associated with this permission.

    def resources
      Clonk.parsed_response(
        path: "#{url(prefix: 'policy')}/resources"
      ).map { |resource| resource['_id'] }
    end

    ##
    # Returns the scope IDs associated with this permission.

    def scopes
      Clonk.parsed_response(
        path: "#{url(prefix: 'policy')}/scopes"
      ).map { |scope| scope['id'] }
    end

    ##
    # Adds the given policy/resource/scope IDs to this permission in SSO.

    def update(policies: [], resources: [], scopes: [])
      data = config.merge(
        policies: self.policies + policies,
        resources: self.resources + resources,
        scopes: self.scopes + scopes
      )
      Clonk.parsed_response(
        path: url,
        data: data,
        method: :put
      )
    end
  end
end
