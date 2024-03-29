class SurveyDeploymentController < ApplicationController


  def new 
    @surveys=Questionnaire.find_all_by_type(4).map{|u| [u.name, u.id] }
    @course = Course.find_all_by_instructor_id(session[:user].id).map{|u| [u.name, u.id] }
    @total_students = CourseParticipant.find_all_by_parent_id(@course[0].id).count
  end

  def create
    survey_deployment=params[:survey_deployment]

    @survey_deployment=SurveyDeployment.new(survey_deployment)
    #(I'm not sure whether it's correct here to give the course-evaluation_id = 27, withouth given the value, error 
    #will be reported as there is no place that give the value for the variable course_evaluation_id)
    @survey_deployment.course_evaluation_id = 27
    if(params[:random_subset]["value"]=="1")
      @survey_deployment.num_of_students=User.find_all_by_role_id(1).length * rand
    end
    
    if(@survey_deployment.save)
    #Originally, there is an add method here, move the add method in survey_development_controller to the 
    #survey_development model. The method should not be in the controller, it doesn’t mean an action, and there is no 
    #corresponding html file in the view for survey_development. 
      @survey_deployment.add_participants(@survey_deployment.num_of_students,@survey_deployment.id)
      redirect_to :action=>'list'
     else
      @surveys=QuestionnaireTypeNode.find_all_by_id(4).map{|u| [u.name, u.id] }
      @total_students=User.find_all_by_role_id(1).length
      #change u.title to u.name, there is no column called title in the table for course. 
      @course = Course.find_all_by_instructor_id(session[:user].id).map{|u| [u.name, u.id] }
      render(:action=>'new')
     end     
  end
  
  def list
    @survey_deployments=SurveyDeployment.find(:all)
    @surveys={}
    @survey_deployments.each do |sd|
      @surveys[sd.id]=Questionnaire.find(sd.course_evaluation_id).name
    end
  end
  
  
   
   def delete
     SurveyDeployment.find(params[:id]).destroy
     SurveyParticipant.find_all_by_survey_deployment_id(params[:id]).each do |sp|
       sp.destroy
     end
     SurveyResponse.find_all_by_survey_deployment_id(params[:id]).each do |sr|
       sr.destroy
     end
     redirect_to :action=>'list'
   end
 

  
  def reminder_thread 
  
    #Check status of  reminder thread
    @reminder_thread_status="Running"
   unless MiddleMan.get_worker(session[:reminder_key])
        @reminder_thread_status="Not Running"
    end
   
  end
   
  def toggle_reminder_thread
    #Create reminder thread using BackgroundRb or kill it if its already running
   unless MiddleMan.get_worker(session[:reminder_key])
    session[:reminder_key]=MiddleMan.new_worker :class=>:reminder_worker, :args=>{:num_reminders=>3} # 3 reminders for now
   else
    MiddleMan.delete_worker(session[:reminder_key])
    session[:reminder_key]=nil
   end
   redirect_to :action=>'reminder_thread'
  end
   
  

end
