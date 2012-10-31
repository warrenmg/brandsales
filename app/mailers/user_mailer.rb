class UserMailer < ActionMailer::Base
  default from: "support@78e.co.uk"
  
  def ordersready_email(user)
     @user = user
     @url  = "http://brandsales.78e.co.uk/login"
     mail(:to => user, :subject => "Brand Sales Report is ready")
   end
end
