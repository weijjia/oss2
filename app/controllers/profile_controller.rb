#Allows a user to update their own profile information
class ProfileController < ApplicationController

#load the view with the current fields
#only valid if user is logged in
 def edit
    @user = session[:user]
    @assignment_questionnaires = AssignmentQuestionnaires.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',@user.id])
 end
  
 #store parameters to user object
 def update
    @user = session[:user]
    
    unless params[:assignment_questionnaires].nil? or params[:assignment_questionnaires][:notification_limit].blank?
      aq = AssignmentQuestionnaires.find(:first, :conditions => ['user_id = ? and assignment_id is null and questionnaire_id is null',@user.id])
      aq.update_attribute('notification_limit',params[:assignment_questionnaires][:notification_limit])                    
    end
    
    if @user.update_attributes(params[:user])
      flash[:note] = 'Profile was successfully updated.'
      redirect_to :action => 'edit', :id => @user
    else
      flash[:note] = 'Profile was not updated.'
      render :action => 'edit'
    end
  end

end
