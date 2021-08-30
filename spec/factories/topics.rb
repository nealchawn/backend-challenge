FactoryBot.define do
  factory :topic do
    member
    sequence(:title) {|i| "some title #{i}" }
  end
end
