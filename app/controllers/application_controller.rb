class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #around_filter :shopify_session
  before_filter :ensure_merchant_has_paid, :except => 'confirm'
  

    # ...
    def confirm
       # the old method of checking for params[:accepted] is deprecated.
       ShopifyAPI::RecurringApplicationCharge.find(params[:charge_id]).activate
       puts "CHARGE TO BE SAVED TO LOCAL DB APPC"
       # update local data store
        redirect_to :action => root_url
     end
    

    def ensure_merchant_has_paid
        puts "CHECKING FOR CHARGE"
   shopify_session do 
      unless ShopifyAPI::RecurringApplicationCharge.current
          puts "START CHARGE"
        charge = ShopifyAPI::RecurringApplicationCharge.create(:name => "Basic plan", 
                                                               :price => 0.99, 
                                                               :return_url => 'http://0.0.0.0:3000/confirm',
                                                                                                    :test => true)
        redirect_to ShopifyAPI::RecurringApplicationCharge.pending.first.confirmation_url #charge.confirmation_url
      end
   end
      rescue 
        redirect_to login_path
    end
    

 
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
