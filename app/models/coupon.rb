class Coupon < ApplicationRecord
  has_many :invoices
  has_many :merchant_coupons
  has_many :merchants, through: :merchant_coupons

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :discount_type, presence: true, inclusion: { in: %w[percent dollar] }

  def coupon_count
    invoices.count
  end

  def can_be_deactivated? 
    invoices.where(status: "pending").empty? 
  end
end
