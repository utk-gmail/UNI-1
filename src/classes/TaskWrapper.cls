/**
* This class stores task data which is send as a response
*/
public class TaskWrapper{
    
    public Id taskId;
    public String subject;
    public String status;
    public Date dueDate;
    public String assignedTo;
    public Id relatedToId;
    public String relatedToShipping;
    public Date snoozeDate;
    public String relatedType;
    public String description;
    public Id createdById;
    
    /**
    * Constructor takes standard task record and set the variables
    */
    public TaskWrapper(Task taskInstance){
        relatedToShipping = '';
        relatedType = '';
        
        taskId = taskInstance.Id;   
        subject = taskInstance.Subject;
        status = taskInstance.Status;
        dueDate = taskInstance.ActivityDate;
        assignedTo = taskInstance.Owner.Name;
        description = taskInstance.Description;
        createdById = taskInstance.CreatedById;
        
        
        /**
        * if who is of contact type then populate it's details
        */
        if(taskInstance.WhoId != null && taskInstance.WhoId.getSobjectType() == Contact.getSobjectType()){
            relatedToId = taskInstance.WhoId;
            relatedType = Contact.getSobjectType().getDescribe().getLabel();
        }
        
        /**
        * if what is of account type then populate it's details
        */
        if(taskInstance.What instanceof Account) {
           Account account = taskInstance.What;
           if(account != null){
               relatedToShipping = CalendarServiceUtils.getShippingAddress(account);
           }
        }
        relatedToId = taskInstance.WhatId;
        if(taskInstance.WhatId != null){
            relatedType = taskInstance.WhatId.getSobjectType().getDescribe().getLabel();
        } 
        snoozeDate = taskInstance.snoozeDate__c;
    }
}