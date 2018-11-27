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

    # Gets config inside SSO for group with ID in realm
    def self.get_config(id, realm = REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/groups/#{id}"
      )
    end

    def config
      self.class.get_config(@id, @realm)
    end

    # Creates a new Group instance from a group that exists in SSO
    def self.new_from_id(id, realm = REALM)
      new(get_config(id, realm), realm)
    end

    # Creates a new group in SSO and casts it to an instance
    def self.create(name: nil, realm: REALM)
      new_group = new({ 'name' => name }, realm)
      response = new_group.save(realm)
      new_group.id = response.headers[:location].split('/')[-1]
      new_group
    end

    def save(realm = REALM)
      if @id
        Clonk.parsed_response(
          method: :put,
          path: "#{Clonk.realm_admin_root(@realm)}/groups/#{@id}",
          data: config.merge('name' => @name)
        )
      else
        Clonk.response(
          method: :post,
          path: "#{Clonk.realm_admin_root(realm)}/groups",
          data: { name: @name }
        )
      end
    end

    def create_subgroup(name: nil)
      response = Clonk.parsed_response(
        method: :post,
        path: "#{url}/children",
        data: { name: name }
      )
      self.class.new_from_id(response['id'], @realm)
    end

    def subgroups
      config["subGroups"].map { |group| self.class.new_from_id(group['id'], @realm) }
    end

    def self.all(realm: REALM, flattened: false)
      response = Clonk.parsed_response(
        method: :get,
        path: "#{Clonk.realm_admin_root(realm)}/groups",
      )
      response += response.map { |group| group['subGroups'] } if flattened
      response.flatten
              .map { |group| new_from_id(group['id'], realm) }
    end

    def self.where(name: nil, realm: REALM)
      all(flattened: true, realm: realm)
        .select { |group| group['name'] == name }
        .map { |group| new_from_id(group['id'], realm) }
    end

    def self.find_by(name: nil, realm: REALM)
      where(name: name, realm: realm)&.first
    end

    def self.find(id: nil, realm: REALM)
      if all.find { |group| group['id'] == id }
        new_from_id(id, realm)
      end
    end

    def url
      "#{Clonk.realm_admin_root(@realm)}/groups/#{@id}"
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
