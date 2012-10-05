class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #around_filter :shopify_session
 
 def check_order_owner
  order = Order.find(params[:id])
  if order
  	if order.shopify_owner == current_shop.url
  	   puts "@@@@@@@@@@@@@@@@@@@@@@@@"
  	   return true
  	end
  end
  
  if (order.blank? or order.shopify_owner != current_shop.url)
  	redirect_to orders_url
  end
  
  rescue Exception => e
  logger.error("********************** Invalid access of order *********************")
  logger.error(e.message)
  logger.error("********************** Invalid access of order *********************")
  redirect_to orders_url
 end
 
end
