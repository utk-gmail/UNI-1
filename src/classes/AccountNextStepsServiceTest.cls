/**
* This class tests the functionality of AccountNextStepsService class
*/
@isTest
public class AccountNextStepsServiceTest {
    /**
    * This method tests Next steps for Account Service with missing Account
    */
    public static TestMethod void testAccountNextStepsServiceWithAccountMissing() {
        // Create test data
        AccountNextStepsService.AccountWrapper accountWrapper = new AccountNextStepsService.AccountWrapper();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_ACCOUNT_NEXT_STEPS_URL;
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        AccountNextStepsService.ResponseWrapper response = AccountNextStepsService.createNextSteps(accountWrapper);
        Test.stopTest();
        
        // validating the result
        system.assertNotEquals(null, response);
        system.assertEquals(false, response.isSuccess);
    }
    
    /**
    * This method tests Next steps for Account Service with status
    */
    public static TestMethod void testAccountNextStepsServiceWithStatus() {
        // Create test data
        AccountNextStepsService.AccountWrapper accountWrapper = new AccountNextStepsService.AccountWrapper();
        accountWrapper.Account = '001900000194gtF';
        accountWrapper.WhatWasDone = 'Teleprospecting';
        accountWrapper.NewStage = 'Discovery';
        accountWrapper.Status = 'Service Not Applicable';
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_ACCOUNT_NEXT_STEPS_URL;
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        AccountNextStepsService.ResponseWrapper response = AccountNextStepsService.createNextSteps(accountWrapper);
        Test.stopTest();
        
        // validating the result
        system.assertNotEquals(null, response);
        system.assertEquals(true, response.isSuccess);
    }
    
    /**
    * This method tests Next steps for Account Service without status
    */
    public static TestMethod void testAccountNextStepsServiceWithoutStatus() {
        // Create test data
        AccountNextStepsService.AccountWrapper accountWrapper = new AccountNextStepsService.AccountWrapper();
        accountWrapper.Account = '001900000194gtF';
        accountWrapper.WhatWasDone = 'Teleprospecting';
        accountWrapper.NewStage = 'Discovery';
        
        AccountNextStepsService.NoteWrapper note = new AccountNextStepsService.NoteWrapper();
        note.Name = 'Teleprospecting Results';
        note.Text = 'These guys have no set uniforms, and have no legal requirements that would require our services.';
        note.Attachments = new String[] {'06990000001NUL1AAO', '06990000001NVatAAG', '06990000001NWhmAAG'};
        accountWrapper.Note = note;
        
        AccountNextStepsService.ActivityWrapper activity = new AccountNextStepsService.ActivityWrapper();
        activity.Type = 'Event';
        activity.AssignedTo = UserInfo.getUserId();
        activity.Subject = 'Call';
        activity.StartDateTime = ''+DateTime.now();
        activity.EndDateTime = ''+DateTime.now();
        accountWrapper.Activity = activity;
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_ACCOUNT_NEXT_STEPS_URL;
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        AccountNextStepsService.ResponseWrapper response = AccountNextStepsService.createNextSteps(accountWrapper);
        Test.stopTest();
        
        // validating the result
        system.assertNotEquals(null, response);
        system.assertEquals(true, response.isSuccess);
    }
}