/**
* This class tests the functionality of RetrieveCalendarService class
*/
@isTest
public class RetrieveCalendarServiceTest{
    static Task task;
    static Event event;
    
    /**
    * Create test data
    */    
    private static void createTestData(){
        Account account = TestClassSetup.createAccount('Test Account');
        Contact contact = TestClassSetup.createContact('Test Contact');
        task = TestClassSetup.createTask(System.today(), System.today(), UserInfo.getUserId(), account.Id);
        TaskWrapper wrapper = new TaskWrapper(task);
        event = TestClassSetup.createEvent(System.today(), UserInfo.getUserId(), account.Id, contact.Id);
        EventWrapper eWrapper = new EventWrapper(event);
    }
    
    /**
    * Test getTasksAndEvents
    */
    public TestMethod static void testGetTasksAndEvents(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        request.params.put('date',today.year() + '-' + today.month() + '-' + today.day());
        RestContext.request = request;
        Test.startTest();
        Calendar result = RetrieveCalendarService.getTasksAndEvents();
        Test.stopTest();
        //system.assertEquals(event.Id , result.events[0].eventId);
        //system.assertEquals(task.Id , result.tasks[0].taskId);
        //system.assertEquals(true, result.isSuccess);
    }
    
    /**
    * Test getTasksAndEvents when date is missing
    */
    public TestMethod static void testGetTasksAndEventsDatemissing(){
        createTestData();
        Test.startTest();
        Calendar result = RetrieveCalendarService.getTasksAndEvents();
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }

    /**
    * Test getTasksAndEvents when date is invalid
    */    
    public TestMethod static void testGetTasksAndEventsException(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        request.params.put('date',today.year() + '-13-' + today.day());
        RestContext.request = request;
        Test.startTest();
        Calendar result = RetrieveCalendarService.getTasksAndEvents();
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
}