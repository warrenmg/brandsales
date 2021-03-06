class ApplicationController < ActionController::Base
  protect_from_forgery
  
  prepend_around_filter :shopify_session
  before_filter :ensure_merchant_has_paid, :except => 'confirm', :except => 'login'
    
    def ensure_merchant_has_paid
      #  puts 'Shop been charged?' + session[:shopifyshop][:charged].to_s
      if session[:shopifyshop].blank?
           session[:shopifyshop] ||= {}
           session[:shopifyshop][:charged] = false
      end
       # puts "CHECKING FOR CHARGE"
        if session[:shopifyshop][:charged] == false
        #    puts "CHECKING FOR CHARGE"
        shopify_session do 
        #  puts "Shopify Session Check"
          unless ShopifyAPI::RecurringApplicationCharge.current
             
          #   puts "START CHARGE"
             charge = ShopifyAPI::RecurringApplicationCharge.create(:name => "Basic Plan", 
                                                               :price => 3.0, 
                                                               :trial_days => 7,
                                                               :return_url => 'http://brandsales.78e.co.uk/charge/confirm')
           redirect_to ShopifyAPI::RecurringApplicationCharge.pending.first.confirmation_url #charge.confirmation_url
          else
            # puts "SETTING CHARGED TO TRUE"
             #:return_url => 'http://brandsales.78e.co.uk/charge/confirm', 
             #,:test => true
             session[:shopifyshop][:charged] = true
          end
        
   end
 end
      #rescue
       # puts "PROBELM WITH CHARGE" 
      #  redirect_to login_path
    end
 
 def check_order_owner
  order = Order.find(params[:id])
  if order
  	if order.shopify_owner == shop_session.url
  	   return true
  	end
  end
  
  if (order.blank? or order.shopify_owner != shop_session.url)
  	redirect_to orders_url
  end
  
  rescue Exception => e
  logger.error("********************** Invalid access of order *********************")
  logger.error(e.message)
  logger.error("********************** Invalid access of order *********************")
  redirect_to orders_url
 end
 
end
