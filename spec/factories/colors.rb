FactoryBot.define do
  factory :color do
    association :user
    color_code { '#FF0000' }  # Red color
  end
end 