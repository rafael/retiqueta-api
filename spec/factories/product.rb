FactoryGirl.define do
  factory :product do
    association :user
    title "Mis mejores zapatos"
    description "En muy buen estado"
    price 40.0
    original_price 80.0
    status "published"
    after(:create) do |product, evaluator|
      create(:product_picture, product: product) if product.product_pictures.empty?
    end
  end
end
