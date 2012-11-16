class HomeController < ApplicationController
  #skip_filter :ensure_merchant_has_paid
  around_filter :shopify_session
  def is_a_number?(s)
    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true 
  end
  
  def checkjob
       @job = Delayed::Job.find_by_id(params[:job_id])
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
    @callback_url = "http://#{current_host}/login/finalize"
  end
  
  def index

###### Check shopify store properties
if session[:shopifyshop][:name].blank?
    @existing_store = Shopifystores.where(:shopify_owner => session[:shopify].url).first
      
    if @existing_store.blank?
         @mystore = ShopifyAPI::Shop.current
         coder = HTMLEntities.new

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
         session[:shopifyshop][:email] = @mystore.email
         session[:shopifyshop][:charged] = false
         session[:shopifyshop][:storeid] =  @shopifystore.id
         session[:shopifyshop][:lastupdate] = Time.now.strftime("%F %H:%M")
         
         @orderscount = ShopifyAPI::Order.count(:status => "any")
         if @orderscount > 0
            @estimatedtime = @orderscount.div(60)
         else
            @estimatedtime = 10
         end
    else
        session[:shopifyshop] = nil
        session[:shopifyshop] ||= {}	
        session[:shopifyshop][:currency] = @existing_store.currency
        session[:shopifyshop][:name] = @existing_store.name
        session[:shopifyshop][:email] = @existing_store.email
        session[:shopifyshop][:charged] = false
        session[:shopifyshop][:storeid] =  @existing_store.id
        if @existing_store.lastorderupdate.blank?
          session[:shopifyshop][:lastupdate] = Datetime.now.strftime("%F %H:%M")
        else
          session[:shopifyshop][:lastupdate] = @existing_store.lastorderupdate
        end
    end 
    delayedjoborderfetchstart
end
##### End Check shopify store properties

      check_orders(Time.now.year)     
      
        #@customergroupcount = ShopifyAPI::Customer.find(:all, :params => {:customer_group_id => 7792059, :limit => 250, :page => 1, :fields => "id,name" })
        #ShopifyAPI::Customer.count(:customer_group_id => 7792059)
         
 end
 
 def delayedjoborderfetch
    fetchorders = Delayedorderfetch.new
     @job_id = fetchorders.delay.perform(session[:shopifyshop][:lastupdate],session[:shopify].url,session[:shopify],session[:shopifyshop][:email],session[:shopifyshop])
     redirect_to :action => 'index', :job_id => @job_id.id
 end
 
 def delayedjoborderfetchstart
    fetchorders = Delayedorderfetch.new
     @job_id = fetchorders.delay.perform(session[:shopifyshop][:lastupdate],session[:shopify].url,session[:shopify],session[:shopifyshop][:email],session[:shopifyshop])
 end
 
 def build_years
     #@o_years = Order.find_by_sql("select DISTINCT(year(order_date)) year_list from orders where shopify_owner= '#{shop_session.url}'")
      @o_years = Order.find_by_sql("select DISTINCT(extract(year from order_date)) as year_list from orders where shopify_owner= '#{shop_session.url}'")
     if @o_years
     @order_year = []
     @o_years.each do |oy|
     @order_year << oy.year_list
     end
     end
 end
 
 
 def pull_all_orders 
  @lastorderid = Order.find_by_sql("select max(shopify_order_id) as shopifyorderid from orders where shopify_owner= '#{shop_session.url}'")

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
             @order.shopify_owner = shop_session.url
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
     redirect_to :action => 'index'
 end
 
   def select_orders_of_year_customergroups
     if params[:year]
        check_orders(params[:year])
        render :partial => 'select_orders' 
     else
        redirect_to home_url
     end
   end

 #private

    def check_orders_customergroups(yr)
       @o_years = Order.find_by_sql("select DISTINCT(extract(year from order_date))as year_list from orders where shopifystores_id= '#{session[:shopifyshop][:storeid]}'")
       @order_year = []
       @o_years.each do |oy|
          @order_year << oy.year_list
       end

       @local_orders = Order.find_by_sql("Select extract(year from order_date) as year_list, extract(month from order_date) as month_list, customergroups.name,SUM(CASE WHEN taxes_included = true THEN price ELSE price + (total_tax /  (subtotal_price / price))  END) as taxesincludedtotal, sum(price * no_of_items) as totcost,SUM(CASE WHEN taxes_included = false THEN price ELSE price-(total_tax /  (subtotal_price / price))  END) as notaxestotal,sum(total_tax /  (subtotal_price / price)) as totaltax from orders, customergroups_customers, customergroups where  orders.customer_id = customergroups_customers.customer_id and customergroups_customers.customergroup_id = customergroups.customergroup_id and shopifystores_id = '#{session[:shopifyshop][:storeid]}' and price > 0 and subtotal_price > 0 and extract(year from order_date) = #{yr} and cancelled_at is null group by year_list,month_list,customergroups.name  order by customergroups.name ")
       @local_vendors = Order.find_by_sql("select DISTINCT(vendor_name) as vendor from orders where shopify_owner= '#{shop_session.url}' order by vendor_name"  )
       @months=["Jan","Feb","Mar","Apr","May","June","July","Aug","Sep","Oct","Nov","Dec"]
    end

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
      @o_years = Order.find_by_sql("select DISTINCT(extract(year from order_date))as year_list from orders where shopifystores_id= '#{session[:shopifyshop][:storeid]}'")
      @order_year = []
      @o_years.each do |oy|
         @order_year << oy.year_list
      end
      
      @local_orders = Order.find_by_sql("Select extract(year from order_date) as year_list, extract(month from order_date) as month_list, vendor_name,SUM(CASE WHEN taxes_included = true THEN price ELSE price + (total_tax /  (subtotal_price / price))  END) as taxesincludedtotal, sum(price * no_of_items) as totcost,SUM(CASE WHEN taxes_included = false THEN price ELSE price-(total_tax /  (subtotal_price / price))  END) as notaxestotal,sum(total_tax /  (subtotal_price / price)) as totaltax from orders where shopifystores_id = '#{session[:shopifyshop][:storeid]}' and price > 0 and subtotal_price > 0 and extract(year from order_date) = #{yr} and cancelled_at is null group by year_list,month_list,vendor_name order by vendor_name")
      @local_vendors = Order.find_by_sql("select DISTINCT(vendor_name) as vendor from orders where shopifystores_id = '#{session[:shopifyshop][:storeid]}' order by vendor_name"  )
      @months=["Jan","Feb","Mar","Apr","May","June","July","Aug","Sep","Oct","Nov","Dec"]
end
 
  
end
