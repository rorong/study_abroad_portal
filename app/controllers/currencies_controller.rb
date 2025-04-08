class CurrenciesController < ApplicationController
  def set_currency
    currency = params[:currency]
    
    # Validate currency against the full list
    valid_currencies = ['USD', 'GBP', 'CAD', 'EUR', 'AED', 'SGD', 'AUD', 'NZD', 'JPY', 'CHF', 'THB', 'MYR', 'CNY', 'HKD', 'INR']
    
    if valid_currencies.include?(currency)
      session[:currency] = currency
    end
    
    # Redirect back to the previous page with a refresh parameter
    redirect_to request.referer || root_path, notice: "Currency updated to #{currency}"
  end
end 