/**
* This rest service is used to update event status
*/
@RestResource(urlMapping='/Calendar/DispositionEvent')
global with sharing class DispositionEventService{
    
    /**
    * This method gets called when post http method is performed to update event status
    * @eventId: Event id of the event whose status to be updated
    * @status: Status to be updated with. valid values are Not Started, Done and Cancelled
    * @return: DispositionEventResponse which contains isSuccess boolean and message
    */
    @HttpPost
    global static DispositionEventResponse updateEventStatus(String eventId, String status) {
        DispositionEventResponse response = new DispositionEventResponse();

        /**
        * Validate the parameters
        */
        if(isValidParameters(eventId, status, response)){
        	
        	/**
        	* Fetch event
        	*/
            List<Event> eventList = [Select Id, Event_Status__c from Event where id =: eventId];
            
            /**
            * If event not found then show error else update it 
            */
            if(eventList.size() > 0){
                try{
                    eventList[0].Event_Status__c = status;
                    update eventList[0];
                    response = new DispositionEventResponse(Label.CS_Success);
                }
                catch(Exception ex){
                    response.message = ex.getMessage();
                }
            }
            else{
            	response.isSuccess = false;
                response.message = Label.CS_Event_Not_Found_Msg;
            }
        }
        return response;
    }
    
    /**
    * This method validates the passed parameters
  	* @eventId: check its requiredness
    * @status: check its requiredness and validity. valid values are Not Started, Cancelled and Done
    * @response: response where error message is stored in case of invalid parameters
    * @return: return boolean. true for success and false for error
    */
    private static boolean isValidParameters(String eventId, String status, DispositionEventResponse response){
    	response.isSuccess = true;
        if(eventId == null || eventId == ''){
            response.message = Label.CS_Event_Id_Required_Msg;
        }
        else if(status == null || status == ''){
            response.message = Label.CS_Status_Required_Msg;
        }
        /**
        * Checks status valid value
        */
        else if(!CalendarServiceUtils.isValidEventStatus(status)){
            response.message = Label.CS_Invalid_Status_Msg;
        }
        if(response.message != null){
            response.isSuccess = false;
        }
        return response.isSuccess;
    }
	
	/**
	* This wrapper is used to send disposition event rest response
	*/
	global class DispositionEventResponse{
       public string message;
       public boolean isSuccess;
       public DispositionEventResponse(){
           isSuccess = false;
       }
       public DispositionEventResponse(String message){
       		this.message = message; 
            isSuccess = true;
       }
   }
}