module Spree
  module Auth
    module UserExtensions
      class DestroyWithOrdersError < StandardError; end

      def self.included(base)
        base.class_eval do
          include Spree::Core::UserBanners

          has_many :orders
          has_and_belongs_to_many :roles, :join_table => 'spree_roles_users'
          belongs_to :ship_address, :foreign_key => 'ship_address_id', :class_name => 'Spree::Address'
          belongs_to :bill_address, :foreign_key => 'bill_address_id', :class_name => 'Spree::Address'

          before_save :check_admin
          before_validation :set_login
          before_destroy :check_completed_orders

          # Setup accessible (or protected) attributes for your model
          attr_accessible :email, :password, :password_confirmation, :remember_me, :persistence_token, :login, :role_ids

          users_table_name = Spree::Auth.user_class.table_name
          roles_table_name = Role.table_name

          scope :admin, lambda { includes(:roles).where("#{roles_table_name}.name" => "admin") }
          # scope :registered, where("#{users_table_name}.email NOT LIKE ?", "%@example.net")

          # Creates an anonymous user.  An anonymous user is basically an auto-generated +User+ account that is created for the customer
          # behind the scenes and its completely transparently to the customer.  All +Orders+ must have a +User+ so this is necessary
          # when adding to the "cart" (which is really an order) and before the customer has a chance to provide an email or to register.
          # def self.anonymous!
          #   token = User.generate_token(:persistence_token)
          #   User.create(:email => "#{token}@example.net", :password => token, :password_confirmation => token, :persistence_token => token)
          # end

          # def self.admin_created?
          #   User.admin.count > 0
          # end
        end
      end

      def check_completed_orders
        raise Spree::Auth::UserExtensions::DestroyWithOrdersError if orders.complete.present?
      end

      def check_admin
        return if self.class.admin_created?
        admin_role = Role.find_or_create_by_name 'admin'
        self.roles << admin_role
      end
    end
  end
end
