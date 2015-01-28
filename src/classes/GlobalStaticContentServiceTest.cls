/**
* This class tests the functionality of GlobalStaticContentService class
*/
@isTest
public class GlobalStaticContentServiceTest {
    /**
    * This method tests global static content service
    */
    public static TestMethod void testglobalStaticContentService() {
        // Create test data
        CompassHomepageSettings__c[] settings = new CompassHomepageSettings__c[]{};
        settings.add(new CompassHomepageSettings__c(Name = 'NAMaterials', Content_Item_URL__c = 'http://www.someurl4.com/'));
        settings.add(new CompassHomepageSettings__c(Name = 'siteAssessment', Content_Item_URL__c = 'http://www.someurl3.com/'));
        insert settings;
        
        TestClassSetup.createContent();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_STATICCONTENT_URL;
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalStaticContentService.retrieveContent();
        Test.stopTest();
        
        // validating the result
        system.assertNotEquals(null, RestContext.response);
    }
}