class CurrenciesController < ApplicationController
  def set_currency
    currency = params[:currency]
    
    # Validate currency
    if ['USD', 'CAD', 'INR', 'GBP'].include?(currency)
      session[:currency] = currency
    end
    
    # Redirect back to the previous page with a refresh parameter
    redirect_to request.referer || root_path, notice: "Currency updated to #{currency}"
  end
end 