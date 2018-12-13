# frozen_string_literal: true

module Clonk
  # Represents a group or subgroup within SSO.
  class Group
    attr_accessor :id
    attr_reader :name

    def initialize(group_response, realm = REALM)
      @name = group_response['name']
      @id = group_response['id']
      @realm = realm
    end
  end

  # Defines a connection to SSO.
  class Connection
    # Lists groups in the realm.
    def groups(user: nil)
      return objects(type: 'Group') unless user

      objects(type: 'Group', path: "/users/#{user.id}/groups")
    end

    # Lists subgroups of a given group.
    def subgroups(group)
      subgroups = config(group)['subGroups']
      return [] if subgroups.nil?

      subgroups.map { |subgroup| create_instance_of('Group', subgroup) }
    end

    # Creates a group in SSO and returns its representation as a Clonk::Group.
    def create_group(**data)
      return if data[:name].nil? # Breaks things in SSO!

      create_object(type: 'Group', data: data)
    end

    # Creates a subgroup in SSO and returns its representation as a
    # Clonk::Group.
    def create_subgroup(group:, **data)
      create_object(
        type: 'Group', path: "/groups/#{group.id}/children", data: data
      )
    end

    # Adds a user to a group.
    def add_to_group(user:, group:)
      response(
        method: :put,
        path: "#{realm_admin_root}/users/#{user.id}/groups/#{group.id}",
        data: {
          userId: user.id,
          groupId: group.id,
          realm: @realm.name
        }
      )
    end
  end
end
