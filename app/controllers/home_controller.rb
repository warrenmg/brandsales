class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => 'welcome'
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
  
  def welcome
     
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    #current_host = "http://#{request.host+request.fullpath}"
    @callback_url = "http://brandsales.herokuapp.com/login/finalize"
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
      @orders.each do |shop_order| 
      @order= Order.new
      @existing_order = Order.where(:shopify_order_id => shop_order.id, :shopify_name => shop_order.name)
      if @existing_order.blank?
      if shop_order.financial_status = "authorized" or shop_order.financial_status = "paid"  then 

      	 if shop_order.cancel_reason.nil? 
          shop_order.line_items.each do |line_item| 
            @vend["totalsales"] += (line_item.price.to_i * line_item.quantity).to_f  
            @order.shopify_order_id = shop_order.id
            @order.shopify_name = shop_order.name
            @order.order_date = shop_order.created_at
            @order.no_of_items =line_item.quantity
            @order.price = line_item.price
            @order.vendor_name = line_item.vendor
            @order.shopify_owner=current_shop.url
             @order.save
#             render :text =>   line_item.vendor and return 
           # @vend[line_item.vendor].nil? ? @vend[line_item.vendor] = (line_item.price.to_i * line_item.quantity) : @vend[line_item.vendor] += (line_item.price.to_i * line_item.quantity.to_d) 
           #@vend[line_item.vendor][order.created_at.to_date.strftime("%m")].nil? ? @vend[line_item.vendor][order.created_at.to_date.strftime("%m")] = (line_item.price.to_d * line_item.quantity.to_d) : @vend[line_item.vendor][order.created_at.to_date.strftime("%m")] += (line_item.price.to_d * line_item.quantity.to_d)
                line_item.price.blank? ? line_item.price = (line_item.price.to_i * line_item.quantity).to_s : line_item.price += (line_item.price.to_i * line_item.quantity).to_s 
           #@vend[line_item.vendor][order.created_at.to_date.strftime("%m")].nil? ? @vend[line_item.vendor][order.created_at.to_date.strftime("%m")] = (line_item.price.to_d * line_item.quantity.to_d) : @vend[line_item.vendor][order.created_at.to_date.strftime("%m")] += (line_item.price.to_d * line_item.quantity.to_d)
      			@vend["ordercount"] += line_item.quantity.to_i 
      		  end 
      	 else 
      		@vend["ordercancelled"] += 1
       	 end 
         end 
         end
       end 

      @order_cancel_perc = (@vend["ordercancelled"].to_i / @orders.size.to_f * 100)
      @orderactive = (@orders.size - @vend["ordercancelled"]).to_i
      
       @o_years = Order.find_by_sql("select DISTINCT(year(order_date)) year_list from orders where shopify_owner= '#{current_shop.url}'")
      if @o_years
      @order_year = []
      @o_years.each do |oy|
      @order_year << oy.year_list
      end
      end
      check_orders(Time.now.year)


            
 end
 
  def initial_pull
    puts "Initial Pul Enteringggggg"
    @orders = ShopifyAPI::Order.find(:all, :params => {:status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" })
    
    @orders.each do |shop_order| 
      @order= Order.new
      @existing_order = Order.where(:shopify_order_id => shop_order.id, :shopify_name => "#{shop_order.name}")
      puts "##########"
      puts @exitsing_order.inspect
      puts shop_order.id.class.inspect
      puts shop_order.name.class.inspect
      puts Order.all.inspect
      puts "##########"
      if @existing_order.blank? 
      puts "order creatingggggggggggg"
      if shop_order.financial_status = "authorized" or shop_order.financial_status = "paid"  then 

      	 if shop_order.cancel_reason.nil? 
          shop_order.line_items.each do |line_item| 
           
            @order.shopify_order_id = shop_order.id
            @order.shopify_name = shop_order.name
            @order.order_date = shop_order.created_at
            @order.no_of_items =line_item.quantity
            @order.price = line_item.price
            @order.vendor_name = line_item.vendor
            @order.shopify_owner=current_shop.url
             @order.save
        puts "Order Createddddddddddddddddddddddd"
        
       	 end ######### shop_order.line_items.each do
         end  ########if shop_order.cancel_reason.nil? 
         end  ###########if shop_order.financial_status = "authorized" or shop_order.financial_status = "paid"  then 
       end ######### if @existing_order
     end  #####@orders.each do 
#     rescue Exception => e
#     logger.error("*******************Access Denied****************************")
#     logger.error(e.message)
#     logger.error("*******************Access Denied****************************")
     redirect_to orders_url
 end   

  def select_orders_of_year
    if params[:year]
    check_orders(params[:year])
    render :partial => 'select_orders' 
    else
    redirect_to home_url
    end
  end

private

def check_orders(year)
          
      @o_years = Order.find_by_sql("select DISTINCT(year(order_date)) year_list from orders where shopify_owner= '#{current_shop.url}'")
      @order_year = []
      @o_years.each do |oy|
      @order_year << oy.year_list
      end
      #params[:year_var]
       puts "############################################################"
      
    #  @local_orders = Order.find_by_sql("Select year(order_date) year, month(order_date) month, vendor_name,sum(price * no_of_items) totCost from orders where shopify_owner = '#{current_shop.url}' and year(order_date) ='#{year}' group by year,month,vendor_name")
      puts @local_orders.inspect
      
      
     #  @local_vendors = Order.find_by_sql("select DISTINCT(vendor_name) vendor from orders where shopify_owner= '#{current_shop.url}'")
       @prices = Array.new
       @months=["Jan","Feb","Mar","Apr","May","June","July","Aug","Sep","Oct","Nov","Dec"]
       
end
 
  
end
