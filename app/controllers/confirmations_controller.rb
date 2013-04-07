class ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :require_no_authentication
  skip_before_filter :authenticate_user!
  respond_to :html, :json

  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)

    # this business here doesn't seem to work
    respond_to do |format|
      format.html do
        if successfully_sent?(resource)
          respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
        else
          respond_with(resource)
        end
      end
      format.json do
        if successfully_sent?(resource)
          render json: "success!"
        else
          render json: "error", status: 400
        end
      end
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    root_path
  end

end
