class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => 'welcome'
  
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login/finalize"
  end
  
  def index
    # get 3 products
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 3})

    # get latest 3 orders
   # @orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 3, :order => "created_at DESC" })
    
    # get latest 10 orders
      @orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 10, :fields => "created_at,id,name,total-price,currency,financial_status,billing_address,line_items", :order => "created_at DESC" })
  end
  
end