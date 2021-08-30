FactoryBot.define do
    factory :member do
        sequence(:first_name) { |i| "first_name_#{i}"}
        sequence(:last_name) { |i| "last_name_#{i}"}
        sequence(:email) { |i| "email#{i}@gmail.com"}
        password {"password"}
        password_confirmation {"password"}
        # url {"http://example.com/"}
        url {File.join(Rails.root,'spec','fixtures','test.xml')}
    end
end