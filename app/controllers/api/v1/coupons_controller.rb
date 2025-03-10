class Api::V1::CouponsController < ApplicationController
  before_action :set_merchant, only: [:index, :create]
  before_action :set_coupon, only: [:show, :update]

  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: CouponSerializer.new(merchant.coupons), status: :ok
  end

  def show
    coupon = set_coupon

    if coupon
      render json: CouponSerializer.new(coupon), status: :ok
      return
    else
      render json: ErrorSerializer.format_errors(["Coupon not found for this merchant"]), status: :not_found
      return
    end
    render json: CouponSerializer.new(coupon), status: :ok
  end

  def create
    merchant = Merchant.find(params[:merchant_id])

    if merchant.coupons.where(active: true).count >= 5
      render json: ErrorSerializer.format_errors(["Merchant can only have 5 active coupons at a time"]), status: :unprocessable_entity
      return
    end

    coupon = Coupon.find_or_create_by(code: params[:code]) do |c|
      c.name = params[:name]
      c.discount_value = params[:discount_value]
      c.discount_type = params[:discount_type]
      c.active = params[:active]
    end

    if merchant.coupons.exists?(coupon.id)
      render json: ErrorSerializer.format_errors(["Merchant already has this coupon"]), status: :unprocessable_entity
    else 
      merchant.coupons << coupon
      render json: CouponSerializer.new(coupon), status: :created
    end
  end

  def update
    coupon = Coupon.find(params[:id])

    if params[:active] == false || params[:active] == "false"
      if coupon.invoices.where(status: "pending").exists? 
        render json: ErrorSerializer.format_errors(["Cannot deactivate a coupon on a pending invoice"]), status: :unprocessable_entity
        return
      end
    end
    
    if coupon.update(coupon_params)
      render json: CouponSerializer.new(coupon), status: :ok
    else 
      render json: ErrorSerializer.format_errors(coupon.errors.full_messages), status: :unprocessable_entity
    end
  end

  private 

  def coupon_params
    params.permit(:name, :code, :discount_value, :discount_type, :active)
  end

  def set_merchant
    Merchant.find(params[:merchant_id])
  end

  def set_coupon
    Merchant.find(params[:merchant_id]).coupons.find_by(id: params[:id])
  end
end
