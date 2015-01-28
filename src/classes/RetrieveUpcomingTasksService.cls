/**
* This rest service is used to retrieve current user's upcoming tasks
*/
@RestResource(urlMapping = '/Calendar/RetrieveUpcomingTasks')
global with sharing class RetrieveUpcomingTasksService{
	
    /**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static UpComingTask getUpcomingTasks(){
        UpComingTask upComingTask = new UpComingTask();
        RestRequest request = RestContext.request;
        try{
        	String dateParam = request.params.get(CalendarServiceUtils.DATE_PARAMETER);
        	String userId = request.params.get(CalendarServiceUtils.USER_ID_PARAMETER);
			if(userId == null || userId == ''){
				userId = UserInfo.getUserId();	
			}
			else{
				List<User> userList = [Select Id from User Where Id =: userId];
				if(userList.size() == 0){
					throw new CalendarServiceException(Label.CS_User_Not_Found_Msg);
				}
			}
        	/**
        	* Fetch upcoming task 
        	*/
	        Date dateInstance = CalendarServiceUtils.getDate(dateParam);
	        upComingTask = new UpComingTask(getUpcomingTasks(dateInstance, userId));
        }
        catch(Exception ex){
        	upComingTask.message = ex.getMessage();
        }
        return upComingTask;
    }
     
    /**
    * This method retrieve the passed userIds upcoming tasks within passedDate
    * @passedDate: Date which is used to filter taks
    * @userId: Users whose tasks to be fetched
	* @return: returns a list of upcoming tasks
    */
    private static List<TaskWrapper> getUpcomingTasks(Date passedDate, String userId){
		Id currentUserId = UserInfo.getUserId();
        List<TaskWrapper> taskList = new List<TaskWrapper>();
         
        for(Task task: Database.query(CalendarServiceUtils.getTaskQuery() + ' where Start_Date__c <=: passedDate ' +
	        																       'and ActivityDate >: passedDate ' +
	        																       'and OwnerId =: userId ')){
            taskList.add(new TaskWrapper(task));
        }
        return taskList;
    }
}