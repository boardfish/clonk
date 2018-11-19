module Clonk
  class Permission
    def initialize(permission_response, realm)
      @id = permission_response['id']
      @realm = realm
    end

    def url(prefix: 'permission/scope')
      client_url = Clonk::Client.find_by(realm: @realm, name: 'realm-management').url
      "#{client_url}/authz/resource-server/#{prefix}/#{@id}"
    end

    def self.new_from_id(id: nil, realm: REALM)
      client_url = Clonk::Client.find_by(realm: realm, name: 'realm-management').url
      response = Clonk.parsed_response(
        path: "#{client_url}/authz/resource-server/permission/scope/#{id}"
      )
      new(response, realm)
    end

    def config
      Clonk.parsed_response(
        path: "#{url}"
      )
    end

    def policies
      Clonk.parsed_response(
        path: "#{url(prefix: 'policy')}/associatedPolicies"
      ).map { |policy| policy['id'] }
    end

    def resources
      Clonk.parsed_response(
        path: "#{url(prefix: 'policy')}/resources"
      ).map { |resource| resource['_id'] }
    end

    def scopes
      Clonk.parsed_response(
        path: "#{url(prefix: 'policy')}/scopes"
      ).map { |scope| scope['id'] }
    end

    def update(policies: [], resources: [], scopes: [])
      data = config.merge(  
        policies: self.policies + policies,
        resources: self.resources + resources,
        scopes: self.scopes + scopes
       )
      Clonk.parsed_response(
        path: url,
        data: data,
        protocol: :put
      )
    end
  end
end