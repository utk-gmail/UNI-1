/**
* This class contains common methods used in calendar service
*/
public class CalendarServiceUtils{
    
    /**
    * This is used to define that how many levels suboridnates to be retrieved
    */
    private static Integer SUBORDINATES_HIERARCHY_COUNT = 3; 
    
    /**
    * Constants used for comparison
    */
    public static final string DATE_PARAMETER = 'date';
    public static final string USER_ID_PARAMETER = 'userId';
    private static final string DONE = 'Done';
    private static final string CANCELLED = 'Cancelled';
    private static final string NOT_STARTED = 'Not Started';
    
    /**
    * @return: Task query
    * If you want to add new field in api call just add field in this query and it will be reflected in all service 
    */
    public static String getTaskQuery(){
        return 'Select Id, Subject, Status, '+
                       'ActivityDate, Owner.Name, WhatId, SnoozeDate__c,WhoId, CreatedById, Description, '+
                       'TYPEOF What '+
                           'WHEN Account THEN ShippingAddress, ShippingStreet, ShippingCity, '+
                                       'ShippingCountry, ShippingState, ShippingPostalCode '+
                           'Else Id '+
                       'End '+
                'from Task';
    }
    
    /**
    * @return: Event query
    * If you want to add new field in api call just add field in this query and it will be reflected in all service 
    */
    public static String getEventQuery(){
        return 'Select Id, ActivityDate, ActivityDateTime, Subject, Location, Type, '+
                      'Owner.Name,Event_Status__c,Duration__c,  WhatId, '+
                      'whoId, who.Name, Who.Phone, who.email, '+
                      'TYPEOF What '+
                             'WHEN Account THEN ShippingAddress, ShippingStreet, ShippingCity, '+
                                               'ShippingCountry, ShippingState, ShippingPostalCode, '+
                                               'Phone, Name '+
                             'Else Id '+
                      'End '+
                'from Event';
    }
    
    /**
    * This method returns date when passed the date parameter string get in rest call
    * @dateString: Date parameter which is passed to the service as string
    * @return: Returns date by converting it
    */
    public static Date getDate(String dateString){
        /**
        * default it to today
        */
        Date dateInstance = system.today();
        
        /**
        * If date string is blank or null then send todays date by default
        */
        if(dateString != null && dateString != ''){
            Pattern MyPattern = Pattern.compile('(\\d{4})-(\\d{2})-(\\d{2})');
            Matcher MyMatcher = MyPattern.matcher(dateString);
            
            /**
            * Check if the passed string matches with the above pattern
            */
            if(MyMatcher.matches()){
                try{
                    /**
                    * If date is invalid then valueOf method throws exception
                    */
                    dateInstance = Date.valueof(dateString);
                }
                catch(Exception ex){
                    throw new CalendarServiceException(Label.CS_Invalid_Date_Msg);
                }
            }
            /**
            * If it doesnt match then throw error
            */
            else{
                throw new CalendarServiceException(Label.CS_Invalid_Date_Msg);
            }
        }
        return dateInstance;
    }
    
    /**
    * This method return the shipping address of account
    * @account: Account instance from where shipping address is retrieved
    * @return: Concatenation of shipping address fields
    */ 
    public static String getShippingAddress(Account account){
        String shippingAddress = '';
        shippingAddress += account.ShippingStreet != null ? account.ShippingStreet + ', ' : '';
        shippingAddress += account.ShippingCity != null ? account.ShippingCity + ', ' : '';
        shippingAddress += account.ShippingState != null ? account.ShippingState + ', ' : '';
        shippingAddress += account.ShippingCountry != null ? account.ShippingCountry + ', ' : '';
        shippingAddress += account.ShippingPostalCode != null ? account.ShippingPostalCode + ', ' : '';
        shippingAddress.removeEnd(', ');
        return shippingAddress;
    }
    
    public static boolean isValidEventStatus(String status){
        Set<String> validStatus =  new Set<String>{NOT_STARTED, DONE, CANCELLED};
        return validStatus.contains(status);
    }
}