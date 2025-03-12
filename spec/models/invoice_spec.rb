require "rails_helper"

RSpec.describe Invoice do
  it { should belong_to :merchant }
  it { should belong_to :customer }
  it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }

  describe "custom validations" do 
    it "allows the same coupon to be used by different merchants" do 
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      customer = create(:customer)
      coupon = create(:coupon)

      invoice1 = create(:invoice, merchant: merchant1, customer: customer, coupon: coupon)
      invoice2 = create(:invoice, merchant: merchant2, customer: customer, coupon: coupon)

      expect(coupon.valid?).to eq(true)
    end

    it "does not allow the same coupon to be used more than once per merchant" do 
      merchant = create(:merchant)
      customer1 = create(:customer)
      customer2 = create(:customer)
      coupon = create(:coupon)

      invoice1 = create(:invoice, merchant: merchant, customer: customer1, coupon: coupon)
      invoice2 = build(:invoice, merchant: merchant, customer: customer2, coupon: coupon)

      invoice2.validate

      expect(invoice2.valid?).to eq(false)
      expect(invoice2.errors[:coupon_id]).to include("This coupon has already been used by this Merchant")
    end
  end
end