/**
* This class tests the functionality of GlobalPopularService class
*/
@isTest
public class GlobalPopularServiceTest {
    /**
    * This method tests global popular service
    */
    public static TestMethod void testglobalPopularService() {
        // Create Test data
        TestClassSetup.createContent();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_POPULAR_URL;
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalPopularService.retrivePopular();
        Test.stopTest();
        
        // validating the result
        system.assertNotEquals(null, RestContext.response);
    }
}