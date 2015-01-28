/**
* This class tests the functionality of RetrieveAccountService class
*/
@isTest
public class RetrieveAccountServiceTest{
    
    static Account account;
    
    /**
    * Create test data
    */
    private static void createTestData(){
        account = new Account();
        account.Name = 'Test Account';
        account.Type = 'Customer - Direct';
        account.D_B_Phone__c =  '1234567890';
        account.Number_of_Wearers__c = 12;
        account.Top_25__c = true;
        account.Direct_Mail_Opt_Out__c = false;
        insert account;
    }
    
    /**
    * This method tests modified retrieveAccount
    */
    public static TestMethod void testModifiedRetrieveAccount(){
        // create test data
        createTestData();
        Contact contact = TestClassSetup.createContact('Test LastName', account.Id);
        TestClassSetup.createEvent(Date.today(), UserInfo.getUserId(), account.Id, contact.Id);
        TestClassSetup.createTask(Date.today(), Date.today(), UserInfo.getUserId(), account.Id);
        Opportunity opportunity = TestClassSetup.createOpportunity('Test Opportunity - 001', account.Id);
        TestClassSetup.createQuote('Test Quote - 001', opportunity.Id);
        Note__c note = TestClassSetup.createNote('Test Note', 'Test text', account.Id);
        ContentVersion content = [SELECT ContentDocumentId FROM ContentVersion where Id = :TestClassSetup.createContent().Id];
        
        Attachment__c attachment = TestClassSetup.createAttachment(note.Id, content.ContentDocumentId);
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_RETRIEVE_ACCOUNT_URL;
        request.params.put('accountId',account.Id);
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        RetrieveAccountService.AccountWrapper result = RetrieveAccountService.retrieveAccount();
        Test.stopTest();
        
        // validating the result
        system.assertEquals(account.Id , result.id);
        system.assertEquals('true', result.top25);
        system.assertEquals('false', result.directMailOptOut);
    }
    
    /**
    * This method tests retrieveAccount
    */
    public static TestMethod void testRetrieveAccount(){
        createTestData();
        RestRequest request = new RestRequest();
        request.params.put('accountId',account.Id);
        RestContext.request = request;
        Test.startTest();
        RetrieveAccountService.AccountWrapper result = RetrieveAccountService.retrieveAccount();
        Test.stopTest();
        system.assertEquals(account.Id , result.id);
        system.assertEquals('true', result.top25);
        system.assertEquals('false', result.directMailOptOut);
    }
    
    /**
    * This method tests retrieveAccount when account Id is not passed
    */
    public static TestMethod void testRetrieveAccountNotPassedAccId(){
        RestRequest request = new RestRequest();
        RestContext.request = request;
        Test.startTest();
        RetrieveAccountService.AccountWrapper result = RetrieveAccountService.retrieveAccount();
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
    
    /**
    * This method tests retrieveAccount when account Id is invalid
    */
    public static TestMethod void testRetrieveAccountInvalidAccId(){
        RestRequest request = new RestRequest();
        request.params.put('accountId','test');
        RestContext.request = request;
        Test.startTest();
        RetrieveAccountService.AccountWrapper result = RetrieveAccountService.retrieveAccount();
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
}