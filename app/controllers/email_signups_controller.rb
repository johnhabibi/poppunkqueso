class EmailSignupsController < ApplicationController
  def create
    email = params[:email].to_s.strip.downcase

    if email.blank? || email.exclude?("@")
      return render_signup_response(false, "Drop a valid email so we can send the monthly queso drop.")
    end

    Rails.logger.info(
      "[email_signup] email=#{email} endpoint=#{Rails.application.config.x.email_signup.endpoint.present?} source=#{params[:source].presence || 'unknown'}"
    )

    render_signup_response(true, "You're on the list. Next queso drop lands soon.")
  end

  private

  def render_signup_response(success, message)
    respond_to do |format|
      format.json { render json: { success: success, message: message }, status: (success ? :ok : :unprocessable_entity) }
      format.html do
        flash[success ? :notice : :alert] = message
        redirect_back fallback_location: root_path
      end
    end
  end
end
