/*
* Test Class for Close Fit Session webservice.
*/
@isTest
public with sharing class TestWSCloseFitSession {
    private static Account account;
    private static Opportunity curOpportunity;
    
    /*
    * Creates seed data using TestClassSetup needed for positive & negative tests.
    */
    private static void createSeedData() {
        account = TestClassSetup.createAccount('Test Account');
        curOpportunity = TestClassSetup.createOpportunity('Test Opportunity');        
    }
    
    /*
    * Method runs Positive Test Cases for WSCloseFitSession Webservice.
    */
    public static testMethod void runPositiveTests(){
        /*
        * Test case 1 : Sizing complete is updated correctly.
        */
        Map<String,String> jsonMap = new Map<String,String>();
        
        //Create Seed Data.
        createSeedData();        
        
        account.Current_Opportunity__c = curOpportunity.Id;
        update account;
        
        //Assert Sizing complete is false before calling webservice.
        System.assertEquals(false,curOpportunity.sizing_complete__c);
        
        //REST Setup for test.
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = '/Account/FitSession/Close';
        req.httpMethod = 'POST';
        
        jsonMap.put('accountId',account.Id);
        req.requestBody = Blob.valueOf(TestClassSetup.createRequestJson(jsonMap));
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Response response = WSCloseFitSession.sessionClose();
        Test.stopTest();
        
        //Assert Sizing complete is marked true. Requery Opportunity for assert.
        Opportunity opp = [Select Id,Name,
                                  sizing_complete__c
                           From Opportunity
                           Where ID =: curOpportunity.Id];
        System.assertEquals(true,opp.sizing_complete__c);
    }//end runPositiveTests.
    
    
    /*
    * Method runs all negative tests for WSCloseFitSession webservice.
    */
    public static testMethod void runNegativeTests(){
        
        Map<String,String> jsonMap = new Map<String,String>();
        
        //Create Seed Data.
        createSeedData();       
        
        //REST Setup for test.
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = '/Account/FitSession/Close';
        req.httpMethod = 'POST';
                
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        /*
        * Test Case 1 : No Account Id Provided. Account Id string is null.
        */
        //Passing empty string as accountId;
        jsonMap.put('accountId','');
        req.requestBody = Blob.valueOf(TestClassSetup.createRequestJson(jsonMap));
   
        Response response = WSCloseFitSession.sessionClose();
        
        //Assert response message.
        System.assertEquals(System.Label.ACCOUNT_ID_NULL,response.message);
        
        /*
        * Test Case 2 : Account Not Found for provided accountID.
        */
        jsonMap.clear();
        jsonMap.put('accountId','0019000001A9Uc9');
        req.requestBody = Blob.valueOf(TestClassSetup.createRequestJson(jsonMap));
        
        response = WSCloseFitSession.sessionClose();
        
        //Assert response message.
        System.assertEquals(System.Label.Account_ID_not_found,response.message);
        
        /*
        * Test Case 3 : No Request Params found.
        */
        req.requestBody = null;
        
        response = WSCloseFitSession.sessionClose();
        
        //Assert response message.
        System.assertEquals(System.Label.UNABLE_PARSE_REQ_PARAMS,response.message);
                
        /*
        * Test Case 4 : Account is found but current opportunity is null.
        */
        jsonMap.clear();
        jsonMap.put('accountId',account.Id);
        req.requestBody = Blob.valueOf(TestClassSetup.createRequestJson(jsonMap));
        
        response = WSCloseFitSession.sessionClose();
        
        //Assert response message.
        System.assertEquals(System.Label.Current_Opportunity_Not_Found,response.message);
        
        /*
        * Test Case 5 : Unexpected Test Exception.
        */
        TestClassSetup.throwTestException = true;
        response = WSCloseFitSession.sessionClose();
        
        //Assert response message.
        System.assertEquals('Test Exception',response.message);
        Test.stopTest();        
        
    }//end runNegativeTests.
}