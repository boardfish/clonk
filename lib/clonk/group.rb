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
      config['subGroups'].map { |group| self.class.new_from_id(group['id'], @realm) }
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
  end
end
