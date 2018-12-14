# frozen_string_literal: true

module Clonk
  # Represents a policy in SSO.
  # FIXME: Has not been fully updated from v1's use of the API.
  class Policy
    attr_accessor :id
    attr_reader :name

    def initialize(policy_response)
      @id = policy_response['id']
      @name = policy_response['name']
    end

    ##
    # Returns defaults for a policy.
    # I've found no reason to override these, but then again, I'm not 100% sure
    # how they work. Overrides will be added to necessary methods if requested.
    def self.defaults
      {
        logic: 'POSITIVE',
        decisionStrategy: 'UNANIMOUS'
      }
    end
  end

  class Connection
    def policies
      realm_management = clients.find { |client| client.name == 'realm-management' }
      objects(type: 'Policy',
        path: "/clients/#{realm_management.id}/authz/resource-server/policy"
      )
    end

    ##
    # Gets config inside SSO for policy with ID in realm.
    #--
    # FIXME: bring in line with existing config method
    #++

    def get_policy_config(id)
      parsed_response(
        path: "#{realm_admin_root(realm)}/clients/#{clients.find { |client|
          client.name == 'realm-management'
        }.id}/authz/resource-server/policy/role/#{id}"
      )
    end

    ##
    # Returns a policy definition that can then be used to create a policy in SSO.
    # Only defines role, group and client policies
    #--
    # TODO: Expand to allow for other policy types
    # TODO: Don't assume role as default type
    # FIXME: give objects a type method, split this into two functions
    #++

    def define_policy(type: :role, name: nil, objects: [], description: nil, groups_claim: nil)
      objects = if type == :role
                  {
                    roles: objects.map do |role|
                      { id: role.id, required: true }
                    end
                  }
                elsif type == :group
                  {
                    groups: objects.map do |group|
                              { id: group.id, extendChildren: false }
                            end
                  }
                end
      defaults.merge(objects).merge(
        type: type,
        name: name,
        groupsClaim: (groups_claim if type == :group),
        clients: (objects.map(&:id) if type == :client),
        description: description
      ).delete_if { |_k, v| v.nil? }
    end

    ##
    # Creates a policy in SSO. You should do this after defining a policy with define_policy.
    # FIXME: move to connection class

    def self.create(data)
      realm_management_url = url_for(clients.find { |c| c.name == 'realm-management' })
      parsed_response(
        method: :post,
        path: "#{realm_management_url}/authz/resource-server/policy/#{data['type']}",
        data: data
      )
    end
  end
end
