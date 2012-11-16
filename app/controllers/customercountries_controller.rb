class CustomercountriesController < ApplicationController
  around_filter :shopify_session

def index
     check_orders_customercountries(Time.now.year)
     
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

   def check_orders_customercountries(yr)
      @o_years = Order.find_by_sql("select DISTINCT(extract(year from order_date))as year_list from orders where shopifystores_id= '#{session[:shopifyshop][:storeid]}'")
      @order_year = []
      @o_years.each do |oy|
         @order_year << oy.year_list
      end

      @local_orders = Order.find_by_sql("Select extract(year from order_date) as year_list, extract(month from order_date) as month_list, customers.country,SUM(CASE WHEN taxes_included = true THEN price ELSE price + (total_tax /  (subtotal_price / price))  END) as taxesincludedtotal, sum(price * no_of_items) as totcost,SUM(CASE WHEN taxes_included = false THEN price ELSE price-(total_tax /  (subtotal_price / price))  END) as notaxestotal,sum(total_tax /  (subtotal_price / price)) as totaltax from orders, customers where orders.customer_id = customers.shopify_customer_id and orders.shopifystores_id = '#{session[:shopifyshop][:storeid]}' and orders.price > 0 and orders.subtotal_price > 0 and extract(year from orders.order_date) = #{yr} and orders.cancelled_at is null group by year_list,month_list,customers.country order by customers.country")
      @local_vendors = Order.find_by_sql("select DISTINCT(customers.country) as country from customers, orders where orders.customer_id = customers.shopify_customer_id and orders.subtotal_price > 0 and orders.cancelled_at is null and orders.shopifystores_id= '#{session[:shopifyshop][:storeid]}' order by customers.country"  )
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
 
end
