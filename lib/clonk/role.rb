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

    ##
    # Returns all roles for the given client. Can also return all roles
    # applicable to a specific target object.
    #--
    # FIXME: target_type should really be inherited from classname of incoming
    # object
    #++

    def self.all(client: nil, target: nil, target_type: nil, realm: REALM)
      # need this to work with realms too
      case target
      when nil
        path = "#{Clonk.realm_admin_root(realm)}/clients/#{client.id}/roles"
      else
        path = "#{Clonk.realm_admin_root(realm)}/#{target_type}s/#{target.id}/role-mappings/clients/#{client.id}/available"
      end
      Clonk.parsed_response(
        path: path
      ).map { |role| new_from_id(role['id'], realm) }
    end

    ##
    # Returns all roles with the given name.

    def self.where(client: nil, target: nil, target_type: nil, realm: REALM, name: nil)
      all(client: client, target: target, target_type: target_type, realm: realm)
        .select { |role| role.name == name }
    end

    ##
    # Returns the first role with the given name.

    def self.find_by(client: nil, target: nil, target_type: nil, realm: REALM, name: nil)
      where(client: client, target: target, target_type: target_type, realm: realm, name: name)&.first
    end

    ##
    # Gets config inside SSO for role with ID in realm

    def self.get_config(id, realm = REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/roles-by-id/#{id}"
      )
    end

    ##
    # Gets config inside SSO for this role

    def config
      self.class.get_config(@id, @realm)
    end

    ##
    # Creates a new Role instance from a role that exists in SSO

    def self.new_from_id(id, realm = REALM)
      new(get_config(id, realm), realm)
    end
  end
end
