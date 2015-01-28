/**
* This class tests the functionality of GlobalSearchService class
*/
@isTest
public class GlobalSearchServiceTest {
    /**
    * This method sets up test date
    */
    public static void setupTestData() {
        Account account = TestClassSetup.createAccount('Test Account - 001');
        Contact contact = TestClassSetup.createContact('Test LastName', account.Id);
        TestClassSetup.createEvent(Date.today(), UserInfo.getUserId(), account.Id, contact.Id);
        TestClassSetup.createTask(Date.today(), Date.today(), UserInfo.getUserId(), account.Id);
        Opportunity opportunity = TestClassSetup.createOpportunity('Test Opportunity - 001', account.Id);
        TestClassSetup.createQuote('Test Quote - 001', opportunity.Id);
        TestClassSetup.createContent();
        TestClassSetup.createLead('Test Lead - 001');
    }
    
    /**
    * This method tests global search with no params
    */
    public static TestMethod void testglobalSearchWithNoParams(){
        // create test data
        setupTestData();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_SEARCH_URL;
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalSearchService.ResponseWrapper response = GlobalSearchService.globalSearch();
        Test.stopTest();
        
        // validating the result
        system.assertEquals(1, response.accounts.size());
        system.assertEquals(1, response.contacts.size());
        system.assertEquals(1, response.opportunities.size());
        system.assertEquals(1, response.leads.size());
        system.assertEquals(1, response.quotes.size());
        system.assertEquals(1, response.contents.size());
    }
    
    /**
    * This method tests global search with param : searchTerm
    */
    public static TestMethod void testglobalSearchWithSearchTerm(){
        // create test data
        setupTestData();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_SEARCH_URL;
        request.params.put(GlobalSearchService.SEARCHTERM_PARAMETER, 'Test');
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalSearchService.ResponseWrapper response = GlobalSearchService.globalSearch();
        Test.stopTest();
    }
    
    /**
    * This method tests global search with params : searchTerm and category = Account
    */
    public static TestMethod void testglobalSearchWithSearchTermAndCategory(){
        // create test data
        setupTestData();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_SEARCH_URL;
        request.params.put(GlobalSearchService.SEARCHTERM_PARAMETER, 'Test Account - 001');
        request.params.put(GlobalSearchService.CATEGORY_PARAMETER, 'Account');
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalSearchService.ResponseWrapper response = GlobalSearchService.globalSearch();
        Test.stopTest();
    }
    
    /**
    * This method tests global search with params : searchTerm and category = Content
    */
    public static TestMethod void testglobalSearchWithSearchTermAndCategoryAsContent(){
        // create test data
        setupTestData();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_SEARCH_URL;
        request.params.put(GlobalSearchService.SEARCHTERM_PARAMETER, 'Test');
        request.params.put(GlobalSearchService.CATEGORY_PARAMETER, 'Content');
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalSearchService.ResponseWrapper response = GlobalSearchService.globalSearch();
        Test.stopTest();
    }
    
    /**
    * This method tests global search with params : searchTerm, category, subCategory
    */
    public static TestMethod void testglobalSearchWithAllParams(){
        // create test data
        setupTestData();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_SEARCH_URL;
        request.params.put(GlobalSearchService.SEARCHTERM_PARAMETER, 'Yahoo.com');
        request.params.put(GlobalSearchService.CATEGORY_PARAMETER, 'Content');
        request.params.put(GlobalSearchService.SUBCATEGORY_PARAMETER, 'Popular');
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalSearchService.ResponseWrapper response = GlobalSearchService.globalSearch();
        Test.stopTest();
    }
    
    /**
    * This method tests global search with param : category
    */
    public static TestMethod void testglobalSearchWithCategory(){
        // create test data
        setupTestData();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_SEARCH_URL;
        request.params.put(GlobalSearchService.CATEGORY_PARAMETER, 'Content');
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalSearchService.ResponseWrapper response = GlobalSearchService.globalSearch();
        Test.stopTest();
    }
    
    /**
    * This method tests global search with param : subCategory
    */
    public static TestMethod void testglobalSearchWithSubCategory(){
        // create test data
        setupTestData();
        
        RestRequest request = new RestRequest();
        request.requestURI = TestClassSetup.RESTAPI_BASEURL + 
            TestClassSetup.RESTAPI_GLOBAL_SEARCH_URL;
        request.params.put(GlobalSearchService.SUBCATEGORY_PARAMETER, 'Popular');
        RestContext.request = request;
        
        // start testing
        Test.startTest();
        GlobalSearchService.ResponseWrapper response = GlobalSearchService.globalSearch();
        Test.stopTest();
    }
}