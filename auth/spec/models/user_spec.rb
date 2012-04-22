require 'spec_helper'

describe User do
  before(:all) { Spree::Role.create :name => 'admin' }

  context '#destroy' do
    it 'can not delete if it has completed orders' do
      order = Factory.build(:order, :completed_at => Time.now)
      order.save
      user = order.user

      lambda { user.destroy }.should raise_exception(Spree::User::DestroyWithOrdersError)
    end
  end

  context '#save' do
    let(:user) { Factory.build(:user) }

    context 'when there are no admin users' do
      it 'should assign the user an admin role' do
        user.save
        user.has_role?('admin').should be_true
      end
    end

    context 'when there are existing admin users' do
      before { Factory(:admin_user) }

      it 'should not assign the user an admin role' do
        user.save
        user.has_role?('anonymous?').should be_false
      end
    end
  end
end
