require 'rails_helper'

RSpec.describe "Merchant Coupons API", type: :request do
  before(:each) do
    @merchant = Merchant.create!(name: "Test Merchant")
    @coupon1 = @merchant.coupons.create!(
      name: "Spring Sale", 
      code: "SPRING50", 
      discount_value: 50, 
      discount_type: "percent", 
      active: true
      )
    @coupon2 = @merchant.coupons.create!(
      name: "$20 off!", 
      code: "TAKE20", 
      discount_value: 20, 
      discount_type: "dollar", 
      active: true
      )
  end

  describe "GET /api/v1/merchants/:merchant_id/coupons" do
    it "returns all coupons for a merchant" do 
      get "/api/v1/merchants/#{@merchant.id}/coupons"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data].size).to eq(2)

      expect(json[:data][0][:attributes][:name]).to eq("Spring Sale")
      expect(json[:data][1][:attributes][:name]).to eq("$20 off!")

      expect(json[:data][0][:attributes][:discount_type]).to eq("percent")
      expect(json[:data][1][:attributes][:discount_type]).to eq("dollar")
    end

    it "returns an error if the merchant does not exist" do 
      get "/api/v1/merchants/2222222/coupons"

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json).to have_key(:message)
      expect(json[:message]).to eq("Your query could not be completed")

      expect(json).to have_key(:errors)
      expect(json[:errors]).to be_an(Array)
      expect(json[:errors]).to include("Couldn't find Merchant with 'id'=2222222")
    end

    it "returns an empty array if the merchant has no coupons" do 
      no_coupons = Merchant.create!(name: "New Merchant")

      get "/api/v1/merchants/#{no_coupons.id}/coupons"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data]).to eq([])
    end

    it "returns only active coupons when status=active is passed" do
      @coupon2.update(active: false)

      get "/api/v1/merchants/#{@merchant.id}/coupons?status=active"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data].size).to eq(1)
      expect(json[:data][0][:attributes][:name]).to eq("Spring Sale")
      expect(json[:data][0][:attributes][:active]).to eq(true)

    end

    it "returns only inactive coupons when status=inactive is passed" do
      @coupon1.update(active: false)

      get "/api/v1/merchants/#{@merchant.id}/coupons?status=inactive"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data].size).to eq(1) # Only 1 inactive coupon should be returned
      expect(json[:data][0][:attributes][:name]).to eq("Spring Sale")
      expect(json[:data][0][:attributes][:active]).to eq(false)
    end

    it "returns all coupons when no status param is given" do
      get "/api/v1/merchants/#{@merchant.id}/coupons"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data].size).to eq(2)
    end
  end

  describe "GET /api/v1/merchants/:merchant_id/coupons/:id" do
    it "returns a specific percent coupon by ID" do 
      get "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data][:id]).to eq(@coupon1.id.to_s)
      expect(json[:data][:attributes][:name]).to eq("Spring Sale")
      expect(json[:data][:attributes][:code]).to eq("SPRING50")
      expect(json[:data][:attributes][:discount_value]).to eq("50.0")
      expect(json[:data][:attributes][:discount_type]).to eq("percent")
      expect(json[:data][:attributes][:active]).to eq(true)
    end
    
    it "returns a specific dollar coupon by ID" do 
      get "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon2.id}"
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:data][:id]).to eq(@coupon2.id.to_s)
      expect(json[:data][:attributes][:name]).to eq("$20 off!")
      expect(json[:data][:attributes][:code]).to eq("TAKE20")
      expect(json[:data][:attributes][:discount_value]).to eq("20.0") 
      expect(json[:data][:attributes][:discount_type]).to eq("dollar")
      expect(json[:data][:attributes][:active]).to eq(true)
    end
    
    it "returns an error if the coupon does not exist" do 
      get "/api/v1/merchants/#{@merchant.id}/coupons/2222222"
      
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to include("Coupon not found for this merchant")
    end
    
    it "returns a coupon with the correct attributes" do 
      get "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data]).to have_key(:id)
      expect(json[:data][:id]).to eq(@coupon1.id.to_s)

      expect(json[:data]).to have_key(:type)
      expect(json[:data][:type]).to eq("coupon")

      expect(json[:data]).to have_key(:attributes)
      expect(json[:data][:attributes]).to be_a(Hash)

      expect(json[:data][:attributes]).to have_key(:name)
      expect(json[:data][:attributes][:name]).to eq(@coupon1.name)

      expect(json[:data][:attributes]).to have_key(:code)
      expect(json[:data][:attributes][:code]).to eq(@coupon1.code)

      expect(json[:data][:attributes]).to have_key(:discount_value)
      expect(json[:data][:attributes][:discount_value]).to eq(@coupon1.discount_value.to_s) # Since JSONAPI converts numbers to strings

      expect(json[:data][:attributes]).to have_key(:discount_type)
      expect(json[:data][:attributes][:discount_type]).to eq(@coupon1.discount_type)

      expect(json[:data][:attributes]).to have_key(:active)
      expect(json[:data][:attributes][:active]).to eq(@coupon1.active)
    end
  end

  describe "POST /api/v1/merchants/:merchant_id/coupons" do 
    it "creats a new coupon for a merchant" do 
      coupon_params = {
        "name": "Big Summer Blowout",
        "code": "OAKENSAUNA",
        "discount_value": 50,
        "discount_type": "percent",
        "active": true
      }
      
      headers = { "CONTENT_TYPE" => "application/json"}
      
      post "/api/v1/merchants/#{@merchant.id}/coupons", params: coupon_params.to_json, headers: headers
      
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:data][:attributes][:name]).to eq("Big Summer Blowout")
      expect(json[:data][:attributes][:code]).to eq("OAKENSAUNA")
      expect(json[:data][:attributes][:discount_value]).to eq("50.0")
      expect(json[:data][:attributes][:discount_type]).to eq("percent")
      expect(json[:data][:attributes][:active]).to eq(true)
    end
    
    it "returns an error message when trying to create a duplicate coupon" do 
      coupon_params = {
        name: "Spring Sale", 
        code: "SPRING50", 
        discount_value: 50, 
        discount_type: "percent", 
        active: true
      }
      
      headers = { "CONTENT_TYPE" => "application/json"}
    
      post "/api/v1/merchants/#{@merchant.id}/coupons", params: coupon_params.to_json, headers: headers
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to include("Merchant already has this coupon")
    end
  end

  describe "PATCH /api/v1/merchants/:merchant_id/coupons/id" do
    it "successfully updates a coupon to deactivate status" do 
      patch "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon1.id}", params: { active: false }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body, symbolize_names: true)

      expect(json[:data][:attributes][:active]).to eq(false)
    end

    it "successfully updates a coupon to active stats" do 
      inactive_coupon = @merchant.coupons.create!(
        name: "Star Wars Day",
        code: "MAYTHEFOURTH",
        discount_value: 66,
        discount_type: "dollar",
        active: false
      )

      expect(inactive_coupon.active).to eq(false)

      patch "/api/v1/merchants/#{@merchant.id}/coupons/#{inactive_coupon.id}", params: { active: true }
      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:ok)
      expect(json[:data][:attributes][:active]).to eq(true)
    end

    it "returns a 404 if the coupon does not exist" do 
      patch "/api/v1/merchants/#{@merchant.id}/coupons/2222222", params: {active: false}

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:errors]).to include("Coupon not found for this Merchant")
    end

    it "returns a 422 if trying to deactivate a coupon with pending invoices" do 
      customer = Customer.create!(first_name: "Austin", last_name: "Powers")
      invoice = Invoice.create!(
        customer_id: customer.id, 
        merchant_id: @merchant.id, 
        coupon_id: @coupon1.id, 
        status: "pending"
      )

      patch "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon1.id}", params: { active: false }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to include("Cannot deactivate a coupon on a pending invoice")
    end

    it "returns a 422 if trying to activate a coupon when merchant already has 5 active coupons" do
      5.times do |i|
        @merchant.coupons.create!(
          name: "Active Coupon #{i}",
          code: "ACTIVE#{i}",
          discount_value: 10,
          discount_type: "percent",
          active: true
        )
      end

      patch "/api/v1/merchants/#{@merchant.id}/coupons/#{@coupon1.id}", params: { active: true }

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:errors]).to include("Merchant can only have 5 active coupons at a time")
    end
  end
end
