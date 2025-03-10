class CouponSerializer 
  include JSONAPI::Serializer
  attributes :name, :code, :discount_value, :discount_type, :active 

  attribute :usage_count do |coupon|
    coupon.coupon_count
  end
end