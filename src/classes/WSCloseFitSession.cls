/*
* This webservice is used to close FitSession for given accountId.
*/
@RestResource(urlMapping='/Account/FitSession/Close')
global with sharing class WSCloseFitSession {
    
     /**
     * This service closes Fit Session.
     *     
     * accountId            Account Id to Fetch Related Current Opportunity and mark Siziing_complete__c true.
     *                      It should be specified as a JSON Body.
     *
     * @return              Custom Response Object.
     * @errorCode           INVALID_INPUT, API_EXCEPTION
     */
    @HttpPost
    global static Response sessionClose() {
        Response res = new Response();
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        
        String accountId;        
        
        //Parse JSON request.
        RequestBodyParser.RequestBodyParams reqParams = RequestBodyParser.getJsonParamsFromRequest(restReq);
        
        //Check if request params are provided.
        if(reqParams == null) {
            res.status = ApplicationConstants.ERROR;
            res.errorCode = ApplicationConstants.INVALID_INPUT;
            res.message = System.Label.UNABLE_PARSE_REQ_PARAMS;
            return res;
        }
        
        //get JSON params in map.
        Map<String, Object> params = reqParams.getParams();
        
        //get Account Id.
        if(params.get('accountId') != null) {
            accountId = (String)params.get('accountId');
        }
        
        //If Account Id is null, return error response.
        if (accountId == null || accountId.trim() == '') {
            res.errorCode = ApplicationConstants.INVALID_INPUT;
            res.status = ApplicationConstants.ERROR;
            res.message = System.Label.ACCOUNT_ID_NULL;
            return res;
        }
        
        /*
        * Call API to close Fit Session.
        * Processing logic is not included in webservice because API can be used internally to close fit session too.
        * In Future, Factory Design Pattern can be implemented to maintain APIs well.
        */
        try{
            UniSalesAPIUtil api1 = new UniSalesAPIUtil();
            String resultStr = api1.closeFitSession(accountId);
            
            res.message = resultStr;
        }catch(Exception e){
            res.errorCode = ApplicationConstants.API_EXCEPTION;
            res.status = ApplicationConstants.ERROR;
            res.message = e.getMessage();
            return res;
        }
        
        res.status = ApplicationConstants.SUCCESS;
        return res;        
    }//end sessionClose
}//end class.