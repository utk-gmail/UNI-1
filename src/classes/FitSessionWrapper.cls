/*
* This is wrapper class for FitSession Infromation Webservice response.
*/
global with sharing class FitSessionWrapper extends Response{
    
    public DataWrapper data;
    
    /*
    * Inner Wrapper class for complete data.
    */
    public class DataWrapper { 
        //list of Departments, Department Line Items, Department Embellishments.
        public List<DepartmentWrapper> departments;
        
        //List of Contacts, Invoice Line Items, Invoice Embellishments.
        public List<ContactWrapper> contacts;
        
        //List of Opportunity Products through Service agreement relationship.
        public List<Product2> opportunityProducts;
        
        //List of Unique Products through Product Relationship.
        public List<Unique_Product__c> uniqueProducts;
        
        //List of Embellishments related to Quote Embellishments.
        public List<Embellishment__c> embellishments;
        
        //list of accounts where parentId = provided account Id.
        public List<Account> invoices;
    }//end DataWrapper class.
    
    /*
    * constructor
    */
    public FitSessionWrapper(){
        data = new DataWrapper();
        
        data.departments = new List<DepartmentWrapper>();
        data.contacts = new List<ContactWrapper>();
        data.opportunityProducts = new List<Product2>();
        data.uniqueProducts = new List<Unique_Product__c>();
        data.embellishments = new List<Embellishment__c>();
        data.invoices = new List<Account>();
    }
    
    /*
    * Department Section.
    */
    public class DepartmentWrapper {
        String name;
        String id;
        String externalId;
        String address;
        
        List<DepartmentLineItemWrapper> departmentLineItems;
        
        public DepartmentWrapper(Department__c department,
                                 List<DepartmentLineItemWrapper> departmentLineItems) {
            this.name = department.Name;
            this.id   = department.Id;
            this.externalId = department.External_Id__c;
            this.address = department.Address__c;                            
            this.departmentLineItems = departmentLineItems;
        }
    }//end DepartmentWrapper class.
    
    /*
    * Department Line Item & Embellishment Wrapper.
    */
    public class DepartmentLineItemWrapper {
        String id;
        String name;
        String opportunityId;
        String externalId;
        
        List<Department_Embellishment__c> departmentEmbellishments;
    
        public DepartmentLineItemWrapper(Department_Line_Item__c departmentLineItem,
                                         List<Department_Embellishment__c> departmentEmbellishments) {
            this.id = departmentLineItem.Id;
            this.name = departmentLineItem.Name;
            this.opportunityId = departmentLineItem.Id;
            this.externalId = departmentLineItem.External_Id__c;
            this.departmentEmbellishments = departmentEmbellishments;                            
        }
    }//end DepartmentLineItemWrapper class
    
    /* 
    * Contact Section.
    */
    
    public class ContactWrapper {
        public String name;
        public String accountId;
        public String firstName;
        public Id id;
        public String department;
        public String lastName;
        List<InvoiceLineItemWrapper> invoiceLineItems;
        
        public ContactWrapper(Contact contact,
                              List<InvoiceLineItemWrapper> invoiceLineItems) {
            this.name = contact.Name;
            this.accountId = contact.AccountId;
            this.firstName = contact.firstName;
            this.lastName = contact.lastName;
            this.department = contact.department;
            this.invoiceLineItems = invoiceLineItems;
        }
    }//end ContactWrapper class.
    
    /*
    * Invoice Line Item & Embellishments wrapper.
    */ 
    public class InvoiceLineItemWrapper {
        public String name;
        public String wearer;
        public String externalID;
        public Id id;
        public String invoice;
        List<Invoice_Embellishment__c> invoiceEmbellishments;   
        
        public InvoiceLineItemWrapper(Invoice_Line_Item__c invoiceLineItem,
                                      List<Invoice_Embellishment__c> invoiceEmbellishments) {
            this.name  = invoiceLineItem.Name;
            this.id    = invoiceLineItem.Id;
            this.wearer= invoiceLineItem.Wearer__c;
            this.externalId = invoiceLineItem.External_Id__c;
            this.invoice = invoiceLineItem.Invoice__C;                        
            this.invoiceEmbellishments = invoiceEmbellishments;                            
        }                                      
    }//end InvoiceLineItemWrapper class.
}//end class