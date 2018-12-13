# frozen_string_literal: true

module Clonk
  class Role
    attr_accessor :id
    attr_accessor :container_id
    attr_reader :name

    def initialize(role_response)
      @id = role_response['id']
      @container_id = role_response['containerId']
      @name = role_response['name']
    end
  end
end
