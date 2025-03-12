require "rails_helper"

RSpec.describe "Merchant invoices endpoints" do
  before :each do
    @merchant2 = Merchant.create!(name: "Merchant")
    @merchant1 = Merchant.create!(name: "Merchant Again")

    @customer1 = Customer.create!(first_name: "Papa", last_name: "Gino")
    @customer2 = Customer.create!(first_name: "Jimmy", last_name: "John")

    @invoice1 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "packaged")
    @invoice2 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice3 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice4 = Invoice.create!(customer: @customer1, merchant: @merchant1, status: "shipped")
    @invoice5 = Invoice.create!(customer: @customer1, merchant: @merchant2, status: "shipped")
  end

  it "should return all invoices for a given merchant based on status param" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices?status=packaged"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data]).to be_an(Array)
    expect(json[:data].count).to eq(1)

    expect(json[:data][0][:id]).to eq(@invoice1.id.to_s)
    expect(json[:data][0][:type]).to eq("invoice")
    expect(json[:data][0][:attributes][:customer_id]).to eq(@customer1.id)
    expect(json[:data][0][:attributes][:merchant_id]).to eq(@merchant1.id)
    expect(json[:data][0][:attributes][:status]).to eq("packaged")
    
    json[:data].each do |invoice|
      expect(invoice[:id]).to be_a(String)
      expect(invoice[:type]).to eq("invoice")
      expect(invoice[:attributes][:customer_id]).to be_an(Integer)
      expect(invoice[:attributes][:merchant_id]).to be_an(Integer)
      expect(invoice[:attributes][:status]).to be_a(String)
    end
  end

  it "should get multiple invoices if they exist for a given merchant and status param" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices?status=shipped"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(3)
  end

  it "should only get invoices for merchant given" do
    get "/api/v1/merchants/#{@merchant2.id}/invoices?status=shipped"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(1)
    expect(json[:data][0][:id]).to eq(@invoice5.id.to_s)
  end

  it "should return 404 and error message when merchant is not found" do
    get "/api/v1/merchants/2222222/invoices"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(:not_found)
    expect(json[:message]).to eq("Your query could not be completed")
    expect(json[:errors]).to be_an(Array)
    expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=2222222")
  end

  it "should return all invoices for a given merchant without status filter" do
    get "/api/v1/merchants/#{@merchant1.id}/invoices"

    json = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(json[:data].count).to eq(4)
    expect(json[:data].map { |invoice| invoice[:id] }).to match_array([@invoice1.id.to_s, @invoice2.id.to_s, @invoice3.id.to_s, @invoice4.id.to_s])
  end

  

  describe "POST /api/v1/merchants/:merchant_id/invoices" do
    it "creates a new invoice for a merchant" do
      invoice_params = {
        customer_id: @customer1.id,
        merchant_id: @merchant1.id,
        status: "shipped"
      }

      headers = { "CONTENT_TYPE" => "application/json" }

      post "/api/v1/merchants/#{@merchant1.id}/invoices", params: invoice_params.to_json, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data]).to include(:id, :type, :attributes)
      expect(json[:data][:id]).to be_a(String)
      expect(json[:data][:type]).to eq("invoice")
      expect(json[:data][:attributes][:customer_id]).to eq(@customer1.id)
      expect(json[:data][:attributes][:merchant_id]).to eq(@merchant1.id)
      expect(json[:data][:attributes][:status]).to eq("shipped")
    end

    it "returns an error when missing required fields" do 
      invalid_invoice_params = {
        merchant_id: @merchant1.id,
        status: "shipped"
      }

      headers = { "CONTENT_TYPE" => "application/json" }

      post "/api/v1/merchants/#{@merchant1.id}/invoices", params: invalid_invoice_params.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:errors]).to include("Customer must exist")
    end

    it "returns an error when the merchant does not exist" do
      invoice_params = {
        customer_id: @customer1.id,
        merchant_id: 999999, 
        status: "shipped"
      }

      headers = { "CONTENT_TYPE" => "application/json" }

      post "/api/v1/merchants/999999/invoices", params: invoice_params.to_json, headers: headers

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:errors]).to include("Couldn't find Merchant with 'id'=999999")
    end
  end
end
