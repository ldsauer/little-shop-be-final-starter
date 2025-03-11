class Api::V1::Merchants::InvoicesController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    invoices = merchant.invoices.select(:id, :customer_id, :merchant_id, :coupon_id, :status)


    if invoice.save 
      render json: INvoiceSerilaizer.new(invoice), status: :created
    else 
      render json ErrorSerializer.format_errors(onvoice.errors.full_messages), status: :unprocessable_entity
    end
  
    if params[:status].present?
      invoices = merchant.invoices_filtered_by_status(params[:status])
    else
      invoices = merchant.invoices
    end
    render json: InvoiceSerializer.new(invoices)
  end

  def create 
    invoice = Invoice.new(invoice_params)

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