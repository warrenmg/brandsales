class ChargeController < ApplicationController
  #around_filter :shopify_session
  skip_filter :ensure_merchant_has_paid
  
  def confirm
    
    puts "CHARGE TO BE SAVED TO LOCAL DB QQ"
      # the old method of checking for params[:accepted] is deprecated.
      ShopifyAPI::RecurringApplicationCharge.find(params[:charge_id]).activate
      # update local data store
      session[:shopifyshop][:charged] = true
        redirect_to home_url
  end



end