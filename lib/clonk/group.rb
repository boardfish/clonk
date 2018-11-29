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

    def subgroups
      config["subGroups"].map { |group| self.class.new_from_id(group['id'], @realm) }
    end

    def map_role(role: nil)
      client_path = role.container_id == @realm ? 'realm' : "clients/#{role.container_id}"
      response = Clonk.parsed_response(
        method: :post,
        data: [role.config],
        path: "#{url}/role-mappings/#{client_path}"
      )
    end

    def add_user(user: nil, realm: REALM)
      Clonk.parsed_response(
        method: :put,
        path: "#{user.url}/groups/#{@id}",
        data: {
          groupId: @id,
          userId: user.id,
          realm: @realm
        }
      )
    end

    def set_permissions(enabled: true)
      Clonk.parsed_response(
        method: :put,
        path: "#{url}/management/permissions",
        data: {
          enabled: enabled
        }
      )
    end

    def delete
      Clonk.response(
        method: :delete,
        path: url
      )
    end 
  end
end
