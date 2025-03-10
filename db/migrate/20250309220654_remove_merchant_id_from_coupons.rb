class RemoveMerchantIdFromCoupons < ActiveRecord::Migration[7.1]
  def change
    remove_column :coupons, :merchant_id, :integer
  end
end
