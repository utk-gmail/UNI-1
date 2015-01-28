/**
* This class tests the functionality of GlobalMetadataService class
*/
@isTest
public class GlobalMetadataServiceTest {
    /**
    * This method tests global metadate service
    */
    public static TestMethod void testglobalMetadataService() {
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_METADATA_URL;
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalMetadataService.retriveMetadata();
        Test.stopTest();
        
        // validating the result
        system.assertNotEquals(null, RestContext.response);
    }
}