class ErrorsController < ApplicationController
  def not_found
    set_meta(
      title: "Page Not Found | Pop Punk Queso",
      description: "The page you were looking for bounced out of the pit. Jump back to Pop Punk Queso."
    )
    render "errors/not_found", status: :not_found
  end
end
