/**
* This class tests the functionality of RetrieveNotificationService class
*/
@isTest
public class RetrieveNotificationServiceTest{
    
    static Lead lead;
    
    /**
    * Create test data
    */
    private static void createTestData(){
        lead = new Lead();
        lead.LastName = 'Test lead';
        lead.Company = 'Test Company';
        insert lead;
        
        Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(lead.id);
        
        /**
        * Submit the approval request for the lead
        */
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    /**
    * This method tests retrieveNotification
    */
    public static TestMethod void testRetrieveNotification(){
        createTestData();
        RestRequest request = new RestRequest();
        DateTime dt = system.now().addDays(-1);
        request.params.put(ServiceUtils.LASTCHECK_PARAMETER, dt.year() + '-' + dt.month() + '-' + dt.day()+'T00:00:00');
        RestContext.request = request;
        Test.startTest();
        RetrieveNotificationService.Notifications result = RetrieveNotificationService.retrieveNotification();
        Test.stopTest();
        //system.assertEquals(true, result.isSuccess);
        //system.assertEquals(1, result.leads.size());
    }
    
    /**
    * This method tests retrieveNotification with lastCheck parameter not provided
    */
    public static TestMethod void testRetrieveNotificationMissingLastCheck(){
        createTestData();
        RestRequest request = new RestRequest();
        DateTime dt = system.now().addDays(-1);
        RestContext.request = request;
        Test.startTest();
        RetrieveNotificationService.Notifications result = RetrieveNotificationService.retrieveNotification();
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
    
    /**
    * This method tests retrieveNotification with invalid lastCheck parameter
    */
    public static TestMethod void testRetrieveNotificationInvalidDate(){
        createTestData();
        RestRequest request = new RestRequest();
        DateTime dt = system.now().addDays(-1);
        request.params.put(ServiceUtils.LASTCHECK_PARAMETER, dt.year() + '-test-' + dt.day()+'T'+dt.hour()+':'+dt.minute()+':'+dt.second());
        RestContext.request = request;
        Test.startTest();
        RetrieveNotificationService.Notifications result = RetrieveNotificationService.retrieveNotification();
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
    
}