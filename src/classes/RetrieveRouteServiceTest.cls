/**
* This class tests the functionality of RetrieveRouteService class
*/
@isTest
public class RetrieveRouteServiceTest{
    
    /**
    * Create test data
    */
    private static void createTestData(){
        List<Route__c> routes = new List<Route__c>();
        routes.add(new Route__c(Name = 'Test Route 1'));
        routes.add(new Route__c(Name = 'Test Route 2'));
        insert routes;
    }
    
    /**
    * This method tests retrieveRoute
    */
    public static TestMethod void testRetrieveRoute(){
        createTestData();
        RestRequest request = new RestRequest();
        RestContext.request = request;
        Test.startTest();
        RetrieveRouteService.Routes result = RetrieveRouteService.retrieveRoute();
        Test.stopTest();
        system.assertEquals(result.isSuccess , true);
        system.assertEquals(2, result.routes.size());
    }
    
    /**
    * This method tests retrieveRoute with invalid date
    */
    public static TestMethod void testRetrieveRouteInvalidDate(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        request.params.put(ServiceUtils.DATE_PARAMETER, today.year() + '-13-' + today.day());
        RestContext.request = request;
        Test.startTest();
        RetrieveRouteService.Routes result = RetrieveRouteService.retrieveRoute();
        Test.stopTest();
        system.assertEquals(result.isSuccess , false);
    }
}