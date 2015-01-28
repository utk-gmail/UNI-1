/*
* Test class for WSgetFitSession Webservice.
*/
@isTest
public with sharing class TestWSgetFitSession {
    
    private static Account account;
    private static Account invoice1;
    private static Contact contact;
    private static Opportunity opp1, opp2, opp3;
    private static Quote quo1,quo2;
    
    private static Invoice_Line_Item__c iLineItem1, iLineItem2;
    private static Invoice_Embellishment__c iEmbellishment;    
    
    private static Department__c dept;
    private static Department_Line_Item__c dLineItem1, dLineItem2;
    private static Department_Embellishment__c dEmbellishment1, dEmbellishment2;
    
    private static Service_Agreement__c sAgreement1, sAgreement2;
    private static Opportunity_Product__c oProduct1, oProduct2;
    private static Product2 prod1, prod2;    
    private static Unique_Product__c uProd1, uProd2;
    
    private static Quote_Line_Item__c qLineItem1, qLineItem2;
    private static Quote_Embellishment__c qEmb1, qEmb2;
    private static Embellishment__c  emb1,emb2; 
    
    private static void createSeedData(){
        Map<String,RecordType> rtMap = ServiceUtils.getRecordTypeMap();
        
        //Create Account.
        account = TestClassSetup.createAccount('Test Account');        
        
        //Create Invoices.               
        invoice1 = TestClassSetup.createAccount('Test Invoice',
                                                rtMap.get(System.Label.INVOICE_RECORD_TYPE).Id,account.Id);
        
        //Create Contact with Wearer Record Type.
        contact = TestClassSetup.createContactWithRecordType('Tim K',account.ID,
                                                             rtMap.get(System.Label.WEARER_RECORD_TYPE).Id);
                                                             
        //Create Opportunities
        opp1 = TestClassSetup.createOpportunity('Test Opp1');                                                             
        opp2 = TestClassSetup.createOpportunity('Test Opp2');
        
        // this opportunity is directly related to account. Not via service agreement.
        opp3 = TestClassSetup.createOpportunity('Test Opp3',account.Id); 
                
        //Create Invoice Line Item & Assign to Contact.
        iLineItem1 = TestClassSetup.createInvoiceLineItem('Invoice L1',contact,'121223423');
        iLineItem2 = TestClassSetup.createInvoiceLineItem('Invoice L2',contact,'221223423');
        
        //Create Invoice Embellishments.
        iEmbellishment = TestClassSetup.createInvoiceEmbellishment('Invoice Embellish 1',
                                                                    iLineItem1,
                                                                    '121223423',
                                                                    'Test_desc');
    
        //Create Department.
        dept = TestClassSetup.createDepartment('Dept 1',account,'32432423','Test_Desc');
        
        //Create Department Line Items.
        dLineItem1 = TestClassSetup.createDepartmentLineItem('Dept Line 1',dept,'32423');
        dLineItem2 = TestClassSetup.createDepartmentLineItem('Dept Line 2',dept,'42423');
        
        //Create Department Embellishments.
        dEmbellishment1 = TestClassSetup.createDepartmentEmbellishment('Dept Embe 1',
                                                                      dLineItem1,
                                                                      '546456',
                                                                      'TEst_Description');
        
        dEmbellishment2 = TestClassSetup.createDepartmentEmbellishment('Dept Embe 1',
                                                                      dLineItem2,
                                                                      '5464532',
                                                                      'TEst_Description');
    
        //Create Service Agreements.
        sAgreement1 = TestClassSetup.createServiceAgreement(account,opp1);
        sAgreement2 = TestClassSetup.createServiceAgreement(account,opp2);
        
        //Create Products.
        prod1 = TestClassSetup.createProduct('Test Prod 1','Test Desc');
        prod2 = TestClassSetup.createProduct('Test Prod 2','Test Desc');
        
        //Create Opportunity Products.
        oProduct1 = TestClassSetup.createOpportunityProduct(opp1,prod1);
        oProduct2 = TestClassSetup.createOpportunityProduct(opp2,prod2);
        
        //Create Unique Product;
        uProd1 = TestClassSetup.createUniqueProduct('Unique Prod1',prod1);
        
        //Create Quote
        quo1 = TestClassSetup.createQuote('Quote 1',opp1.Id);
        quo2 = TestClassSetup.createQuote('Qupte 2',opp2.Id);
        
        //Create Quote Line Items.
        qLineItem1 = TestClassSetup.createQuoteLineItem('Quo Line 1',quo1,prod1);
        qLineItem2 = TestClassSetup.createQuoteLineItem('Quo Line 2',quo2,prod2);
        
        //Create Embellishsments.
        emb1 = TestClassSetup.createEmbellishment('Emb 1','NY');
        emb2 = TestClassSetup.createEmbellishment('Emb 2','CA');
        
        //Create Quote line Embellishments.
        qEmb1 = TestClassSetup.createQuoteEmbellishment('QEmb1',qLineItem1,emb1);
        qEmb1 = TestClassSetup.createQuoteEmbellishment('QEmb2',qLineItem2,emb2);
         
    }
    
    /*
    * MEthod runs postivie test case.
    */
    public static testMethod void runPositiveTests1(){
        
        //Create Seed Data.
        account = TestClassSetup.createAccount('Test Account');
        
        //REST Setup for test.
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = '/Opportunity/FitSetup';
        req.httpMethod = 'GET';
        req.addParameter('accountId',account.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        /*
        * Test Case 1 : Account Id is valid but no related data available. All Lists are empty.
        */
        FitSessionWrapper fWrap = WSgetFitSessionInformation.getFitSessionInfo();
        
        //Asserts
        System.assertEquals(System.Label.FIT_INFORMATION_SUCCESS,fWrap.message);
        System.assertEquals(0,fWrap.data.departments.size());
        System.assertEquals(0,fWrap.data.contacts.size());
        System.assertEquals(0,fWrap.data.opportunityProducts.size());
        System.assertEquals(0,fWrap.data.uniqueProducts.size());
        System.assertEquals(0,fWrap.data.embellishments.size());
        System.assertEquals(0,fWrap.data.invoices.size());
        
        Test.stopTest();
    }//end runPositiveTests1.
    
    /*
    * MEthod runs postivie test case.
    */
    public static testMethod void runPositiveTests2(){
        
        //Create Seed Data.
        createSeedData();
        
        //REST Setup for test.
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = '/Opportunity/FitSetup';
        req.httpMethod = 'GET';
        req.addParameter('accountId',account.Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        /*
        * Test Case 2 : Account Id is valid. Response is recieved with expected Data.
        */
        FitSessionWrapper fWrap = WSgetFitSessionInformation.getFitSessionInfo();
        
        //Asserts
        System.assertEquals(System.Label.FIT_INFORMATION_SUCCESS,fWrap.message);
        System.assertEquals(1,fWrap.data.departments.size());
        System.assertEquals(1,fWrap.data.contacts.size());
        System.assertEquals(2,fWrap.data.opportunityProducts.size());
        System.assertEquals(1,fWrap.data.uniqueProducts.size());
        System.assertEquals(2,fWrap.data.embellishments.size());
        System.assertEquals(1,fWrap.data.invoices.size());
        
        Test.stopTest();
    }//end runPositiveTests2
    
    /*
    * MEthod runs negative test cases.
    */
    public static testMethod void runNegativeTests(){
        
        //Create Seed Data.
        createSeedData();
        
        //REST Setup for test.
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
 
        req.requestURI = '/Opportunity/FitSetup';
        req.httpMethod = 'GET';
        req.addParameter('accountId','');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        /*
        * Test Case 1 : Account Id is empty.
        */
        FitSessionWrapper fWrap = WSgetFitSessionInformation.getFitSessionInfo();
        
        //Asserts
        System.assertEquals(System.Label.ACCOUNT_ID_NULL,fWrap.message);
        
        /*
        * Test Case 2 : Invalid Salesforce Account Id. Throws exception.
        */
        req.addParameter('accountId','sdlkdsaldlajds');
        fWrap = WSgetFitSessionInformation.getFitSessionInfo();
        
        //Asserts
        System.assertEquals(true,fWrap.message.contains('invalid ID field'));
        
        /*
        * Test Case 3 : No Account Found.
        */
        Id aID = account.Id;
        
        //deleting account so it will not be found in webservice.
        delete account;
        
        req.addParameter('accountId',aID);
        fWrap = WSgetFitSessionInformation.getFitSessionInfo();
        
        //Asserts
        System.assertEquals(System.Label.Account_Not_Found_Msg,fWrap.message);
        Test.stopTest();
    }//end runNegativeTests
}