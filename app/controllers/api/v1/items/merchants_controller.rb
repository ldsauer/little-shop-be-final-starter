class Api::V1::Items::MerchantsController < ApplicationController
  def show
    item = Item.find(params[:item_id])
    render json: MerchantSerializer.new(item.merchant)
  end

  def index
    merchant = Merchant.all
    render json: MerchantSerializer.new(merchants), status: :ok
  end
end