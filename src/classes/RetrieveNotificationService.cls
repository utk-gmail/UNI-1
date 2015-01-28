/**
* This rest service is used to retrieve notifications
*/
@RestResource(urlMapping='/Notifications/Retrieve')

global with sharing class RetrieveNotificationService{
 
 	/**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static Notifications retrieveNotification() {
    	Notifications response;
    	try{
	    	RestRequest request = RestContext.request;
			String lastCheck = request.params.get(ServiceUtils.LASTCHECK_PARAMETER);
			
			if(lastCheck != null && lastCheck != ''){
				/**
				* Get lastCheck Date time
				*/
				Datetime lastCheckDt = ServiceUtils.getDateTime(lastCheck);
				
				/**
				* Fetch approval data
				*/
				List<ProcessInstance> processInstanceList = [Select Id, TargetObjectId, Status, LastActorId, LastActor.Name,
																	CompletedDate,
																	(SELECT Id, StepStatus, Comments, ActorId, Actor.Name 
																	 FROM StepsAndWorkitems) 
															 from ProcessInstance 
															 where ProcessDefinition.TableEnumOrId =: ServiceUtils.LEAD
															 	and lastModifiedDate >=: lastCheckDt];
				List<ApprovalData> leadNotifications = new List<ApprovalData>();
				for(ProcessInstance processInstance: processInstanceList){
					leadNotifications.add(new ApprovalData(processInstance));
				}											 		
				response = new Notifications(leadNotifications);
			}
			else{
				response = new Notifications(Label.LastCheck_Required_Msg);
			}
    	}
    	catch(Exception ex){
    		response = new Notifications(ex.getMessage());
    	}
        return response;
    }
           
    /**
    * This wrapper is used to store notification response
    */
    global class Notifications{
        public List<ApprovalData> leads;
        public List<ApprovalData> approvals;
        public List<ApprovalData> activities;
        public List<ApprovalData> messages;
        public Boolean isSuccess;
        public String message;
        
        /**
        * Constructor to store leads
        */
        Notifications(List<ApprovalData> leads){
        	this.leads = leads;
        	approvals = new List<ApprovalData>();
        	activities = new List<ApprovalData>();
        	messages = new List<ApprovalData>();
        	isSuccess = true;
        	message = '';
        }
        
        /**
        * Constructor for error message
        */
        Notifications(String message){
        	this.message = message;
        	isSuccess = false;
        }
    }   
    
    /**
    * This wrapper stores approval data
    */
    public class ApprovalData{
        String parentId;
        String objectType;
        String approvalStatus;
        String approverId;
		String approverName;
		DateTime dateApproved;
		String comment;		 
		
		/**
		* Constructor accept processInstance and create approval data
		*/
		ApprovalData(ProcessInstance processInstance){
			parentId = processInstance.TargetObjectId;
			objectType = processInstance.TargetObjectId.getSobjectType().getDescribe().getLabel();
			approvalStatus = processInstance.Status;
			comment = '';
			/**
			* If approval status is approved then populate approvers data
			*/
			if(approvalStatus == ServiceUtils.APPROVED){
				dateApproved = processInstance.CompletedDate;
				approverId = processInstance.LastActorId;
				approverName = processInstance.LastActor.Name;
			}
			/**
			* Use process instance history to get latest comment
			*/
			for(ProcessInstanceHistory approvalHistory: processInstance.StepsAndWorkitems){
				/**
				* If step status is same as approval status then populate comment
				*/
				if(approvalHistory.StepStatus == approvalStatus){
					comment = approvalHistory.Comments != null ? approvalHistory.Comments : '';
					/**
					* If status is pending then also populate approvers information
					*/
					if(approvalStatus == ServiceUtils.PENDING){
						approverId = approvalHistory.ActorId;
						approverName = approvalHistory.Actor.Name;
					}
					break; 
				}
			}
		}       
    }
}