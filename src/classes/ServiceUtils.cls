/**
* This class contains common methods used in rest service
*/
public class ServiceUtils{
    
    public static final String ACCOUNT_ID_PARAMETER = 'accountId';
    public static final String DATE_PARAMETER = 'date';    
    public static final String USER_ID_PARAMETER = 'userId';    
    public static final String OWNER_ID_PARAMETER = 'ownerId';
    public static final String LASTCHECK_PARAMETER = 'lastCheck';
    public static final String LEAD = 'lead';
    public static final String APPROVED = 'Approved';
    public static final String PENDING = 'Pending';
    
    /**
    * Returns blank string if passed value is null else return value
    */
    public static String getNotNullValue(String value){
        return value != null ? value : '';
    }
    
    /**
    * Returns strung value of boolean 
    */
    public static String getStringValue(Boolean value){
        return value != null ? value+'' : 'False';
    }
    
    /**
    * Returns integer value of decimal
    */
    public static Integer getIntegerValue(Decimal value){
        return value != null ? Integer.valueof(value): null;
    }
    
    /**
    * This method returns date when passed the date parameter string gets in rest call
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
                    throw new ServiceException(Label.Invalid_Date_Msg);
                }
            }
            /**
            * If it doesnt match then throw error
            */
            else{
                throw new ServiceException(Label.Invalid_Date_Msg);
            }
        }
        return dateInstance;
    }
    
    /**
    * This method returns datetime when passed the datetime string parameter gets in rest call
    * @datetimeString: DateTime parameter which is passed to the service as string
    * @return: Returns datetime by converting it
    */
    public static DateTime getDateTime(String datetimeString){
        
        /**
        * default it to system.now()
        */
        DateTime datetimeInstance = system.now();
        
        /**
        * If datetime string is blank or null then send system.now datetime by default
        */
        if(datetimeString != null && datetimeString != ''){
            Pattern MyPattern = Pattern.compile('(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})');
            Matcher MyMatcher = MyPattern.matcher(datetimeString);
            
            /**
            * Check if the passed string matches with the above pattern
            */
            if(MyMatcher.matches()){
                try{
                    /**
                    * If datetime is invalid then valueOfGMT method throws exception
                    */
                    datetimeString = datetimeString.replace('T',' ');
                    datetimeInstance = DateTime.valueOfGMT(datetimeString);
                }
                catch(Exception ex){
                    throw new ServiceException(Label.Last_Check_Invalid_DateTime_Msg);
                }
            }
            /**
            * If it doesnt match then throw error
            */
            else{
                throw new ServiceException(Label.Last_Check_Invalid_DateTime_Msg);
            }
        }
        return datetimeInstance;
    }
    
    /**
    * This method returns user id if its valid else throw exception
    * @ownerIdParameter: User id get to the service
    * @isPassedOwnerId: If true means ownerId is used as parameter then show User not found with passed ownerId message
    *                   and if false that means userId is used as parameter then show User not found with passed userId message
    */
    public static String getUserParameter(String userIdParameter, boolean isPassedOwnerId){
        String userId = UserInfo.getUserId();
        /**
        * If user id is not passed as parameter then use current user id
        */
        if(userIdParameter != null && userIdParameter != ''){
            List<User> userList = [Select Id from User where Id =: userIdParameter];
            if(userList.size() == 0){
                String errorMessage = Label.User_Not_Found_Msg;
                if(isPassedOwnerId){
                    errorMessage = Label.User_Not_Found_with_OwnerId;
                }
                throw new ServiceException(errorMessage);
            }
            else{ 
                userId = userIdParameter;
            }
        }
        return userId;
    }
    
    public static Map<String,RecordType> getRecordTypeMap() {        
        Map<String,RecordType> retVal = new Map<String,RecordType>();
        
        List<RecordType> rtList = [Select Id,Name,
                                           DeveloperName
                                    From RecordType 
                                    Where DeveloperName in ('Invoice','Wearer') 
                                    AND sObjectType in ('Account','Contact')];
                                    
        for(RecordType rt : rtList) {
            retVal.put(rt.DeveloperName,rt);
        }                             
        
        return retVal;         
    }
}