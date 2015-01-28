/**
* This class create test data
*/
@isTest
public class TestClassSetup{
    // Properties
    public static final String RESTAPI_BASEURL = system.URL.getSalesforceBaseUrl().toExternalForm() + 
        '/services/apexRest';
    public static final String RESTAPI_GLOBAL_STATICCONTENT_URL = '/Global/StaticContent';
    public static final String RESTAPI_GLOBAL_SEARCH_URL = '/Global/Search';
    public static final String RESTAPI_GLOBAL_POPULAR_URL = '/Global/Popular';
    public static final String RESTAPI_ACCOUNT_CREATE_URL = '/Account/Create';
    public static final String RESTAPI_GLOBAL_METADATA_URL = 'Global/Metadata';
    public static final String RESTAPI_GLOBAL_RETRIEVE_ACCOUNT_URL = 'Accounts/RetrieveAccount';
    public static final String RESTAPI_ACCOUNT_NEXT_STEPS_URL = 'Account/NextSteps';
    
    public static final String DEFAULT_WORKSPACE_NAME = 'First Library';
    
    public static boolean throwTestException = false;
    
    /**
    * Create Account
    */
    public static Account createAccount(String name){
        Account account = new Account();
        account.Name = name;
        insert account;
        return account;
    }
    
    public static Account createAccount(String name,Id recordTypeId, Id parentID){
        Account account = new Account();
        account.Name = name;
        account.parentId = parentId;
        account.RecordTypeId = recordTypeId;
        insert account;
        return account;
    }
    
    /**
    * Create Contact
    */
    public static Contact createContact(String lastName){
        Contact contact = new Contact();
        contact.LastName = lastName;
        insert contact;
        return contact;
    }
    
    public static Contact createContact(String lastName, Id accountId){
        Contact contact = new Contact();
        contact.LastName = lastName;
        contact.AccountId = accountId;
        insert contact;
        system.assertNotEquals(null, contact.Id, 'Unable to create Contact!');
        return contact;
    }
    
    public static Contact createContactWithRecordType(String lastName, String accountId,
                                                      ID recordTypeId) {
        Contact contact = new Contact();
        contact.LastName = lastName;
        contact.AccountId = accountId;
        contact.recordTypeId = recordTypeId;
        insert contact;
        system.assertNotEquals(null, contact.Id, 'Unable to create Contact!');
        return contact;    
    }
    
    /*
    * Create Invoice Line Item - Version API 1
    */
    public static Invoice_Line_Item__c createInvoiceLineItem(String name,
                                                             Contact con, String externalId){
        Invoice_Line_Item__c iLineItem = new Invoice_Line_Item__c();
        iLineItem.Name = name;
        iLineItem.Wearer__c = con.Id;
        iLineItem.External_Id__c = externalId;
        
        insert iLineItem;
        system.assertNotEquals(null, iLineItem.Id, 'Unable to create Invoice Line Item!');
        return iLineItem;  
    }
    
    /*
    * Create Invoice Embellishments - Version API 1
    */
    public static Invoice_Embellishment__c  createInvoiceEmbellishment(String name,
                                                                  Invoice_Line_Item__c  iLineItem, 
                                                                  String externalId,
                                                                  String description){
        Invoice_Embellishment__c iEmbe = new Invoice_Embellishment__c();
        iEmbe.Name = name;
        iEmbe.Invoice_Line_Item__c = iLineItem.Id;
        iEmbe.External_Id__c = externalId;
        iEmbe.Description__c = description;
        
        insert iEmbe;
        system.assertNotEquals(null, iEmbe.Id, 'Unable to create Invoice Embellishment!');
        return iEmbe;  
    }
    
    /*
    * Create Department - Version API 1
    */
    public static Department__c createDepartment(String name, Account acc,
                                                 String externalId,
                                                 String address){
        Department__c dept = new Department__c();
        dept.Name = name;
        dept.Delivery_Location__c = acc.Id;
        dept.External_Id__c = externalId;
        dept.Address__c = address;
        
        insert dept;
        system.assertNotEquals(null, dept.Id, 'Unable to create Department!');
        return dept; 
    }
    
    /*
    * Create Department Line Item - Version API 1
    */
    public static Department_Line_Item__c createDepartmentLineItem(String name,
                                                                     Department__c dept, 
                                                                     String externalId){
        Department_Line_Item__c iLineItem = new Department_Line_Item__c();
        iLineItem.Name = name;
        iLineItem.Department__c = dept.Id;
        iLineItem.External_Id__c = externalId;
        
        insert iLineItem;
        system.assertNotEquals(null, iLineItem.Id, 'Unable to create Department Line Item!');
        return iLineItem;  
    }
    
    /*
    * Create Department Embellishments - Version API 1
    */
    public static Department_Embellishment__c  createDepartmentEmbellishment(String name,
                                                                  Department_Line_Item__c  iLineItem, 
                                                                  String externalId,
                                                                  String description){
        Department_Embellishment__c iEmbe = new Department_Embellishment__c();
        iEmbe.Name = name;
        iEmbe.Department_Line_Item__c = iLineItem.Id;
        iEmbe.External_Id__c = externalId;
        iEmbe.Description__c = description;
        
        insert iEmbe;
        system.assertNotEquals(null, iEmbe.Id, 'Unable to create Department Embellishment!');
        return iEmbe;  
    }
    
    /*
    * Create Service Agreement - Version API 1
    * Acccount record type must be delivery location here.
    */
    public static Service_Agreement__c createServiceAgreement(Account acc, Opportunity opp){
        Service_Agreement__c sAgreement = new Service_Agreement__c();
        sAgreement.Delivery_Location__c = acc.Id;
        sAgreement.Opportunity__c = opp.Id;
        
        insert sAgreement;
        system.assertNotEquals(null, sAgreement.Id, 'Unable to create Service Agreement.!');
        return sAgreement;
    }    
    
    /*
    * Create Quote Line Item - Version API 1
    */
    public static Quote_Line_Item__c createQuoteLineItem(String name, Quote quo,Product2 prod){
        Quote_Line_Item__c qLineItem = new Quote_Line_Item__c();
        qLineItem.Name = name;
        qLineItem.Quote__c = quo.Id;
        qLineItem.Product__c = (prod != null) ? prod.ID : NULL;
        
        insert qLineItem;
        system.assertNotEquals(null, qLineItem.Id, 'Unable to create Qutoe Line Item.!');
        return qLineItem;
    }    
    
    /*
    * Create Quote Embellishments - Version API 1
    */
    public static Quote_Embellishment__c  createQuoteEmbellishment(String name,
                                                                  Quote_Line_Item__c  iLineItem, 
                                                                  Embellishment__c embe){
        Quote_Embellishment__c iEmbe = new Quote_Embellishment__c();
        iEmbe.Name = name;
        iEmbe.Quote_Line_Item__c = iLineItem.Id;
        iEmbe.Embellishment__c = embe.Id;
        
        insert iEmbe;
        system.assertNotEquals(null, iEmbe.Id, 'Unable to create Quote Embellishment!');
        return iEmbe;  
    }
    
    /*
    * Create  Embellishments - Version API 1
    */
    public static Embellishment__c  createEmbellishment(String name,
                                                        String loc){
        Embellishment__c iEmbe = new Embellishment__c();
        iEmbe.Name = name;
        iEmbe.Location__c = loc;
        
        insert iEmbe;
        system.assertNotEquals(null, iEmbe.Id, 'Unable to create Embellishment!');
        return iEmbe;  
    }                                                     
    
    /**
    * Create Lead
    */
    public static Lead createLead(String lastName){
        Lead lead = new Lead(
            LastName = lastName,
            Company = 'Test Comp',
            Status = 'Open - Not Contacted'
        );
        insert lead;
        system.assertNotEquals(null, lead.Id, 'Unable to create Lead!');
        return lead;
    }
    
    /**
    * Create Task
    */
    public static Task createTask(Date dueDate, Date startDate, Id ownerId, Id accountId){
        Task task = new Task();
        task.OwnerId = ownerId;
        task.WhatId = accountId;
        task.ActivityDate = dueDate;
        task.subject = 'Test Subject';
        task.status = 'Not Started';
        task.snoozeDate__c = system.today();
        task.Start_Date__c = startDate;
        insert task;
        system.assertNotEquals(null, task.Id, 'Unable to create Task!');
        return task;
    }
    
    /**
    * Create Event
    */
    public static Event createEvent(Date activityDate, Id ownerId, Id accountId, Id contactId){
        Event event = new Event();
        event.OwnerId = ownerId;
        event.WhatId = accountId;
        event.whoId = contactId;
        event.ActivityDate = activityDate;
        event.subject = 'Test Subject';
        event.Event_Status__c= 'Not Started';
        event.DurationInMinutes = 30;
        event.ActivityDateTime = system.now();
        insert event;
        system.assertNotEquals(null, event.Id, 'Unable to create Event!');
        return event;
    }
    
    /**
    * Create User
    */
    public static user createUser(Id managerId){
        User user = new User(Alias = 'standt', 
                            Email = 'standarduser@testcalendar.com', 
                            EmailEncodingKey = 'UTF-8', 
                            LastName = 'Testing', 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', 
                            ProfileId = Userinfo.getProfileId(), 
                            TimeZoneSidKey = 'America/Los_Angeles',
                            UserName = 'standarduser@testcalendar.com',
                            ManagerId = managerId);
        insert user;
        return user;
    }
    
    /**
    * Create Opportunity without acccount.
    */
    public static Opportunity createOpportunity(String name){
        Opportunity opportunity = new Opportunity(
            Name = name,
            CloseDate = Date.today(),
            StageName = 'Open',
            Amount = 10,
            Probability = 10
        );
        insert opportunity;
        system.assertNotEquals(null, opportunity.Id, 'Unable to create Opportunity!');
        return opportunity;
    }
    
    /**
    * Create Opportunity
    */
    public static Opportunity createOpportunity(String name, Id accountId){
        Opportunity opportunity = new Opportunity(
            Name = name,
            AccountId = accountId,
            CloseDate = Date.today(),
            StageName = 'Open',
            Amount = 10,
            Probability = 10
        );
        insert opportunity;
        system.assertNotEquals(null, opportunity.Id, 'Unable to create Opportunity!');
        return opportunity;
    }
    
    /*
    * Create  Opportunity Product - Version API 1
    */
    public static Opportunity_Product__c createOpportunityProduct(Opportunity opp, Product2 prod){
        Opportunity_Product__c oProd = new Opportunity_Product__c();
        oProd.Product__c = prod.ID;
        oProd.Opportunity__c = opp.Id;
        
        insert oProd;
        system.assertNotEquals(null, oProd.Id, 'Unable to create Opportunity Product!');
        return oProd;
    }
    
    /*
    * Create  Opportunity Product - Version API 1
    */
    public static Product2 createProduct(String name, String description){
        Product2 prod = new Product2();
        prod.Name = name;
        prod.description = description;
        
        insert prod;
        system.assertNotEquals(null, prod.Id, 'Unable to create Product!');
        return prod;
    }
    
    /*
    * Create  Unique Product - Version API 1
    */
    public static Unique_Product__c createUniqueProduct(String name, Product2 prod) {
        Unique_Product__c uProd = new Unique_Product__c();
        uProd.Name = name;
        uProd.Product__c = prod.Id;
        
        insert uProd;
        system.assertNotEquals(null, uProd.Id, 'Unable to create Unique Product!');
        return uProd;
    }
    
    
    /**
    * Create Quote
    */
    public static Quote createQuote(String name, Id opportunityId){
        Quote quote = new Quote(
            Name = name,
            OpportunityId = opportunityId
        );
        insert quote;
        system.assertNotEquals(null, quote.Id, 'Unable to create Quote!');
        return quote;
    }
    
    /**
    * Create Note
    */
    public static Note__c createNote(String name, String text, Id accountId){
        Note__c note = new Note__c(
            Name = name,
            Account__c = accountId,
            Text__c = text
        );
        insert note;
        system.assertNotEquals(null, note.Id, 'Unable to create Note__c!');
        return note;
    }
    
    /**
    * Create Attachment
    */
    public static Attachment__c createAttachment(Id noteId, Id contentDocumentId){
        Attachment__c attachment = new Attachment__c(
            Note__c = noteId,
            Content__c = contentDocumentId
        );
        insert attachment;
        system.assertNotEquals(null, attachment.Id, 'Unable to create Attachment__c!');
        return attachment;
    }
    
    /**
    * Create Content
    */
    public static ContentVersion createContent() {
        ContentVersion content = new ContentVersion();
        content.ContentURL = 'http://www.yahoo.com/';
        content.Title = 'Yahoo.com'; 
        insert content;
        system.assertNotEquals(null, content.Id, 'Unable to create Content!');
        content = [SELECT ContentDocumentId FROM ContentVersion where Id = :content.Id];
        ContentWorkspace workspace = [SELECT Id FROM ContentWorkspace WHERE Name = :DEFAULT_WORKSPACE_NAME];
        ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
        newWorkspaceDoc.ContentWorkspaceId = workspace.Id; 
        newWorkspaceDoc.ContentDocumentId = content.ContentDocumentId; 
        insert newWorkspaceDoc;

        content.tagCsv = 'Popular';
        update content;
        return content;
    }
    
    /*
    * Create Request JSON
    */
    public static String createRequestJson(Map<String,String> keyValMap){
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();
        
        for(String key : keyValMap.keyset()) {
            gen.writeStringField(key,keyValMap.get(key));
        }
        
        gen.writeEndObject();
        
        return gen.getAsString();
    }
    
}