require 'spree_core'
require 'cancan'

require 'spree/token_resource'

module Spree
  module Auth
    mattr_accessor :user_class, :current_user_method

    def self.user_class
      if @@user_class.is_a?(Class)
        raise "The Spree::Auth.user_class setting must be a String, not a Class. " +
              "This is due to autoloading issues that you would normally encounter in the development environment."
      elsif @@user_class.is_a?(String)
        @@user_class.constantize
      end
    end

    def self.config(&block)
      yield(Spree::Auth::Config)
    end
  end
end

require 'spree/auth/user_extensions'
require 'spree/auth/engine'
