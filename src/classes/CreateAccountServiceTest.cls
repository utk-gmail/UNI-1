/**
* This class tests the functionality of CreateAccountService class
*/
@isTest
public class CreateAccountServiceTest {
    /**
    * This method tests create account service
    */
    public static TestMethod void testCreateAccountService() {
        // Create test data
        CreateAccountService.AccountWrapper accountWrapper = new CreateAccountService.AccountWrapper();
        accountWrapper.name = 'Test Account - 001';
        accountWrapper.accountAlias = 'Test';
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_ACCOUNT_CREATE_URL;
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        CreateAccountService.ResponseWrapper response = CreateAccountService.createAccount(accountWrapper);
        Test.stopTest();
        
        // validating the result
        system.assertNotEquals(null, response);
        system.assertEquals(true, response.isSuccess);
    }
}