# frozen_string_literal: true

module Clonk
  class Realm
    attr_reader :name

    def initialize(realm_response)
      @name = realm_response['realm'] || realm_response['id']
    end
  end
end
