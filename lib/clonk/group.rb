# frozen_string_literal: true

module Clonk
  class Group
    attr_accessor :id
    attr_reader :name

    def initialize(group_response, realm = REALM)
      @name = group_response['name']
      @id = group_response['id']
      @realm = realm
    end

    # FIXME: move to connection model
    def subgroups
      config['subGroups'].map { |group| self.class.new_from_id(group['id'], @realm) }
    end
  end

  class Connection
    def groups(user: nil)
      return objects(type: 'Group') unless user

      objects(type: 'Group', path: "/users/#{user.id}/groups")
    end

    def subgroups(group)
      subgroups = config(group)['subGroups']
      return [] if subgroups.nil?

      subgroups.map { |group| create_instance_of('Group', group) }
    end

    def create_group(**data)
      return if data[:name].nil? # Breaks things in SSO!

      create_object(type: 'Group', data: data)
    end

    def create_subgroup(group:, **data)
      create_object(type: 'Group', path: "/groups/#{group.id}/children", data: data)
    end

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
