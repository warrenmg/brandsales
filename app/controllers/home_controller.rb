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

   #if params[:enddate].blank? then
  #       @orderend = Date.today
  # else
  #       @orderend = params[:enddate].to_time.strftime('%Y-%m-%d')
  # end
   
   @orderstart = params[:startdate].blank? ?  (Date.today - 7.days) : params[:startdate] 
   @orderend = params[:enddate].blank? ?  Date.today : params[:enddate] 
   
   @orderdiff = (@orderend.to_date - @orderstart.to_date).to_i

      @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 250, :created_at_min =>  @orderstart, :created_at_max => @orderend, :page => 1, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" })
      @orders.size > 249 ? @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :created_at_min =>  @orderstart, :created_at_max => @orderend, :page => 2, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" }) : ""
      @orders.size > 499 ? @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :created_at_min =>  @orderstart, :created_at_max => @orderend, :page => 3, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" }) : ""
      @orders.size > 749 ? @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :created_at_min =>  @orderstart, :created_at_max => @orderend, :page => 4, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" }) : "" 
      @orders.size > 999 ? @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :created_at_min =>  @orderstart, :created_at_max => @orderend, :page => 5, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" }) : "" 
      @orders.size > 1249 ? @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :created_at_min =>  @orderstart, :created_at_max => @orderend, :page => 6, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" }) : "" 
      @orders.size > 1499 ? @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :created_at_min =>  @orderstart, :created_at_max => @orderend, :page => 7, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" }) : "" 
      
      @vend = {"ordercount" => 0, "ordercancelled" => 0, "totalsales" => 0}

      @orders.each do |order| 

      if order.financial_status = "authorized" or order.financial_status = "paid"  then 
      	 if order.cancel_reason.blank? 
          order.line_items.each do |line_item| 
            @vend["totalsales"] += (line_item.price.to_d * line_item.quantity.to_d)
       			if @vend[line_item.vendor].nil? then
      				@vend[line_item.vendor] = (line_item.price.to_d * line_item.quantity.to_d)   
      			else
      			  @vend[line_item.vendor] += (line_item.price.to_d * line_item.quantity.to_d) 
      		    end
      			@vend["ordercount"] += line_item.quantity.to_i 
      		  end 
      	 else 
      		@vend["ordercancelled"] += 1
       	 end 
         end 
       end 

      @order_cancel_perc = (@vend["ordercancelled"].to_d / @orders.size.to_d * 100)
      @orderactive = (@orders.size - @vend["ordercancelled"]).to_i
       
 end
  
end