/*
* This rest service is used Account next steps service
*/

@RestResource(urlMapping='/Account/NextSteps')
global class AccountNextStepsService {
    
    /**
    * This method gets called when POST http method is performed
    */
    @HttpPost
    global static ResponseWrapper createNextSteps(AccountWrapper objAccountWrapper) {
        ResponseWrapper response = new ResponseWrapper();
        response.isSuccess = false;
        try {
            // Check if Account is missing, show an error
            if(String.isEmpty(objAccountWrapper.Account)) {
                response.message = 'Missing Account, further actions can not be taken';
            } else {
                Account objAccount = new Account(Id = objAccountWrapper.Account);
                // Check if Account.Status is set, update the account and return
                if(String.isNotEmpty(objAccountWrapper.Status)) {
                    objAccount.Status__c = objAccountWrapper.Status;
                    update objAccount;
                    
                    response.isSuccess = true;
                    response.message = 'Your request processed successfully.';
                    return response;
                }
                
                // Check if Note is present, create related Note__c record
                if(objAccountWrapper.Note != null) {
                    Note__c objNote = new Note__c(
                        Name = objAccountWrapper.Note.Name,
                        Account__c = objAccountWrapper.Account,
                        Text__c = objAccountWrapper.Note.Text
                    );
                    insert objNote;
                    
                    // Check if Attachments present, create a junction object storing the content items
                    if(objAccountWrapper.Note.Attachments != null && objAccountWrapper.Note.Attachments.size() > 0) {
                        Attachment__c[] lstAttachment = new Attachment__c[] {};
                        for(String contentId : objAccountWrapper.Note.Attachments) {
                            if(contentId.subString(0,3) == SobjectType.ContentDocument.getKeyPrefix()) {
                                lstAttachment.add(new Attachment__c(
                                    Note__c = objNote.Id,
                                    Content__c = contentId
                                ));
                            }
                        }
                        if(lstAttachment.size() > 0) {
                            insert lstAttachment;
                        }
                    }
                }
                
                // Check if Activity present, create Event or Tas based on Type
                if(objAccountWrapper.Activity != null && String.isNotEmpty(objAccountWrapper.Activity.Type)) {
                    if('Event'.equalsIgnoreCase(objAccountWrapper.Activity.Type)) {
                        insert new Event(
                            OwnerId = objAccountWrapper.Activity.AssignedTo,
                            Subject = objAccountWrapper.Activity.Subject,
                            WhatId = objAccountWrapper.Account,
                            StartDateTime = DateTime.valueOf(objAccountWrapper.Activity.StartDateTime),
                            EndDateTime = DateTime.valueOf(objAccountWrapper.Activity.EndDateTime)
                        );
                    } else if('Task'.equalsIgnoreCase(objAccountWrapper.Activity.Type)) {
                        insert new Task(
                            OwnerId = objAccountWrapper.Activity.AssignedTo,
                            Subject = objAccountWrapper.Activity.Subject,
                            WhatId = objAccountWrapper.Account,
                            Status = objAccountWrapper.Activity.Status,
                            Priority = objAccountWrapper.Activity.Priority
                        );
                    }
                }
                response.isSuccess = true;
                response.message = 'Your request processed successfully.';
            }
        } catch(Exception ex) {
            response.isSuccess = true;
            response.message = ex.getMessage();
        }
        return response;
    }
    
    /**
    * This wrapper stores Account data which is accepted as input parameter
    */
    global class AccountWrapper {
        public String Account;
        public String WhatWasDone;
        public String NewStage;
        public String Status;
        public NoteWrapper Note;
        public ActivityWrapper Activity;
    }
    
    /**
    * This wrapper stores Note data
    */
    global class NoteWrapper {
        public String Name;
        public String Text;
        public String[] Attachments;
    }
    
    /**
    * This wrapper stores Activity data
    */
    global class ActivityWrapper {
        public String Type;
        public String AssignedTo;
        public String Subject;
        public String Status; //Task
        public String Priority; //Task
        public String StartDateTime; //Event
        public String EndDateTime; //Event
    }
    
    /**
    * This wrapper stores Response data
    */
    global class ResponseWrapper {
        public String message;
        public Boolean isSuccess;
    }
}