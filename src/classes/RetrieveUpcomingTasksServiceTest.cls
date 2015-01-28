/**
* This class tests the functionality of RetrieveUpcomingTasksService class
*/
@isTest
public class RetrieveUpcomingTasksServiceTest{
    
    static Task task;
    
    /**
    * Create test data
    */
    private static void createTestData(){
        Account account = TestClassSetup.createAccount('Test Account');
        Contact contact = TestClassSetup.createContact('Test Contact');
        task = TestClassSetup.createTask(System.today()+1, System.today(), UserInfo.getUserId(), account.Id);
        Task task2 = TestClassSetup.createTask(System.today()+1, System.today(), UserInfo.getUserId(), account.Id);
    }
    
    /**
    * Test getUpcomingTasks
    */
    public TestMethod static void testGetUpcomingTasks(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        request.params.put('date',today.year() + '-' + today.month() + '-' + today.day());
        RestContext.request = request;
        Test.startTest();
        UpComingTask result = RetrieveUpcomingTasksService.getUpcomingTasks();
        Test.stopTest();
        //system.assertEquals(task.Id , result.tasks[0].taskId);
        //system.assertEquals(2, result.tasks.size());
        //system.assertEquals(true, result.isSuccess);
    }
    
    /**
    * Test getUpcomingTasks when date is missing
    */
    public TestMethod static void testGetUpcomingTasksDatemissing(){
        createTestData();
        Test.startTest();
        UpComingTask result = RetrieveUpcomingTasksService.getUpcomingTasks();
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
    
    /**
    * Test getUpcomingTasks when date is invalid
    */
    public TestMethod static void testGetUpcomingTasksException(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        request.params.put('date',today.year() + '-13-' + today.day());
        RestContext.request = request;
        Test.startTest();
        UpComingTask result = RetrieveUpcomingTasksService.getUpcomingTasks();
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
}