require File.dirname(__FILE__) + '/../test_helper'
require 'student_team_controller'

# Re-raise errors caught by the controller.
class StudentTeamController; def rescue_action(e) raise e end; end

class StudentTeamControllerTest < ActionController::TestCase
  fixtures :users, :roles, :participants

  def setup
    @controller = StudentTeamController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:student1).id)
    AuthController.set_current_role(User.find(users(:student1).id).role_id,@request.session)
  end


end