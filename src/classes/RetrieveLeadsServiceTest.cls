/**
* This class tests the functionality of RetrieveLeadsService class
*/
@isTest
public class RetrieveLeadsServiceTest{
    
    /**
    * Create test data
    */
    private static void createTestData(){
        List<Lead> leadList = new List<Lead>();
        for(Integer i = 0; i < 10; i++){
            Lead lead = new Lead(LastName = 'Test Lead '+i);
            lead.Company = 'Test Company '+i;
            lead.NumberOfEmployees = 12;
            lead.Interest_Uniform_Rental_Program__c = true;
            leadList.add(lead);
        }
        insert leadList;
    }
    
    /**
    * This method tests retrieveLeads
    */
    public static TestMethod void testRetrieveLeads(){
        createTestData();
        RestRequest request = new RestRequest();
        RestContext.request = request;
        Test.startTest();
        RetrieveLeadsService.UserLeads result = RetrieveLeadsService.retrieveLeads();
        Test.stopTest();
        system.assertEquals(true, result.isSuccess);
        system.assertEquals(10, result.leads.size());
    }
    
    /**
    * This method tests retrieveLeads invalid ownerId
    */
    public static TestMethod void testRetrieveLeadsInvalidOwnerId(){
        createTestData();
        RestRequest request = new RestRequest();
        request.params.put(ServiceUtils.User_ID_PARAMETER,'Test');
        RestContext.request = request;
        Test.startTest();
        RetrieveLeadsService.UserLeads result = RetrieveLeadsService.retrieveLeads();
        Test.stopTest();
        system.assertEquals(false, result.isSuccess);
    }
    
}