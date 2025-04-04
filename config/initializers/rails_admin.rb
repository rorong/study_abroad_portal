RailsAdmin.config do |config|
  config.asset_source = :importmap

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Pundit ==
  config.authorize_with :pundit

  # Only allow admin users to access Rails Admin
  config.authorize_with do
    unless current_user.admin?
      flash[:error] = 'You are not authorized to access this area.'
      redirect_to main_app.root_path
    end
  end

  # Display empty fields in show views
  config.compact_show_view = false

  # Number of default rows per-page
  config.default_items_per_page = 20

  # Show gravatar
  config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end
end
