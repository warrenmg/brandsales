class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => 'welcome'
  
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
  
  def welcome
     
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    #current_host = "http://#{request.host+request.fullpath}"
    @callback_url = "http://#{current_host}/login/finalize"
  end
  
  def index

   #if params[:enddate].blank? then
  #       @orderend = Date.today
  # else
  #       @orderend = params[:enddate].to_time.strftime('%Y-%m-%d')
  # end
   # @orderend = params[:enddate].blank? ?  Date.today : params[:enddate] 
  # today = Date.today
  # today.to_s
  # @orderstart = Date.parse "#{today.year}-01-01" 
  # @orderend = Date.today
  # @orderdiff = (@orderend.to_date - @orderstart.to_date).to_i
  
      pull_all_orders
      
      build_years
      
      check_orders(Time.now.year)       
 end
 
 def build_years
     #@o_years = Order.find_by_sql("select DISTINCT(year(order_date)) year_list from orders where shopify_owner= '#{current_shop.url}'")
      @o_years = Order.find_by_sql("select DISTINCT(extract(year from order_date)) as year_list from orders where shopify_owner= '#{current_shop.url}'")
     if @o_years
     @order_year = []
     @o_years.each do |oy|
     @order_year << oy.year_list
     end
     end
   
 end
 
 def pull_all_orders
    @num = 250 
    @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 250, :page => 1, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" })

       if @orders
        @o_size = @orders.size
        @page = 2
         while @o_size >= @num-1 do
         @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :page => '{@page}', :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" })
         @num += 250
         @page+=1
         end
       end   

       @orders.each do |shop_order| 

       @order= Order.new
       @existing_order = Order.where(:shopify_order_id => shop_order.id, :shopify_name => shop_order.name)
       if @existing_order.blank?
       if shop_order.financial_status = "authorized" or shop_order.financial_status = "paid"  then 

       	 if shop_order.cancel_reason.nil? 
           shop_order.line_items.each do |line_item| 
             #@vend["totalsales"] += (line_item.price.to_i * line_item.quantity).to_f  
             @order.shopify_order_id = shop_order.id
             @order.shopify_name = shop_order.name
             @order.order_date = shop_order.created_at
             @order.no_of_items =line_item.quantity
             @order.price = line_item.price
             @order.vendor_name = line_item.vendor
             @order.shopify_owner=current_shop.url
             @order.save
              
             line_item.price.blank? ? line_item.price = (line_item.price.to_i * line_item.quantity).to_s : line_item.price += (line_item.price.to_i * line_item.quantity).to_s 
       		  end 
       	 else 
       	   # Nothing yet
         end 
          end 
          end
        end 

 end
 
  def initial_pull
    @orders = ShopifyAPI::Order.find(:all, :params => {:status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,line_items,cancel_reason", :order => "created_at DESC" })
    
    @orders.each do |shop_order| 
      @order= Order.new
      @existing_order = Order.where(:shopify_order_id => shop_order.id, :shopify_name => "#{shop_order.name}")
     
      if @existing_order.blank? 
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

def check_orders(yr)
          
      @o_years = Order.find_by_sql("select DISTINCT(extract(year from order_date))as year_list from orders where shopify_owner= '#{current_shop.url}'")
      @order_year = []
      @o_years.each do |oy|
      @order_year << oy.year_list
      end
      #puts @order_year.inspect
      #params[:year_var]
      # puts "############################################################"
      
      @local_orders = Order.find_by_sql("Select extract(year from order_date) as year_list, extract(month from order_date) as month_list, vendor_name,sum(price * no_of_items) as totcost from orders where shopify_owner = '#{current_shop.url}' and extract(year from order_date) = #{yr} group by year_list,month_list,vendor_name")
      
       @local_vendors = Order.find_by_sql("select DISTINCT(vendor_name) as vendor from orders where shopify_owner= '#{current_shop.url}' order by vendor_name"  )
      @months=["Jan","Feb","Mar","Apr","May","June","July","Aug","Sep","Oct","Nov","Dec"]
end
 
  
end
