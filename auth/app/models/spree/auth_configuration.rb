module Spree
  module Auth
    class Configuration < Preferences::Configuration
      preference :registration_step, :boolean, :default => true
      preference :signout_after_password_change, :boolean, :default => true
    end
  end
end
