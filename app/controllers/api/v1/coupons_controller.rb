class Api::V1::CouponsController < ApplicationController
  before_action :set_merchant, only: [:index, :create]
  before_action :set_coupon, only: [:show, :update]

  def index
    merchant = Merchant.find(params[:merchant_id])

      if params[:status] == "active" || params[:status] == "true"
        filtered_coupons = merchant.coupons.where(active: true)
      elsif params[:status] == "inactive" || params[:status] == "false"
        filtered_coupons = merchant.coupons.where(active: false)
      else
        filtered_coupons = merchant.coupons
      end
    
    render json: CouponSerializer.new(filtered_coupons), status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: ErrorSerializer.format_errors([e.message]), status: :not_found
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

    coupon = Coupon.find_by(code: params[:code])

    if coupon.nil? 
      coupon = Coupon.create!(coupon_params)
    end

    if merchant.coupons.exists?(coupon.id)
      render json: ErrorSerializer.format_errors(["Merchant already has this coupon"]), status: :unprocessable_entity
    else 
      merchant.coupons << coupon
      render json: CouponSerializer.new(coupon), status: :created
    end
  end

 
  
  def update
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find_by(id: params[:id])

    if coupon.nil? 
      render json: ErrorSerializer.format_errors(["Coupon not found for this Merchant"]), status: :not_found
      return
    end

    if params[:active] == false || params[:active] == "false"
      if coupon.invoices.where(status: "pending").exists? 
        render json: ErrorSerializer.format_errors(["Cannot deactivate a coupon on a pending invoice"]), status: :unprocessable_entity
        return
      end
    end

    if params[:active] == true || params[:active] == "true"
      if merchant.coupons.where(active: true).count >= 5
        render json: ErrorSerializer.format_errors(["Merchant can only have 5 active coupons at a time"]), status: :unprocessable_entity
        return
      end
    end

    if coupon.update(coupon_params)
      render json: CouponSerializer.new(coupon), status: :ok
      return
    else 
      render json: ErrorSerializer.format_errors(coupon.errors.full_messages), status: :unprocessable_entity
      return
    end
  end

  private 

  def coupon_params
    permitted_params = params.permit(:name, :code, :discount_value, :discount_type, :active)

    if permitted_params[:active].nil?
      permitted_params[:active] = true
    elsif permitted_params[:active] == "false"
      permitted_params[:active] = false
    elsif permitted_params[:active] == "true"
      permitted_params[:active] = true
    end

    permitted_params
  end

  def set_merchant
    Merchant.find(params[:merchant_id])
  end

  def set_coupon
    Merchant.find(params[:merchant_id]).coupons.find_by(id: params[:id])
  end
end
