class MerchantCoupon < ApplicationRecord
  belongs_to :merchant
  belongs_to :coupon
end