/*
* This class forms all dynamic SOQLs without where clauses.
* Any field, added later & which needs to be queried, can be added in appropriate dynamic SOQL string.
*/
public with sharing class ProcessQueryUtil {
    
    public static String getSkinnyAccountFieldsQuery() {
        String retVal = 'Select Id,Name,'+
                      'Current_Opportunity__r.Id,'+
                      'Current_Opportunity__r.Sizing_Complete__c '+
                 'From Account ';
    
        return retVal;     
    }//end getSkinnyAccountFieldsQuery
    
    public static String getSkinnyQueryForDepartmentLineItem() {
        return 'Select Id,Name,'+
                       'Department__c,'+
                       'External_ID__c,'+
                       '(Select Id,Name,'+
                                'Description__c,'+
                                'External_ID__c'+
                         ' From Department_Embellishments__r)'+
                ' From Department_Line_Item__c ';
    }//end getSkinnyQueryForDepartmentLineItem
    
    public static String getSkinnyQueryForInvoiceLineItem() {
        return 'Select Id,Name,'+
                        'Invoice__c,'+
                        'External_ID__c,'+
                        'Wearer__c,'+
                        '(Select Id,Name,'+
                                'Description__c,'+
                                'External_ID__c'+
                         ' From Invoice_Embellishments__r)'+
               ' From Invoice_Line_Item__c';
    }//end getSkinnyQueryForInvoiceLineItem
    
    public static String getSkinnyQueryForUniqueProduct() {
        return 'Select Id,Name From Unique_Product__c ';
    }//end getSkinnyQueryForUniqueProduct
    
    public static String getSkinnyQueryForQuoteEmbellishment() {
        String retVal = 'Select Id,Name,'+
                               'Embellishment__c,'+
                               'Embellishment__r.Name,'+
                               'Embellishment__r.Location__c'+
                        ' From Quote_Embellishment__c';
        return retVal;
    }//end getSkinnyQueryForQuoteEmbellishment
    
    public static String getSkinnyQueryForOpportunityProducts() {
        String retVal = 'Select Id,Name,'+
                             'Product__r.Id,'+
                             'Product__r.Name,'+
                             'Product__r.Family,'+
                             'Product__r.Description,'+
                             'Product__r.ProductCode,'+
                             'Product__r.IsActive'+
                        ' From Opportunity_Product__c ';
        return retVal;
    }//end getSkinnyQueryForOpportunityProducts
    
    public static String getSkinnyQueryForFitSession() {
        Map<String,RecordType> rtMap = ServiceUtils.getRecordTypeMap();
        String retVal = 'Select Id,Name,'+
                                'parentID,'+
                                '(Select Id,Name,'+
                                        'FirstName,'+
                                        'LastName,'+
                                        'accountId,'+
                                        'Department,'+
                                        'External_Id__c,'+
                                        'Locker_Number__c,'+
                                        'Locker_Bank__c,'+
                                        'Notes__c,'+
                                        'Gender__c'+
                                 ' From Contacts '+
                                 ' Where RecordTypeID = '+ '\'' + rtMap.get(System.Label.WEARER_RECORD_TYPE).Id + '\'' +'),'+
                                '(Select Id,Name,'+
                                        'Address__c,'+
                                        'External_ID__c,'+
                                        'Delivery_Location__c'+
                                 ' From Departments__r),'+
                               '(Select Id,Name,'+
                                       'Opportunity__c'+
                                ' From Service_Agreements__r),'+
                               '(Select ID,Name From Opportunities),'+
                               '(Select Id,Name, '+
                                        'AccountNumber,'+
                                        'Active__c,'+
                                        'AnnualRevenue,'+
                                        'BillingCity,'+
                                        'BillingCountry,'+
                                        'BillingPostalCode,'+
                                        'BillingState,'+
                                        'BillingStreet,'+
                                        'Current_Opportunity__c,'+
                                        'CustomerPriority__c,'+
                                        'Description,'+
                                        'External_ID__c,'+
                                        'Fax,'+
                                        'Industry,'+
                                        'Language__c,'+
                                        'NumberofLocations__c,'+
                                        'Ownership,'+
                                        'ParentId,'+
                                        'Phone,'+
                                        'Product_Type__c,'+
                                        'Rating,'+
                                        'ShippingCity,'+
                                        'ShippingCountry,'+
                                        'ShippingPostalCode,'+
                                        'ShippingState,'+
                                        'ShippingStreet,'+
                                        'Sic,'+
                                        'Site,'+
                                        'SLAExpirationDate__c,'+
                                        'SLASerialNumber__c,'+
                                        'SLA__c,'+
                                        'TickerSymbol,'+
                                        'Type,'+
                                        'UpsellOpportunity__c,'+
                                        'Website '+
                               ' From ChildAccounts  Where RecordTypeID =\''+ rtMap.get(System.Label.INVOICE_RECORD_TYPE).Id +'\')'+                 
                         'From Account';
        return retVal;
    }//end getSkinnyQueryForFitSession.
}//end class.