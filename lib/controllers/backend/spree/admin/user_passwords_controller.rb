class Spree::Admin::UserPasswordsController < Devise::PasswordsController
  helper 'spree/base'

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Store

  helper 'spree/admin/navigation'
  helper 'spree/admin/tables'
  layout 'spree/layouts/admin'

  # Overridden due to bug in Devise.
  #   respond_with resource, :location => new_session_path(resource_name)
  # is generating bad url /session/new.user
  #
  # overridden to:
  #   respond_with resource, :location => spree.login_path
  #
  def new
	cookies.permanent[:refer] = { value: request.referrer, expires: 10.hour.from_now }
  end


  def create
     if cookies[:refer].nil?
                        ref = spree.login_path
                else
                    	ref = cookies[:refer]
                end
  self.resource = resource_class.send_reset_password_instructions(params[resource_name])
    if resource.errors.empty?
      set_flash_message(:notice, :send_instructions) if is_navigational_format?
      #respond_with resource, :location => "/"
    respond_with resource, :location => ref
    else
      respond_with resource, :location => params[:path] || spree.login_path
        #respond_with_navigational(resource) { render :new }
    end
  end

  # Devise::PasswordsController allows for blank passwords.
  # Silly Devise::PasswordsController!
  # Fixes spree/spree#2190.
  def update
    if params[:spree_user][:password].blank?
      set_flash_message(:error, :cannot_be_blank)
      render :edit
    else
      super
    end
  end

end
