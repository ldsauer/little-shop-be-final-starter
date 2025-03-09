class CreateMerchantCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :merchant_coupons do |t|
      t.references :merchant, null: false, foreign_key: true
      t.references :coupon, null: false, foreign_key: true

      t.timestamps
    end
  end
end
