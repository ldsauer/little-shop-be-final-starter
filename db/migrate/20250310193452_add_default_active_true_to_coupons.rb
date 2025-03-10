class AddDefaultActiveTrueToCoupons < ActiveRecord::Migration[7.1]
  def change
    change_column_default :coupons, :active, true
    change_column_null :coupons, :active, false
  end
end
