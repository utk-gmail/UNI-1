/**
* This rest service is used to update event status and task snooze date
*/
@RestResource(urlMapping='/Calendar/DispositionTask')
global with sharing class DispositionTaskService{
    
    /**
    * This method gets called when post http method is performed to update event status and task snooze date
    * @taskId: Task id of the task whose status and snooze date to be updated
    * @status: Status to be updated with. valid values are Not Started, Done and Cancelled
    * @snoozeDate: Snooze date to be updated on task
    * @return: DispositionTaskResponse which contains isSuccess boolean and message
    */
    @HttpPost
    global static DispositionTaskResponse doTaskDisposition(String taskId, String status, Date snoozeDate) {
        DispositionTaskResponse response = new DispositionTaskResponse();

        SavePoint sp = Database.setSavePoint();
        try{
        	/** 
        	* Validate all the parameters
        	*/
            if(isValidParameters(taskId, status, snoozeDate, response)){
            	/**
            	* Fetch event and task
            	*/
                List<Task> taskList = [Select Id, Status, SnoozeDate__c from Task where id =: taskId];
                /**
                * If both of them are found
                */
                if(taskList.size() > 0){
                	if(status != null && status != ''){
                    	taskList[0].Status = status;
                	}
                	if(snoozeDate != null){
                    	taskList[0].SnoozeDate__c = snoozeDate;
                	}
                    update taskList[0];
                    response = new DispositionTaskResponse(Label.CS_Success);
                }
                else{
                	/**
	                * If any of them not found then return error
	                */
                    response.isSuccess = false;
                    
                    if(taskList.size() == 0){
                        response.message = Label.CS_Task_Not_Found_Msg;
                    }
                }
            }
        }
        catch(Exception ex){
        	/**
        	* If due to some issue if task or event update gets failed then rollback all the database operation
        	*/
            Database.rollback(sp);
            response.isSuccess = false;
            response.message = ex.getMessage();
        }
        return response;
    }
       
    /**
    * This method validates the passed parameters
    * @taskId: check its requiredness 
    * @status: check its requiredness and validity. valid values are Not Started, Cancelled and Done
    * @snoozeDate: check its requiredness
    * @response: response where error message is stored in case of invalid parameters
    * @return: return boolean. true for success and false for error
    */
    private static boolean isValidParameters(String taskId, String status, Date snoozeDate, DispositionTaskResponse response){
    	response.isSuccess = true;
        if(taskId == null || taskId == ''){
            response.message = Label.CS_Task_Id_Required_Msg;
        }
         else if(snoozeDate == null && (status == null || status == '')){
            response.message = Label.CS_Status_Or_SnoozeDate_Required_Msg;
        }
        /**
        * Checks status valid value
        */
        else if(status != null && !CalendarServiceUtils.isValidEventStatus(status)){
            response.message = Label.CS_Invalid_Status_Msg;
        }
        if(response.message != null){
            response.isSuccess = false;
        }
        return response.isSuccess;
    }
	
	/**
	* This wrapper is used to send disposition task rest response
	*/
	global class DispositionTaskResponse{
      	public string message; 
       	public boolean isSuccess;
       	public DispositionTaskResponse(){
           	isSuccess = false;
       	}
       	public DispositionTaskResponse(String message){
			this.message = message;
           	isSuccess = true;
       }
   }
}