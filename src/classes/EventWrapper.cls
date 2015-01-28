/**
* This class stores event data which is send as a response
*/
public class EventWrapper{
    
    public Id eventId;
    public DateTime eventDateTime;
    public String subject;
    public String location;
    public String type;
    public String assignedTo;
    public String status;
    public String duration;
    public String name;
    public String phone;
    public String email;
    public String accountShipping;
    public Id relatedToId;
    public String relatedType;
    
    /**
    * Constructor takes standard event record and set the variables
    */
    public EventWrapper(Event eventInstance){
    	relatedType = '';
        phone = '';
        email = '';
        name = '';
        accountShipping = '';
        eventId = eventInstance.Id;
        eventDateTime =  eventInstance.ActivityDateTime;
        subject = eventInstance.Subject;
        location = eventInstance.Location != null? eventInstance.Location: '';
        type = eventInstance.Type != null ? eventInstance.Type : '';
        assignedTo = eventInstance.Owner.Name;
        status = eventInstance.Event_Status__c != null? eventInstance.Event_Status__c: '';
        duration = eventInstance.Duration__c;
        relatedToId = eventInstance.WhatId;
		if(eventInstance.WhatId != null){
        	relatedType = eventInstance.WhatId.getSobjectType().getDescribe().getLabel();
        }

        /**
        * if who is of contact type then populate it's details
        */
        if(eventInstance.WhoId != null && eventInstance.WhoId.getSobjectType() == Contact.getSobjectType()){
        	relatedToId = eventInstance.WhoId;
        	relatedType = Contact.getSobjectType().getDescribe().getLabel();
        	name = eventInstance.who.name;
           	phone = eventInstance.who.phone != null ? eventInstance.who.phone : '';
           	email = eventInstance.who.email != null ? eventInstance.who.email : '';
        }
        
        /**
        * if what is of account type then populate it's details
        */
        if(eventInstance.What instanceof Account) {
        	Account account = eventInstance.What;
           	if(account!= null){
               	name = account.Name;
            	accountShipping = CalendarServiceUtils.getShippingAddress(account);
               	phone = account.phone;
        	}
        } 
    }
}