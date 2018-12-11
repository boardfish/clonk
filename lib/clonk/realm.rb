# frozen_string_literal: true

module Clonk
  class Realm
    attr_reader :name

    def initialize(realm_response)
      @name = realm_response['id'] || realm_response['realm']
    end
  end
end
