class OrdersController < ApplicationController
around_filter :shopify_session
before_filter :check_order_owner, :except =>[:index,:search_orders]
  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.find(:all,:conditions => ["shopify_owner = ? ",current_shop.url])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
    end
  end
 
  # GET /orders/1
  # GET /orders/1.json
  def show
   
    @order = Order.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    
   end 
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
  	 redirect_to orders_url
#    @order = Order.new

#    respond_to do |format|
#      format.html # new.html.erb
#      format.json { render json: @order }
#    end
  end

  # GET /orders/1/edit
  def edit
    	redirect_to orders_url
#    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.json
  def create
    	redirect_to orders_url
#    @order = Order.new(params[:order])

#    respond_to do |format|
#      if @order.save
#        format.html { redirect_to @order, notice: 'Order was successfully created.' }
#        format.json { render json: @order, status: :created, location: @order }
#      else
#        format.html { render action: "new" }
#        format.json { render json: @order.errors, status: :unprocessable_entity }
#      end
#    end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    	redirect_to orders_url
#    @order = Order.find(params[:id])

#    respond_to do |format|
#      if @order.update_attributes(params[:order])
#        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
#        format.json { head :no_content }
#      else
#        format.html { render action: "edit" }
#        format.json { render json: @order.errors, status: :unprocessable_entity }
#      end
#    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(:conditions => ["id = ? and shopify_owner = ?", params[:id],current_shop.url])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end
  
  
  def search_orders
   startdate = params[:startdate].blank? ?  (Date.today - 7.days) : params[:startdate]
   enddate = params[:enddate].blank? ?  Date.today : params[:enddate] 
      
   @orders = Order.find(:all,:conditions => ["shopify_owner = ? AND order_date > ? AND order_date <= ? ",current_shop.url,startdate.to_date,enddate.to_date])
   if @orders
   respond_to do |format|
      format.html 
    end
   else
   
   request.referer 
   end
  end
  
end
