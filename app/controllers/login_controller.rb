class LoginController < ApplicationController
<<<<<<< HEAD
skip_filter :shopify_session
skip_filter :ensure_merchant_has_paid

  def index
    # Ask user for their #{shop}.myshopify.com address
=======
  def index
    # Ask user for their #{shop}.myshopify.com address
    
>>>>>>> 08b4468b937244d1515642d031f20333c00e2fde
    # If the #{shop}.myshopify.com address is already provided in the URL, just skip to #authenticate
    if params[:shop].present?
      redirect_to authenticate_path(:shop => params[:shop])
    end
  end
<<<<<<< HEAD
  
=======

>>>>>>> 08b4468b937244d1515642d031f20333c00e2fde
  def authenticate
    if params[:shop].present?
      redirect_to ShopifyAPI::Session.new(params[:shop].to_s.strip).create_permission_url
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
<<<<<<< HEAD
    shopify_session = ShopifyAPI::Session.new(params[:shop], params[:t],params)
    
=======
    shopify_session = ShopifyAPI::Session.new(params[:shop], params[:t], params)
>>>>>>> 08b4468b937244d1515642d031f20333c00e2fde
    if shopify_session.valid?
      session[:shopify] = shopify_session
      flash[:notice] = "Logged in to shopify store."
      
<<<<<<< HEAD
   redirect_to return_address
     puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
     puts return_address.inspect
     puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
     session[:return_to] = nil
=======
      redirect_to return_address
      session[:return_to] = nil
>>>>>>> 08b4468b937244d1515642d031f20333c00e2fde
    else
      flash[:error] = "Could not log in to Shopify store."
      redirect_to :action => 'index'
    end
  end
  
  def logout
    session[:shopify] = nil
<<<<<<< HEAD
    session[:shopifyshop] =  nil
    flash[:notice] = "Successfully logged out."
=======
    flash[:notice] = "Successfully logged out."
    
>>>>>>> 08b4468b937244d1515642d031f20333c00e2fde
    redirect_to :action => 'index'
  end
  
  protected
  
  def return_address
<<<<<<< HEAD
  puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  puts root_url.inspect
  puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
   session[:return_to] || root_url
  # session[:return_to] || BASE_URL
=======
    session[:return_to] || root_url
>>>>>>> 08b4468b937244d1515642d031f20333c00e2fde
  end
end
