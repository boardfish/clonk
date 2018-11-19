module Clonk
  class Policy

    attr_accessor :id
    attr_reader :name

    def initialize(policy_response, realm)
      @id = policy_response['id']
      @name = policy_response['name']
      @realm = realm
    end

    # Gets config inside SSO for client with ID in realm
    def self.get_config(id, realm = REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/clients/#{Clonk::Client.find_by(name: 'realm-management').id}/authz/resource-server/policy/role/#{id}"
      )
    end

    def config
      self.class.get_config(@id, @realm)
    end

    # Creates a new Client instance from a client that exists in SSO
    def self.new_from_id(id, realm = REALM)
      new(get_config(id, realm), realm)
    end

    def self.defaults
      {
        logic: 'POSITIVE',
        decisionStrategy: 'UNANIMOUS'
      }
    end

    # Only defines role policies
    # TODO: Expand to allow for other policy types
    def self.define(type: :role, name: nil, objects: [], description: nil, groups_claim: nil)
      defaults.merge(
        type: type,
        name: name,
        roles: (objects.map { |role| { id: role.id, required: true } } if type == :role),
        groups: (objects.map { |group| { id: group.id, extendChildren: false } } if type == :group),
        groupsClaim: (groups_claim if type == :group),
        clients: (objects.map { |client| client.id } if type == :client),
        description: description
      ).delete_if { |k,v| v.nil?}
    end

    def self.create(type: :role, name: nil, objects: [], description: nil, groups_claim: nil, realm: REALM)
      data = self.define(type: type, name: name, objects: objects, description: description, groups_claim: groups_claim)
      realm_management_url = Clonk::Client.find_by(name: 'realm-management', realm: realm).url
      Clonk.parsed_response(
        protocol: :post,
        path: "#{realm_management_url}/authz/resource-server/policy/#{type}",
        data: data
      )
    end
  end
end