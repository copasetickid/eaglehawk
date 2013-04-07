class PasswordsController < Devise::PasswordsController

# GET /resource/password/new
  def new
    build_resource({})
    if request.xhr?
      render :partial => "new"
      return
    end
  end

# POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    if successfully_sent?(resource)
      if request.xhr?
        render :json => {:status => 'woot'}
        return
      end
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    else

      if params[:role] && params[:role] == 'company_admin'
         flash[:user] = resource.errors.full_messages
         redirect_to new_employer_password_path
       else
         if request.xhr?
           render :json => {:status => 'error', :message => resource.errors.full_messages}
           return
         end
         respond_with resource
       end
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    if request.xhr?
      render :partial => "edit"
      return
    end
    super
  end


  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?
      #resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      if request.xhr?
        render :json => {:status => 'woot'}
        return
      else
         respond_with resource, :location => after_sign_in_path_for(resource)
      end
    else
      if params[:role] && params[:role] == 'company_admin'
         flash[:user] = resource.errors.full_messages
         redirect_to edit_employer_password_path
       else
         if request.xhr?
            render :json => {:status => 'error', :message => resource.errors.full_messages}
            return
          else
            respond_with resource
          end
       end
    end
  end
end