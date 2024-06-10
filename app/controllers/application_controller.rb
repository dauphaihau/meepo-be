class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # def not_found!
  #   raise ActionController::RoutingError, 'Not Found'
  # end

  # def bad_request!
  #   raise ActionController::RoutingError, 'Bad Request', status: :bad_request!
  # end

  def record_not_found
    # render plain: '404 not found', status: :not_found
    render json: { message: 'record not found' }, status: :not_found
  end
end
