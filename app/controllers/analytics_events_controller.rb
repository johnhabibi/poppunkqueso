class AnalyticsEventsController < ApplicationController
  skip_forgery_protection

  ALLOWED_EVENTS = %w[
    click_spotify
    click_apple_music
    email_signup_submit
    click_embedded_player
  ].freeze

  def create
    event = params[:event].to_s
    return head :unprocessable_entity unless ALLOWED_EVENTS.include?(event)

    Rails.logger.info("[analytics] event=#{event} props=#{params[:properties].to_unsafe_h.inspect}")
    head :accepted
  end
end
