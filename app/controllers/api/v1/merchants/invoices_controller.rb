class Api::V1::Merchants::InvoicesController < ApplicationController
  def index
    merchant = Merchant.find_by(id: params[:merchant_id])

    if merchant.nil? 
      render json: ErrorSerializer.format_errors(["Couldn't find Merchant with 'id'=#{params[:merchant_id]}"]), status: :not_found
      return 
    end 

    invoices = params[:status].present? ? merchant.invoices_filtered_by_status(params[:status]) : merchant.invoices

    render json: InvoiceSerializer.new(invoices), status: :ok
  end

  def create 
    merchant = Merchant.find_by(id: params[:merchant_id])

    if merchant.nil?
      render json: ErrorSerializer.format_errors(["Couldn't find Merchant with 'id'=#{params[:merchant_id]}"]), status: :not_found
      return
    end

    invoice = merchant.invoices.new(invoice_params)

    if invoice.save
      render json: InvoiceSerializer.new(invoice), status: :created
    else
      render json: ErrorSerializer.format_errors(invoice.errors.full_messages), status: :unprocessable_entity
    end
  end

  private

  def invoice_params
    params.permit(:customer_id, :merchant_id, :coupon_id, :status)
  end
end