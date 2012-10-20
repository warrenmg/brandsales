class ApplicationController < ActionController::Base
  protect_from_forgery
  
  prepend_around_filter :shopify_session
  before_filter :ensure_merchant_has_paid, :except => 'confirm', :except => 'pull_all_orders', :except => 'login'
    
    def ensure_merchant_has_paid
      #  puts 'Shop been charged?' + session[:shopifyshop][:charged].to_s
      if session[:shopifyshop].blank?
           session[:shopifyshop] ||= {}
      end
       # puts "CHECKING FOR CHARGE"
        if session[:shopifyshop][:charged] == false
        #    puts "CHECKING FOR CHARGE"
        shopify_session do 
        #  puts "Shopify Session Check"
          unless ShopifyAPI::RecurringApplicationCharge.current
             
          #   puts "START CHARGE"
             charge = ShopifyAPI::RecurringApplicationCharge.create(:name => "Basic plan", 
                                                               :price => 2.0, 
                                                               :return_url => 'http://brandsales.78e.co.uk/charge/confirm',:test => true)
           redirect_to ShopifyAPI::RecurringApplicationCharge.pending.first.confirmation_url #charge.confirmation_url
          else
            # puts "SETTING CHARGED TO TRUE"
             session[:shopifyshop][:charged] = true
          end
        
   end
 end
      #rescue
       # puts "PROBELM WITH CHARGE" 
      #  redirect_to login_path
    end
    
    # ,:test => true
 
 def check_order_owner
  order = Order.find(params[:id])
  if order
  	if order.shopify_owner == current_shop.url
  	   #puts "@@@@@@@@@@@@@@@@@@@@@@@@"
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
