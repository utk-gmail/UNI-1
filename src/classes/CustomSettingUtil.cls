/*
* Utility Class which returns custom setting objects.
*/
public with sharing class CustomSettingUtil {
    
    /*
    * Method returns web Service Params custom settings.
    */
    public static Web_Service_Params__c getWebServiceParams() {
        Web_Service_Params__c params = Web_Service_Params__c.getInstance();
        
        if(params == null) {
            params = Web_Service_Params__c.getOrgDefaults();
        }
        
        return params;
    }
}