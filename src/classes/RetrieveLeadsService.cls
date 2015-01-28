/**
* This rest service is used to retrieve leads of current user
*/
@RestResource(urlMapping='/Leads/RetrieveLeads')
global with sharing class RetrieveLeadsService{
 	
 	/**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static UserLeads retrieveLeads() {
        UserLeads userLeads;
        try{
        	RestRequest request = RestContext.request;
        	String userIdIdParam = request.params.get(ServiceUtils.User_ID_PARAMETER);
        	
        	/**
        	* Pass user id parameter value and false to notify that ownerId is not used as parameter.
        	* This boolean is used to show different error message for ownerId as parameter and userId as parameter 
        	*/
        	String userId = ServiceUtils.getUserParameter(userIdIdParam, false);
        	
        	/**
        	* Check if record type is present in leads
        	*/         
	        Boolean recordTypePresent = isRecordTypePresent();
	        String fields = 'Id, Name, Status, Street, City, State, Country, PostalCode, Phone, Industry, ' +
	        				'Comments__c, NumberOfEmployees, Interest_Uniform_Rental_Program__c, Interest_Purchase_Program__c, '+
	        				'Interest_Facility_Service_Program__c, Interest_Flame_Resistant_Apparel__c, Interest_National_Program__c,'+
	        				'Interest_Other__c, Currently_Seeking_National_Program__c, Email_Sign_Up__c, Existing_Program__c, Bid_Package__c';
	        /**
	        * Add record type field if it is defined for lead object
	        */				
	        if(recordTypePresent){
	        	fields += ', RecordType.Name ';
	        }			
	        /**
	        * Fetch leads
	        */
	        List<Lead> leadList = Database.query('Select ' + fields + ' from Lead where OwnerId =: userId');
	        List<LeadWrapper> leads = new List<LeadWrapper>();
	        for(Lead lead: leadList){
	            leads.add(new LeadWrapper(lead, recordTypePresent));
	        }
	        userLeads = new UserLeads(leads);
        }
        catch(Exception ex){
        	userLeads = new UserLeads(ex.getMessage());
        }
        return userLeads;
    }
    
    /**
    * This method is used to check if record type field is present on lead object
    */
    static boolean isRecordTypePresent(){
        return Lead.getSobjectType().getDescribe().Fields.getMap().containsKey('recordtypeid');
    }

	/**
	* This wrapper is used to store lead retrieve response
	*/           
    global class UserLeads{
        global List<LeadWrapper> leads;
        global boolean isSuccess;
        global String message;
        
        /**
        * Constructor for error message
        */
        public UserLeads(String message){
        	isSuccess = false;
        	this.message = message;	
        }
        
        /**
        * Constructor for storing leads
        */
        public UserLeads(List<LeadWrapper> leads){
            isSuccess = true;
            this.leads = leads;
            message = '';
        }
    } 
           
    /**
    * This wrapper is used to store lead information
    */           
    class LeadWrapper{
        public String id;
        public String recordType;
        public String name;
        public String status;
        public String address;
        public String phoneNumber;
        public String industry;
        public String comments;
        public String numberOfEmployees;
        public String uniformRentalProgram;
        public String purchaseProgram;
        public String facilityServiceProgram;
        public String flameResistantApparel;
        public String nationalProgram;
        public String other;
        public String currentlySeekingNationalProgram;
        public String emailSignUp;
        public String existingProgram;
        public String bidPackage;
        
        LeadWrapper(Lead leadInstance, Boolean copyRecordType){
            id = leadInstance.Id;
            recordType = '';
            /**
            * Get record type name if record type field is present on lead
            */
            if(copyRecordType && leadInstance.getSobject('RecordType') != null){
                recordType = leadInstance.getSobject('RecordType').get('Name')+'';
            }
            name = leadInstance.Name;
            status = leadInstance.Status;
            
            /**
            * Create address
            */    
            address = getAddress(leadInstance);
            phoneNumber = ServiceUtils.getNotNullValue(leadInstance.Phone);
            industry = ServiceUtils.getNotNullValue(leadInstance.Industry);
            comments = ServiceUtils.getNotNullValue(leadInstance.Comments__c);
            numberOfEmployees = leadInstance.NumberOfEmployees != null ? leadInstance.NumberOfEmployees + '' : '';
            uniformRentalProgram = ServiceUtils.getStringValue(leadInstance.Interest_Uniform_Rental_Program__c);
            purchaseProgram = ServiceUtils.getStringValue(leadInstance.Interest_Purchase_Program__c);
            facilityServiceProgram = ServiceUtils.getStringValue(leadInstance.Interest_Facility_Service_Program__c);
            flameResistantApparel = ServiceUtils.getStringValue(leadInstance.Interest_Flame_Resistant_Apparel__c);
            nationalProgram = ServiceUtils.getStringValue(leadInstance.Interest_National_Program__c);
            other = ServiceUtils.getStringValue(leadInstance.Interest_Other__c);
            currentlySeekingNationalProgram = ServiceUtils.getStringValue(leadInstance.Currently_Seeking_National_Program__c);
            emailSignUp = ServiceUtils.getStringValue(leadInstance.Email_Sign_Up__c);
            existingProgram = ServiceUtils.getStringValue(leadInstance.Existing_Program__c);
            bidPackage = ServiceUtils.getStringValue(leadInstance.Bid_Package__c);
        }
        
        /**
        * This method return address of lead
        * @lead: Lead instance for which address to be created
	    * @return: Concatenation of address fields 
        */
        String getAddress(Lead lead){
            String address = '';
            address += lead.Street != null ? lead.Street + ', ' : '';
            address += lead.City != null ? lead.City + ', ' : '';
            address += lead.State != null ? lead.State + ', ' : '';
            address += lead.Country != null ? lead.Country + ', ' : '';
            address += lead.PostalCode != null ? lead.PostalCode + ', ' : '';
            address.removeEnd(', ');
            return address;
        }
    }       
}