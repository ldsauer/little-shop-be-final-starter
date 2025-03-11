class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  belongs_to :coupon, optional: true
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :status, presence: true, inclusion: { in: ["shipped", "packaged", "returned", "pending"] }
  validate :one_coupon_per_merchant

  private
  
  def one_coupon_per_merchant
    return if coupon_id.nil? 

    if merchant.invoices.where(coupon_id: coupon_id).exists?
      errors.add(:coupon_id, "This coupon has already been used by this Merchant")
    end
  end
end