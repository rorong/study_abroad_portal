module ApplicationHelper
    def departments
      Department.all
    end
  
    def intakes
      [
        "January",
        "February", 
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ]
    end
  
    def institutions
      Institution.all
    end
  
    def statuses
      ["Active", "Inactive"]
    end
  
    def delivery_methods
      ["Full Time", "Part Time", "Online"]
    end
  
    def tags
      Tag.all
    end
    
    def back_button(default = root_path, text = 'Back')
      link_to text, request.referer || default, class: 'btn btn-secondary'
    end

    def convert_currency(amount, from_currency = 'USD', to_currency = nil)
      return amount if amount.nil?
      to_currency ||= session[:currency] || 'USD'
      return amount if from_currency == to_currency
      # Try to get exchange rates from cache or API
      exchange_rates = fetch_exchange_rates
      # Convert to USD first if not already in USD
      usd_amount = from_currency == 'USD' ? amount : amount / exchange_rates[from_currency]
      # Then convert to target currency
      converted_amount = usd_amount * exchange_rates[to_currency]
      # Round to 2 decimal places
      converted_amount.round(2)
    end
    
    def fetch_exchange_rates
      # Try to get rates from cache first
      cached_rates = Rails.cache.read('exchange_rates')
      return cached_rates if cached_rates.present?
      begin
        # Try to fetch from a free exchange rate API
        response = HTTP.get('https://api.exchangerate-api.com/v4/latest/USD')
        if response.status.success?
          data = JSON.parse(response.body.to_s)
          rates = data['rates']
          # Extract the rates we need
          exchange_rates = {
            'USD' => 1.0,
            'CAD' => rates['CAD'],
            'INR' => rates['INR'],
            'GBP' => rates['GBP']
          }
          # Cache the rates for 24 hours
          Rails.cache.write('exchange_rates', exchange_rates, expires_in: 24.hours)
          return exchange_rates
        end
      rescue => e
        Rails.logger.error("Failed to fetch exchange rates: #{e.message}")
      end
      # Fallback to hardcoded rates if API fails
      {
        'USD' => 1.0,
        'CAD' => 1.37,
        'INR' => 83.12,
        'GBP' => 0.79
      }
    end
    
    def format_currency(amount, currency = nil)
      return "N/A" if amount.nil?
      currency ||= session[:currency] || 'USD'
      case currency
      when 'USD'
        "$#{number_with_delimiter(amount)}"
      when 'CAD'
        "C$#{number_with_delimiter(amount)}"
      when 'INR'
        "₹#{number_with_delimiter(amount)}"
      when 'GBP'
        "£#{number_with_delimiter(amount)}"
      else
        "$#{number_with_delimiter(amount)}"
      end
    end

end
  