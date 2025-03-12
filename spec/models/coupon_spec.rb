require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe "validations" do 
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
    it { should validate_presence_of(:discount_type) }
    it { should validate_inclusion_of(:discount_type).in_array(%w[percent dollar]) }
    it { should validate_presence_of(:discount_value) }
    it { should validate_numericality_of(:discount_value).is_greater_than(0) }
  end

  describe 'associations' do 
    it { should have_many(:invoices) }
    it { should have_many(:merchant_coupons) }
    it { should have_many(:merchants).through(:merchant_coupons) }
  end

  describe "#coupon_count" do 
    it "returns the correct number of invoices for a coupon" do 
      coupon = create(:coupon)
      customer = create(:customer)
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      invoice1 = create(:invoice, coupon: coupon, customer: customer, merchant: merchant1)
      invoice2 = create(:invoice, coupon: coupon, customer: customer, merchant: merchant2)

      expect(coupon.coupon_count).to eq(2)
    end
  end

  describe "#can_be_deactivated?" do 
    it "returns true if there are no pending invoices for the coupon" do 
      coupon = create(:coupon)
      create(:invoice, coupon: coupon, status: "shipped")

      expect(coupon.can_be_deactivated?).to eq(true)
    end

    it "returns false if there is a pending invoice for the coupon" do 
      coupon = create(:coupon)
      create(:invoice, coupon: coupon, status: "pending")

      expect(coupon.can_be_deactivated?).to eq(false)
    end
  end
end
