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
end
