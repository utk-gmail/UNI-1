/**
* This class tests the functionality of DispositionEventService class
*/
@isTest
public class DispositionEventServiceTest{
    
    static Event event;
     
    /**
    * Create test data
    */
    private static void createTestData(){
        Account account = TestClassSetup.createAccount('Test Account');
        Contact contact = TestClassSetup.createContact('Test Contact');
        event = TestClassSetup.createEvent(System.today(), UserInfo.getUserId(), account.Id, contact.Id);
    }
    
    /**
    * Test updateEventStatus 
    */
    public TestMethod static void testUpdateEventStatus(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionEventService.DispositionEventResponse result = DispositionEventService.updateEventStatus(event.Id, 'Done');
        Test.stopTest();
        system.assertEquals(true, result.isSuccess);
        system.assertEquals('Done', [Select Event_Status__c from Event where id =: event.Id][0].Event_Status__c);
    }
    
    /**
    * Test updateEventStatus when event id is missing
    */
    public TestMethod static void testUpdateEventStatusEventMissing(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionEventService.DispositionEventResponse result = DispositionEventService.updateEventStatus(null, 'Done');
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
    
    /**
    * Test updateEventStatus when event status is missing
    */
    public TestMethod static void testUpdateEventStatusMissing(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionEventService.DispositionEventResponse result = DispositionEventService.updateEventStatus(event.id, null);
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
    
    /**
    * Test updateEventStatus when event status is invalid
    */
    public TestMethod static void testUpdateEventStatusInvalidEventId(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionEventService.DispositionEventResponse result = DispositionEventService.updateEventStatus(event.Id,'test');
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
}