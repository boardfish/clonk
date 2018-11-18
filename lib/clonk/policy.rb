module Clonk
  class Policy
    def self.defaults
      {
        logic: 'POSITIVE',
        decisionStrategy: 'UNANIMOUS'
      }
    end

    # Only defines role policies
    # TODO: Expand to allow for other policy types
    def self.define(type: :role, name: nil, roles: [], description: nil)
      defaults.merge(
        type: type,
        name: name,
        roles: roles.map { |role| role['id'] },
        description: description
      )
    end

    def self.create(type: :role, name: nil, roles: [], realm: REALM)
      data = self.define(type: type, name: name, roles: roles)
      realm_management_url = Clonk::Client.find_by(name: 'realm-management', realm: realm).url
      Clonk.parsed_response(
        protocol: :post,
        path: "#{realm_management_url}/authz/resource-server/policy/#{type}",
        data: data
      )
    end
  end
end