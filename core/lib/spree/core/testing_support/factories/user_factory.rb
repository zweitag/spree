FactoryGirl.define do
  sequence :user_authentication_token do |n|
    "xxxx#{Time.now.to_i}#{rand(1000)}#{n}xxxxxxxxxxxxx"
  end

  factory :user do
    email { Faker::Internet.email }
    login { email }
    password 'secret'
    password_confirmation 'secret'
  end

  factory :admin_user, :parent => :user do
    roles { [Spree::Role.find_by_name('admin') || Factory(:role, :name => 'admin')]}
  end
end
