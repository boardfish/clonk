# frozen_string_literal: true

module Clonk
  ##
  # Represents a user in SSO.
  class User
    attr_accessor :id
    attr_reader :username

    def initialize(user_response)
      @username = user_response['username']
      @id = user_response['id']
    end
  end
end
