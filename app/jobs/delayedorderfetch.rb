class Delayedorderfetch 
  
  def fetchcustomers(shopifystoreid)
     @lastcustomerid = Customer.find_by_sql("select max(shopify_customer_id) as shopify_customer_id from customers where shopifystores_id=#{shopifystoreid}")

       @lastcustomerid.each do |topid|
         @shopifycustomersinceid = topid.shopify_customer_id
       end
           @customercount = ShopifyAPI::Customer.count(:status => "any", :since_id => @shopifycustomersinceid)
           if @customercount > 0
              @page = 1
              @noofpages = (@customercount.div(250) + 1)
              while @page <= @noofpages
                @customers.blank? ? @customers = ShopifyAPI::Customer.find(:all, :params => {:limit => 250, :page => 1, :since_id => @shopifycustomersinceid, :status => "any", :fields => "created_at,id,first_name,last_name,id,state,updated_at,addresses,tags" }) : @customers += ShopifyAPI::Customer.find(:all, :params => {:limit => 250, :since_id => @shopifycustomersinceid, :page => @page, :status => "any", :fields => "created_at,id,first_name,last_name,id,state,updated_at,addresses,tags" })
                @page += 1
              end
          end   

     if @customers  ###  UPDATE DATABASE WITH CUSTOMERS
        @customers.each do |shop_customer| 
            @existing_customer = Customer.where(:shopify_customer_id => shop_customer.id, :shopifystores_id => @shopifyshop[:storeid])
            if @existing_customer.blank?

                  shop_customer.addresses.each do |address| 
                    if address.default == true
                      @customer= Customer.new
                      @customer.shopifystores_id = @shopifystoreid
                      @customer.shopify_customer_id = shop_customer.id
                      @customer.first_name = shop_customer.first_name
                      @customer.last_name = shop_customer.last_name
                      @customer.country = address.country_code
                      @customer.tags = shop_customer.tags
                      @customer.save
                    end
                 end 
           end
        end 
     end  ###  UPDATE DATABASE WITH CUSTOMERS
  end

  def perform(lastorderupdate,shopifyurl,shopify_session,shopifyemail,shopifyshop)
    #puts "Is session valid? #{shopify_session.valid?}"
    ActiveResource::Base.site = shopify_session.site
    
    @shopifyshop = shopifyshop
    
    fetchcustomers(@shopifyshop.id)
    
    #puts @shopifyshop
    
    @lastorderid = Order.find_by_sql("select max(shopify_order_id) as shopifyorderid from orders where shopify_owner= '#{shopifyurl}'")

     @lastorderid.each do |topid|
       @shopifysinceid = topid.shopifyorderid
     end
         @orderscount = ShopifyAPI::Order.count(:status => "any", :since_id => @shopifysinceid)
         if @orderscount > 0
            @page = 1
            @noofpages = (@orderscount.div(250) + 1)
            while @page <= @noofpages
              @orders.blank? ? @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 250, :page => 1, :since_id => @shopifysinceid, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,fulfillment_status,line_items,cancel_reason,subtotal_price,total_tax,taxes_included,cancelled_at,gateway,processing_method,customer" }) : @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :since_id => @shopifysinceid, :page => @page, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,fulfillment_status,line_items,cancel_reason,subtotal_price,total_tax,taxes_included,cancelled_at,gateway,processing_method,customer" })
              @page += 1
            end
        end   

   if @orders  ###  22222
      @orders.each do |shop_order| 
          @existing_order = Order.where(:shopify_order_id => shop_order.id, :shopify_name => shop_order.name)
          if @existing_order.blank?
             if shop_order.financial_status = "authorized" or shop_order.financial_status = "paid"  then 
                shop_order.line_items.each do |line_item| 
                   @order= Order.new
                   @order.shopify_order_id = shop_order.id
                   @order.shopifystores_id = @shopifyshop[:storeid]
                   
                   @order.shopify_name = shop_order.name
                   @order.customer_id = shop_order.customer.id
                   @order.order_date = shop_order.created_at
                   @order.no_of_items =line_item.quantity
                   @order.price = line_item.price
                   @order.vendor_name = line_item.vendor
                   @order.shopify_owner = shopifyurl 
                   @order.shipped_status = line_item.fulfillment_status
                   @order.paid_status = shop_order.financial_status
                   @order.subtotal_price = shop_order.subtotal_price
                   @order.taxes_included = shop_order.taxes_included
                   @order.total_tax = shop_order.total_tax
                   @order.cancelled_at = shop_order.cancelled_at
                   @order.gateway = shop_order.gateway
                   @order.processing_method = shop_order.processing_method
                   @order.save
                end 
            end 
         end
      end 
   end  ###  22222
   
   if @shopifysinceid.blank?
     # Initial order download, email user when complete
      UserMailer.ordersready_email(shopifyemail).deliver
   end
   
   ### CHECK FOR UPDATED ORDERS START
         @existing_store_update = nil
         @existing_store_update = Shopifystores.where(:id => @shopifyshop[:storeid]).first
         
          #puts "My Update 1: #{@existing_store_update.lastorderupdate}"
           @orders =  nil
           @orderscount = ShopifyAPI::Order.count(:updated_at_min => @existing_store_update.lastorderupdate)
           if @orderscount > 0
             @page = 1
             @noofpages = (@orderscount.div(250) + 1)
            while @page <= @noofpages
               @orders.blank? ? @orders = ShopifyAPI::Order.find(:all, :params => {:limit => 250, :page => 1, :updated_at_min => lastorderupdate, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,fulfillment_status,line_items,cancel_reason,subtotal_price,total_tax,cancelled_at,gateway,processing_method" }) : @orders += ShopifyAPI::Order.find(:all, :params => {:limit => 250, :updated_at_min => lastorderupdate, :page => @page, :status => "any", :fields => "created_at,id,name,total-price,currency,financial_status,fulfillment_status,line_items,cancel_reason,subtotal_price,total_tax,cancelled_at,gateway,processing_method" })
              @page += 1
             end
           end

            if @orders 
               @orders.each do |shop_order|
                  Order.update_all({:shipped_status => shop_order.fulfillment_status, :paid_status => shop_order.financial_status, :cancelled_at => shop_order.cancelled_at}, ["shopify_order_id = ?", shop_order.id])
               end
            end
            @existing_store = nil
            @existing_store = Shopifystores.where(:shopify_owner => shopifyurl).first
            @existing_store.lastorderupdate = Time.now.strftime("%F %H:%M")
            @existing_store.save
  ### CHECK FOR UPDATED ORDERS END
  end

  
  def after(job)
    #puts "Finish Delayed Job
  end
  end