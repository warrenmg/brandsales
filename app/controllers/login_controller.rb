class LoginController < ApplicationController
skip_filter :shopify_session
skip_filter :ensure_merchant_has_paid

  def index
    # Ask user for their #{shop}.myshopify.com address
    # If the #{shop}.myshopify.com address is already provided in the URL, just skip to #authenticate
    if params[:shop].present?
      redirect_to authenticate_path(:shop => params[:shop])
    end
  end
  
  def authenticate
   # if params[:shop].present?
   if shop_name = sanitize_shop_param(params)
      #redirect_to ShopifyAPI::Session.new(params[:shop].to_s.strip).create_permission_url
      redirect_to "/auth/shopify?shop=#{shop_name}"
    else
      redirect_to return_address
    end
  end
  
  # Shopify redirects the logged-in user back to this action along with
  # the authorization token t.
  # 
  # This token is later combined with the developer's shared secret to form
  # the password used to call API methods.
  def finalize
    shopify_session = ShopifyAPI::Session.new(params[:shop], params[:t],params)
    
    if shopify_session.valid?
      session[:shopify] = shopify_session
      flash[:notice] = "Logged in to shopify store."
      
      puts shopify_session
   redirect_to return_address
     puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
     puts return_address.inspect
     puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
     session[:return_to] = nil
    else
      flash[:error] = "Could not log in to Shopify store."
      redirect_to :action => 'index'
    end
  end
  
  def logout
    session[:shopify] = nil
    session[:shopifyshop] =  nil
    flash[:notice] = "Successfully logged out."
    redirect_to :action => 'index'
  end
  
  protected
  
  def sanitize_shop_param(params)
      return unless params[:shop].present?
      name = params[:shop].to_s.strip
      name += '.myshopify.com' if !name.include?("myshopify.com") && !name.include?(".")
      name.sub('https://', '').sub('http://', '')
    end
  
  def return_address
  puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  puts root_url.inspect
  puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
   session[:return_to] || root_url
  # session[:return_to] || BASE_URL
  end
end
