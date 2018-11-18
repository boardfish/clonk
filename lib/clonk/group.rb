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
    def self.create(name, realm = REALM)
      new_group = new({ 'name' => name }, realm)
      response = new_group.save(realm)
      new_group.id = response.headers[:location].split('/')[-1]
      new_group
    end

    def save(realm = REALM)
      if @id
        Clonk.parsed_response(
          protocol: :put,
          path: "#{Clonk.realm_admin_root(@realm)}/groups/#{@id}",
          data: config.merge('name' => @name)
        )
      else
        Clonk.response(
          protocol: :post,
          path: "#{Clonk.realm_admin_root(realm)}/groups",
          data: { name: @name }
        )
      end
    end

    def subgroups
      config["subGroups"].map { |group| self.class.new_from_id(group['id'], @realm) }
    end

    def self.all(realm: REALM, flattened: false)
      response = Clonk.parsed_response(
        protocol: :get,
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
  end
end
