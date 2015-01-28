/**
* This class tests the functionality of DispositionEventService class
*/
@isTest
public class DispositionTaskServiceTest{
    
    static Task task;
    
    /**
    * Create test data
    */
    private static void createTestData(){
        Account account = TestClassSetup.createAccount('Test Account');
        Contact contact = TestClassSetup.createContact('Test Contact');
        task = TestClassSetup.createTask(System.today(), System.today(), UserInfo.getUserId(), account.Id);
    }
    
    /**
    * Test doTaskDisposition 
    */
    public TestMethod static void testDoTaskDisposition(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionTaskService.DispositionTaskResponse result = DispositionTaskService.doTaskDisposition(task.Id, 'Done', system.today() + 1);
        Test.stopTest();
        system.assertEquals(true, result.isSuccess);
        system.assertEquals('Done', [Select Status from Task where id =: task.Id][0].Status);
        system.assertEquals(system.today() + 1, [Select SnoozeDate__c from Task where id =: task.Id][0].SnoozeDate__c);
    }
    
    /**
    * Test doTaskDisposition when task id is missing
    */
    public TestMethod static void testDoTaskDispositionEventMissing(){
        createTestData(); 
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionTaskService.DispositionTaskResponse result = DispositionTaskService.doTaskDisposition(null, 'Done', system.today() + 1);
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
        
    }
    
    /**
    * Test doTaskDisposition when status is missing
    */
    public TestMethod static void testDoTaskDispositionStatusMissing(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionTaskService.DispositionTaskResponse result = DispositionTaskService.doTaskDisposition(task.id, null, system.today() + 1);
        Test.stopTest();
        system.assertEquals(true, result.isSuccess);
        system.assertEquals(system.today()+1, [Select SnoozeDate__c from Task where id =: task.Id][0].SnoozeDate__c);
        
    }
    
    /**
    * Test doTaskDisposition when snooze date and status are missing
    */
    public TestMethod static void testDoTaskDispositionSnoozeDateMissing(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionTaskService.DispositionTaskResponse result = DispositionTaskService.doTaskDisposition(task.id, null, null);
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
    
    /**
    * Test doTaskDisposition when task id is not valid
    */
    public TestMethod static void testDoTaskDispositionInvalidEventId(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionTaskService.DispositionTaskResponse result = DispositionTaskService.doTaskDisposition('test','Done', system.today() + 1);
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
    
    /**
    * Test doTaskDisposition when event status is invalid
    */
     public TestMethod static void testDoTaskDispositionInvalidStatus(){
        createTestData();
        RestRequest request = new RestRequest();
        Date today = system.today();
        Test.startTest();
        DispositionTaskService.DispositionTaskResponse result = DispositionTaskService.doTaskDisposition(task.id,'Test', system.today() + 1);
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
}