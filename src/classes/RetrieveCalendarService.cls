/**
* This rest service is used to retrieve current user's calendar information
*/
@RestResource(urlMapping = '/Calendar/RetrieveCalendar')
global with sharing class RetrieveCalendarService{
    
    /**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static Calendar getTasksAndEvents() {
    	Calendar calendar = new Calendar();
    	try{ 
	        RestRequest request = RestContext.request;
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
        	* Fetch tasks and events 
        	*/
	       	Date dateInstance = CalendarServiceUtils.getDate(dateParam);
	    	calendar = new Calendar(getMyTasks(dateInstance, userId),getMyEvents(dateInstance, userId));
	    }
        catch(Exception ex){
        	calendar.message = ex.getMessage();
        }
        return calendar;
    }
    
    /**
    * This method retrieve current user's task
    * @passedDate: Date which is used for due date filter
    * @userId: Users whose tasks to be fetched
	* @return: returns a list of task
    */
    private static List<TaskWrapper> getMyTasks(Date passedDate, Id userId){
        List<TaskWrapper> taskList = new List<TaskWrapper>();
        for(Task task: Database.query( CalendarServiceUtils.getTaskQuery()+' where (ActivityDate =: passedDate OR SnoozeDate__c =:passedDate) and OwnerId =: userId')){
            taskList.add(new TaskWrapper(task));
        }
        return taskList;
    }
    
    /**
    * This method retrieve current user's events
    * @passedDate: Date which is used for due date filter
    * @userId: Users whose tasks to be fetched
	* @return: returns a list of events
    */
    private static List<EventWrapper> getMyEvents(Date passedDate, Id userId){
        List<EventWrapper> eventList = new List<EventWrapper>();
        Id currentUserId = UserInfo.getUserId();
        for(Event event: Database.query( CalendarServiceUtils.getEventQuery()+' where ActivityDate =: passedDate and OwnerId =: userId')){
            eventList.add(new EventWrapper(event));
        }
        return eventList;
    }
}