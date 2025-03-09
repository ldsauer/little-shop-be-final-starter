class Api::V1::CouponsController < ApplicationController
  before_action :set_merchant, only: [:index, :create]
  before_action :set_coupon, only: [:show, :update]

  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: CouponSerializer.new(merchant.coupons), status: :ok
  end

  def show
    coupon = Coupon.find(id: params[:id], merchant_id: params[:merchant_id])

    if coupon
      render json: CouponSerializer.new(coupon), status: :ok
    else
      render json: { error: "Coupon not found for this merchant" }, status: :not_found
    end
    render json: CouponSerializer.new(coupon), status: :ok
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    coupon = Coupon.find_or_create_by(code: params[:code]) do |c|
      c.name = params[:name]
      c.discount_value = params[:discount_value]
      c.discount_type = params[:discount_type]
      c.active = params[:active]
    end

    merchant.coupons << coupon unless merchant.coupons.include?(coupon)

    render json: CouponSerilaizer.new(coupon), status: :created
  end

  def update
    coupon = Coupon.find(params[:id])

    if coupon.update(coupon_params)
      render json: CouponSerializer.new(coupon), status: :ok
    else 
      render json: { errors: coupon.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private 

  def coupon_params
    params.permit(:name, :code, :discount_value, :discount_type, :active)
  end

  def set_merchant
    Merchant.find(params[:merchant_id])
  end
end
