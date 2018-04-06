module UserGeneralHelpers

  # == Instance Variables ==================================================== #

  # define/return @current_user instance variable
  def current_user
    @current_user ||= User.find_by(:id => session[:user_id]) if !!session[:user_id]
  end

  # == Boolean Returns (Status) ============================================== #

  # check status of user
  def logged_in?
    !!current_user
  end

end
