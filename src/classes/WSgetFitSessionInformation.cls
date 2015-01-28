/*
* This webservice is used to get fit session information for provided Account Id.
*/
@RestResource(urlMapping='/Opportunity/FitSetup')
global with sharing class WSgetFitSessionInformation {
    
     /**
     * This service returns Fit Sessio information for provided accountID.
     *     
     * accountId            Account Unique Id (which defines account`s uniqueness. It can be custom unique field too).
     *                      to Fetch Related Fit Session information like Departments, Embellishments, Invoices etc.
     *
     * @return              FitSessionWrapper object.
     * @errorCode           INVALID_INPUT, API_EXCEPTION
     */
    @HttpGet
    global static FitSessionWrapper  getFitSessionInfo() {
        //create wrapper instance to return as response.
        FitSessionWrapper response = new FitSessionWrapper();
        
        RestRequest req = RestContext.request;
        
        //Get Account Id from URL Params.
        String accountId = req.params.get('accountId');
        
        //Check If Acccount Id is not null or emptry. If yes, return error response.
        if (accountId == null || accountId.trim() == '') {
            response.errorCode = ApplicationConstants.INVALID_INPUT;
            response.status = ApplicationConstants.ERROR;
            response.message = System.Label.ACCOUNT_ID_NULL;
            return response;
        } else {
            //call API to get Fit Session information.
            try{
                UniSalesAPIUtil api1 = new UniSalesAPIUtil();
                response = api1.getFitSessionInformation(accountId);
            }catch(Exception e){
                response.errorCode = ApplicationConstants.API_EXCEPTION;
                response.status = ApplicationConstants.ERROR;
                response.message = e.getMessage()+ ' at line '+e.getLineNumber();
                return response;
            }
            
        }
        response.status = ApplicationConstants.SUCCESS;
        return response;
    }//end getFitSessionInfo
}//end class.