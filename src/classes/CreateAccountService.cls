/*
* This rest service is used Create Account
*/

@RestResource(urlMapping='/Account/Create')
global class CreateAccountService {

    /**
    * This method gets called when POST http method is performed
    */
    @HttpPost
    global static ResponseWrapper createAccount(AccountWrapper accountWrapper) {
        ResponseWrapper response = new ResponseWrapper();
        try {
            // Create the account from the passed object
            Account objAccount = new Account(
                Name = accountWrapper.name,
                Account_Alias__c = accountWrapper.accountAlias,
                Phone = accountWrapper.phone,
                ShippingStreet = accountWrapper.shippingStreet,
                ShippingCity = accountWrapper.shippingCity,
                ShippingState = accountWrapper.shippingState,
                ShippingCountry = accountWrapper.shippingCountry,
                ShippingPostalCode = accountWrapper.shippingPostalCode,
                Estimated_Cash_Value__c = accountWrapper.estimatedCashValue,
                Program_Type_1__c = accountWrapper.programType1,
                Competitor_1__c = accountWrapper.competitor1,
                Other_Incumbent__c = accountWrapper.otherIncumbent,
                CED_1__c = ServiceUtils.getDate(accountWrapper.ced1),
                Competitor_2__c = accountWrapper.competitor2,
                CED_2__c = ServiceUtils.getDate(accountWrapper.ced2),
                Incumbent_DP__c = accountWrapper.incumbentDP,
                GK_Employees_Here__c = accountWrapper.gKEmployeesHere,
                Number_of_Wearers__c = accountWrapper.numberOfWearers,
                Mega_Segment__c = accountWrapper.megaSegment
            );
            insert objAccount;
            
            // Return the success response
            response.Id = objAccount.Id;
            response.isSuccess = true;
            response.message = 'Created successfully';
        } catch (Exception objEx) {
            // Catch the exception if any
            response.isSuccess = false;
            response.message = objEx.getMessage();
        }
        return response;
    }
    
    /**
    * This wrapper stores Account data which is accepted as input parameter
    */
    global class AccountWrapper {
        public String name;
	    public String accountAlias;
	    public String phone;
	    public String shippingStreet;
	    public String shippingCity;
	    public String shippingState;
	    public String shippingCountry;
	    public String shippingPostalCode;
	    public String estimatedCashValue;
	    public String programType1;
	    public String competitor1;
	    public String otherIncumbent;
	    public String ced1;
	    public String competitor2;
	    public String ced2;
	    public String incumbentDP;
	    public Integer gKEmployeesHere;
	    public Integer numberOfWearers;
	    public String megaSegment;
    }
    
    /**
    * This wrapper stores response data
    */
    global class ResponseWrapper {
        public String message;
        public String Id;
        public Boolean isSuccess;
    }
}