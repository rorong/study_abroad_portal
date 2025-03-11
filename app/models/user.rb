class User < ApplicationRecord
  self.primary_key = 'id'
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # validates :password, presence: true, on: :create

  # Generate password reset token
  def generate_token_for(purpose)
    signed_id expires_in: 15.minutes, purpose: purpose
  end
end

