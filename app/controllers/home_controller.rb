class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => 'welcome'
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
  
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login/finalize"
  end
  
  def index
    # get 3 products
   # @products = ShopifyAPI::Product.find(:all, :params => {:limit => 3})

    # get latest 3 orders
   # @orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 3, :order => "created_at DESC" })
    
    # get latest 100 orders
    
   if params[:orderfilter][:startdate].blank? then
           @orderstart = "2012-08-01 00:00"
   else
         @orderstart =  params[:orderfilter][:startdate].to_time.strftime('%Y-%m-%d')
   end
   if params[:orderfilter][:enddate].blank? then
         @orderend= "2015-08-01 00:00"
   else
         @orderend = params[:orderfilter][:enddate].to_time.strftime('%Y-%m-%d')
   end

      @orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 250, :created_at_min =>  @orderstart, :created_at_max => @orderend, :page => 1, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" })
     # @orders   += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :page => 2, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" })
     # @orders   += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :page => 3, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" })
 
 
  end
  
end