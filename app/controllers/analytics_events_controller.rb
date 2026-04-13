class AnalyticsEventsController < ApplicationController
  skip_forgery_protection

  def create
    result = Telemetry::Ingestor.new(
      request: request,
      distinct_id: anonymous_distinct_id
    ).call(
      event_name: params[:event],
      properties: telemetry_properties
    )

    return head :unprocessable_entity unless result.ok?

    head :accepted
  end

  private

  def anonymous_distinct_id
    cookies.signed.permanent[:ppq_anon_id] ||= SecureRandom.uuid
  end

  def telemetry_properties
    value = params[:properties]
    return {} if value.blank?
    return value.to_unsafe_h if value.respond_to?(:to_unsafe_h)
    return value.to_h if value.respond_to?(:to_h)

    {}
  end
end
