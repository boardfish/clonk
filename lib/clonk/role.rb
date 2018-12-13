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

  class Connection

    def roles(client:)
      objects(type: 'Role', root: url_for(client))
    end

    ##
    # Creates a role within the given client.
    # it will be visible in tokens given by this client during authentication,
    # as it is already in scope.

    def create_role(client:, **data)
      create_object(type: 'Role', root: url_for(client), data: data)
    end
  end
end
