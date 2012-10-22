class HomeController < ApplicationController
  #skip_filter :ensure_merchant_has_paid
  around_filter :shopify_session
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
  
  def checkjob
       @job = Delayed::Job.find_by_id(params[:job_id])
      # puts "JOB ID: #{params[:job_id]}"
      # puts "LOOKING INTO JOB: #{@job.inspect}"
       if @job.nil?
         # The job has completed and is no longer in the database.
         render :text => "OK"
       else
         if @job.last_error.nil?
           # The job is still in the queue and has not been run.
           render :text => "WORKING"
         else
           # The job has encountered an error.
           render :text => "ERROR"
         end
       end
   end
   
  def welcome
     
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    #current_host = "http://#{request.host+request.fullpath}"
    @callback_url = "http://#{current_host}/login/finalize"
  end
  
  def index
    #puts session[:shopifyshop].inspect

    ###### Check shopify store currency format
if session[:shopifyshop].blank?
    @existing_store = Shopifystores.where(:shopify_owner => session[:shopify].url).first
    #puts @existing_store.inspect
      
    if @existing_store.blank?
      #puts "NOT IN DB - ADDING STORE TO DB"
      @mystore = ShopifyAPI::Shop.current
       #puts "NOT IN DB - ADDING STORE TO DB2"
         #puts @mystore.inspect
         #puts @mystore.money_format.chomp("{{amount}}").html_safe
         coder = HTMLEntities.new
         #puts coder.decode(@mystore.money_format.chomp("{{amount}}")) 

    @shopifystore = Shopifystores.new
    @shopifystore.currency = coder.decode(@mystore.money_format.chomp("{{amount}}"))  
    @shopifystore.shopify_owner = @mystore.myshopify_domain  
    @shopifystore.name = @mystore.name
    @shopifystore.taxesincluded = @mystore.taxes_included
    @shopifystore.shopifyplan = @mystore.plan_name
    @shopifystore.email = @mystore.email
    d = Time.now.strftime("%F %H:%M")
    @shopifystore.lastorderupdate = d
    @shopifystore.save
    
    session[:shopifyshop] = nil
    session[:shopifyshop] ||= {}
    session[:shopifyshop][:currency] = coder.decode(@mystore.money_format.chomp("{{amount}}"))  
    session[:shopifyshop][:name] = @mystore.name
    session[:shopifyshop][:charged] = false
    session[:shopifyshop][:lastupdate] = Time.now.strftime("%F %H:%M")

    else
    #puts "NOT ADDING STORE TO DB"
    #puts @existing_store.inspect
    session[:shopifyshop] = nil
    session[:shopifyshop] ||= {}	
    session[:shopifyshop][:currency] = @existing_store.currency
    session[:shopifyshop][:name] = @existing_store.name
    session[:shopifyshop][:charged] = false
    if @existing_store.lastorderupdate.blank?
       session[:shopifyshop][:lastupdate] = Datetime.now.strftime("%F %H:%M")
    else
      session[:shopifyshop][:lastupdate] = @existing_store.lastorderupdate
    end
    end 
    delayedjoborderfetchstart
end
    ##### End Check shopify store currency format
   # if @existing_store.blank?
    #  delayedjoborderfetchstart
    #end
      check_orders(Time.now.year)     
 end
 
 def delayedjoborderfetch
    fetchorders = Delayedorderfetch.new
     @job_id = fetchorders.delay.perform(session[:shopifyshop][:lastupdate],session[:shopify].url,session[:shopify])
     redirect_to :action => 'index', :job_id => @job_id.id
 end
 
 def delayedjoborderfetchstart
    fetchorders = Delayedorderfetch.new
     @job_id = fetchorders.delay.perform(session[:shopifyshop][:lastupdate],session[:shopify].url,session[:shopify])
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
   
   @lastorderid = Order.find_by_sql("select max(shopify_order_id) as shopifyorderid from orders where shopify_owner= '#{current_shop.url}'")

  @lastorderid.each do |topid|
    @shopifysinceid = topid.shopifyorderid
    puts "Last order ID: #{topid.shopifyorderid}"
  end
       @orderscount = ShopifyAPI::Order.count(:status => "any", :since_id => @shopifysinceid)
       if @orderscount > 0
         @page = 1
         #@noofpages = @orderscount.divmod(250).first
         @noofpages = (@orderscount.div(250) + 1)
         puts "Total Pages: #{@noofpages}" 
         puts "Order Count: #{@orderscount}" 
        while @page <= @noofpages
            puts "Current Page #{@page }"
           @orders.blank? ? @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 250, :page => 1, :since_id => @shopifysinceid, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,fulfillment_status,line_items,cancel_reason,subtotal_price,total_tax,cancelled_at,gateway,processing_method" }) : @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :since_id => @shopifysinceid, :page => @page, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,fulfillment_status,line_items,cancel_reason,subtotal_price,total_tax,cancelled_at,gateway,processing_method" })
          @page += 1
         end
       end   
       
       if @orders 

       @orders.each do |shop_order| 

       @existing_order = Order.where(:shopify_order_id => shop_order.id, :shopify_name => shop_order.name)

       if @existing_order.blank?

       if shop_order.financial_status = "authorized" or shop_order.financial_status = "paid"  then 

       #	 if shop_order.cancel_reason.nil? 
           shop_order.line_items.each do |line_item| 
             @order= Order.new
             @order.shopify_order_id = shop_order.id
             @order.shopify_name = shop_order.name
             @order.order_date = shop_order.created_at
             @order.no_of_items =line_item.quantity
             @order.price = line_item.price
             @order.vendor_name = line_item.vendor
             @order.shopify_owner = current_shop.url
             @order.shipped_status = line_item.fulfillment_status
             @order.paid_status = shop_order.financial_status
             @order.subtotal_price = shop_order.subtotal_price
             @order.total_tax = shop_order.total_tax
             @order.cancelled_at = shop_order.cancelled_at
             @order.gateway = shop_order.gateway
             @order.processing_method = shop_order.processing_method
             @order.save
            end 
       	# else 
       	   # Cancelled Order
        # end 
          end 
          end
        end 
      end
      # Check for any orders UPDATED since last order fetch START
       puts  session[:shopifyshop][:lastupdate]
       @orders =  nil
       @orderscount = ShopifyAPI::Order.count(:updated_at_min => session[:shopifyshop][:lastupdate])
       puts @orderscount
       if @orderscount > 0
         @page = 1
         @noofpages = (@orderscount.div(250) + 1)
         puts "Total updated Pages: #{@noofpages}" 
         puts "Order updated Count: #{@orderscount}" 
        while @page <= @noofpages
            puts "Current updated Page #{@page }"
           @orders.blank? ? @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 250, :page => 1, :updated_at_min => session[:shopifyshop][:lastupdate], :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,fulfillment_status,line_items,cancel_reason,subtotal_price,total_tax,cancelled_at,gateway,processing_method" }) : @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :updated_at_min => session[:shopifyshop][:lastupdate], :page => @page, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,fulfillment_status,line_items,cancel_reason,subtotal_price,total_tax,cancelled_at,gateway,processing_method" })
          @page += 1
         end
       end
       
        if @orders 

        @orders.each do |shop_order|
          
        #  puts shop_order.inspect
        Order.update_all({:shipped_status => shop_order.fulfillment_status, :paid_status => shop_order.financial_status, :cancelled_at => shop_order.cancelled_at}, ["shopify_order_id = ?", shop_order.id])
        end
      end
        puts  session[:shopifyshop][:lastupdate]
        @existing_store = nil
        @existing_store = Shopifystores.where(:shopify_owner => session[:shopify].url).first
        puts  @existing_store.inspect
        @existing_store.lastorderupdate = Time.now.strftime("%F %H:%M")
        @existing_store.save
         session[:shopifyshop][:lastupdate] =  Time.now.strftime("%F %H:%M")
      # Check for any orders updated since last order fetch END
      #return true
     redirect_to :action => 'index'
 end
 #handle_asynchronously :pull_all_orders
 

  def select_orders_of_year
    if params[:year]
    check_orders(params[:year])
    render :partial => 'select_orders' 
    else
    redirect_to home_url
    end
  end

#private

def check_orders(yr)
      @o_years = Order.find_by_sql("select DISTINCT(extract(year from order_date))as year_list from orders where shopify_owner= '#{current_shop.url}'")
      @order_year = []
      @o_years.each do |oy|
      @order_year << oy.year_list
      end
      
      @local_orders = Order.find_by_sql("Select extract(year from order_date) as year_list, extract(month from order_date) as month_list, vendor_name,sum(price * no_of_items) as totcost from orders where shopify_owner = '#{current_shop.url}' and extract(year from order_date) = #{yr} and cancelled_at is null group by year_list,month_list,vendor_name")
      
      @local_vendors = Order.find_by_sql("select DISTINCT(vendor_name) as vendor from orders where shopify_owner= '#{current_shop.url}' order by vendor_name"  )
      @months=["Jan","Feb","Mar","Apr","May","June","July","Aug","Sep","Oct","Nov","Dec"]
end
 
  
end
