# Fix for Devise compatibility with Rails 8
# This addresses the issue with password_digest method expecting an argument

module Devise
  module Models
    module DatabaseAuthenticatable
      # Override the password_digest method to handle the case when no argument is provided
      def password_digest(password = nil)
        if password.nil?
          # Return a default value or handle the nil case appropriately
          return nil
        else
          # Call the original method with the password
          Devise::Encryptor.digest(self.class, password)
        end
      end
    end
  end
end 