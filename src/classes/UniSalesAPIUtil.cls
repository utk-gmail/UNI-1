/*
* This class holds complete implementation logic for WSCloseFitSession 
* & WSgetFitSessionInformation.
*/
public with sharing class UniSalesAPIUtil {
    
    /*
    * Method holds implementation logic for WSgetFitSessionInformation.
    * 
    * @param    accountId    Account Id for which we need to fet FitSession information.
    * @return   fitSession   Wrapper Response to be returned as Webservice response.
    */
    public FitSessionWrapper getFitSessionInformation(String accountId) {
        FitSessionWrapper fitSession = new FitSessionWrapper(); 
                
        //Lists
        List<Department__c> departments;
        List<Service_Agreement__c> serviceAgreements;
        List<Opportunity> opportunities;
        
        //Sets to be used for bulkified Query.
        Set<Id> departmentIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> serviceAgreementOpportunityIds = new Set<Id>();
        set<Id> opportunityIds = new Set<Id>();
        
        /*
        * This is extra feature provided for this challenge.
        * If different Unique Identifier is provided in custom setting then get that field,
        * else use 'Id' by default as described in requirement doc.
        */                
        String accountField = (CustomSettingUtil.getWebServiceParams().Account_Field_API_Name__c != NULL) 
                              ? CustomSettingUtil.getWebServiceParams().Account_Field_API_Name__c  
                              :'Id';
                
        /* 
        * We can not go below 1 Level in SOQL Aggreegate Query.
        * So we will query all necessary 1 level child records in below query.
        * & then we will requery all necessary sub-childs like Line items, embellishments etc.
        */
        String query = ProcessQueryUtil.getSkinnyQueryForFitSession();        
        query = query + ' Where '+ accountField + ' = '+ '\'' + accountID + '\'';
        
        try{         
            //query Account & its related 1 level child records.
            List<Account> accList = Database.Query(query);
            
            //If list is not empty, process.
            if(!accList.isEmpty()) {
                /*
                * Create set of Department, Service Agreements, Opportunities for further SOQLs.
                */
                for(Account acc : accList) {
                    //get all departments related to account.
                    departments = acc.Departments__r;
                
                    //get all service agreements related to account.
                    serviceAgreements = acc.Service_Agreements__r;
                    
                    //get all opportunities related to account.
                    opportunities = acc.Opportunities;
                    
                    //Create Set Of Ids for further SOQLs.
                    for(Contact con : acc.Contacts) {
                        contactIds.add(con.Id);
                    }
                    
                    for(Department__c department : departments) {
                        departmentIds.add(department.Id);
                    }
                    
                    for(Service_Agreement__c sAgreement : serviceAgreements) {
                        serviceAgreementOpportunityIds.add(sAgreement.Opportunity__c);
                    }
                    
                    for(Opportunity opportunity : opportunities) {
                        opportunityIds.add(opportunity.Id);
                    }
                    
                    //Assign all related invoices to FitSessionWrapper variable.
                    fitSession.data.invoices = acc.ChildAccounts;
                }
                
                //get all department line items & its embellishments.
                fitSession.data.departments = formDepartmentsList(departments,departmentIds);
                
                //get all Contacts, Invoice Line Items  & its embellishments.
                fitSession.data.contacts = formContactsList(accList[0].Contacts,contactIds);
                
                //get all embellishments related to account through Quote Line Items.
                fitSession.data.embellishments = formEmbellishmentsList(serviceAgreementOpportunityIds);
                
                //Querying Opportunity_product__C here to reuse it for getting Unique Products too. 
                query  =  ProcessQueryUtil.getSkinnyQueryForOpportunityProducts();
                query  = query + ' Where Opportunity__c in: serviceAgreementOpportunityIds '+
                                 ' AND Opportunity__c != NULL '+
                                 ' AND Product__c != NULL'; 
                                 
                List<Opportunity_Product__c> oProducts = Database.query(query);                
                
                /*
                * If Opportunity Product list is received empty, return Opportunity products 
                * & Unique Products as empty lists because both products needs to be fetched via 
                * Opportunity_product.
                */
                if(!oProducts.isEmpty()) {
                    //Get Product2 via Opportunity Product.
                    fitSession.data.opportunityProducts = formOpportunityProductsList(oProducts);
                    
                    //Get Unique Product via Opportunity Product.
                    fitSession.data.uniqueProducts = formUniqueProductsList(oProducts);
                } 
                
                fitSession.message = System.Label.FIT_INFORMATION_SUCCESS;  
                                             
            }else{
                //If list is empty, return no record found.
                fitSession.message = System.Label.Account_Not_Found_Msg;
            }   
                   
        }catch(Exception e){
            throw e;
        }       
                                                                                                          
        return fitSession;
    }//end getFitSessionInformation
    
    /*
    * Method forms List of Embellishments related to Account Id.
    *
    *@param List of Service Agreement Ids related to Account.
    *@return List of Embellishments.
    */
    private List<Embellishment__c> formEmbellishmentsList(set<Id> sAgreementOppIds){
        String que = '';
        
        List<Embellishment__c> retVal = new List<Embellishment__c>();
        Set<Id> qLineItemIds = new Set<Id>(); 
        
        //get related quotes.
        List<Quote> oppQuotes = [Select Id,Name,    
                                        (Select Id,Name From Quote_Line_Items__r)
                                 From Quote
                                 Where OpportunityId in: sAgreementOppIds];
                                 
        for(Quote quote : oppQuotes){
            
            if(quote.Quote_Line_Items__r != null 
                && !quote.Quote_Line_Items__r.isEmpty()){
            
                for(Quote_Line_Item__c qItem : quote.Quote_Line_Items__r){
                    qLineItemIds.add(qItem.Id);
                }
            }                                     
        }
        
        //get related Quote Line Items.
        que = ProcessQueryUtil.getSkinnyQueryForQuoteEmbellishment();
        que = que + ' Where Quote_Line_Item__c in: qLineItemIds '+
                    ' And  Quote_Line_Item__c != NULL';
                    
        List<Quote_Embellishment__c> quoteEmbellishments = Database.Query(que);

        //for list of Embellishment to return.
        if(!quoteEmbellishments.isEmpty()) {
            for(Quote_Embellishment__c qEmbellishment : quoteEmbellishments) {
                retVal.add(qEmbellishment.Embellishment__r);
            }
        }
        return retVal;
    }//end formEmbellishmentsList
    
    /*
    * Method forms List of Unique products related to Account Id.
    *
    *@param List of Opportunity_Product__c Ids related to Account.
    *@return List of Unique_Product__c.
    */
    private List<Unique_Product__c> formUniqueProductsList(List<Opportunity_Product__c> oProds) {
        String que = '';
        
        List<Unique_Product__c> retVal = new List<Unique_Product__c>();
        Set<ID> prodIds = new Set<ID>();
        
        for(Opportunity_Product__c oProd : oProds) {                
            prodIds.add(oProd.Product__r.Id);
        }
        
        //get List of Unique Products.
        que = ProcessQueryUtil.getSkinnyQueryForUniqueProduct();
        que = que + ' WHERE Product__c in: prodIds';
        retVal = Database.Query(que);
        
        return retVal;
    }//end formUniqueProductsList
    
    /*
    * Method forms List of Products related to Account Id via Opportunity_Product__c.
    *
    *@param List of Opportunity_Product__c Ids related to Account.
    *@return List of Product2.
    */
    private List<Product2> formOpportunityProductsList(List<Opportunity_Product__c> oProds) {
        List<Product2> retVal = new List<Product2>();
        
        for(Opportunity_Product__c oProd : oProds) {                
            retVal.add(oProd.Product__r);
        }
        
        return retVal;
        
    }//end formOpportunityProductsList
    
    /*
    * Method forms List of FitSessionWrapper.ContactWrapper 
    * related to Account Id.
    *
    *@param  List of Contacts related to Account.
    *@param  Set of contact Ids related to Account.
    *@return List of FitSessionWrapper.ContactWrapper.
    */
    private List<FitSessionWrapper.ContactWrapper> formContactsList(List<Contact> contacts,
                                                                      Set<ID> contactIds) {
        String que = '';                                                                      
        List<FitSessionWrapper.ContactWrapper> cWrapperList = new List<FitSessionWrapper.ContactWrapper>();
            
        Map<Id,List<Invoice_Line_Item__c>> invoiceLineItemsMap = new Map<Id,List<Invoice_Line_Item__c>>();
                
        //get Invoice Line Items.
        que = ProcessQueryUtil.getSkinnyQueryForInvoiceLineItem();
        que = que + ' Where Wearer__c in: contactIds '+
                    ' AND Wearer__c != NULL ';
        
        List<Invoice_Line_Item__c> invoiceLineItems = Database.Query(que);
        
        //Form map to assign contact to list of Line Items.
        for(Invoice_Line_Item__c iLineItem : invoiceLineItems) {
            List<Invoice_Line_Item__c> tempInvoiceLineItems;
               
            if(invoiceLineItemsMap.get(iLineItem.Wearer__c) != null) {
                tempInvoiceLineItems = invoiceLineItemsMap.get(iLineItem.Wearer__c);
                tempInvoiceLineItems.add(iLineItem);
                invoiceLineItemsMap.put(iLineItem.Wearer__c,tempInvoiceLineItems);
            }else{
                tempInvoiceLineItems = new List<Invoice_Line_Item__c>();
                tempInvoiceLineItems.add(iLineItem);
                invoiceLineItemsMap.put(iLineItem.Wearer__c,tempInvoiceLineItems);
            }
        }   
        
        //If related contacts are not null set, Add into Wrapper class.
        if(contacts != null && !contacts.isEmpty()){
            for(Contact con : contacts) {
                FitSessionWrapper.InvoiceLineItemWrapper iLineItemWrapper;
                List<FitSessionWrapper.InvoiceLineItemWrapper> iLineItemWrapperList 
                                                              = new List<FitSessionWrapper.InvoiceLineItemWrapper>();
                
                FitSessionWrapper.ContactWrapper cWrapper;
                
                //Get Department Line Items for each Department.                                              
                List<Invoice_Line_Item__c> tempInvoiceLineItems = invoiceLineItemsMap.get(con.Id);
                
                if(tempInvoiceLineItems != NULL && !tempInvoiceLineItems.isEmpty()) {
                    for(Invoice_Line_Item__c iLineItem : tempInvoiceLineItems) {
                        iLineItemWrapper = new FitSessionWrapper.InvoiceLineItemWrapper(iLineItem,
                                                                                        iLineItem.Invoice_Embellishments__r);
                        iLineItemWrapperList.add(iLineItemWrapper);
                    }
                    
                }else{
                    //Do nothing.
                }  
                     
                cWrapper = new FitSessionWrapper.ContactWrapper(con, iLineItemWrapperList);
                cWrapperList.add(cWrapper);         
            }
        } 
        
        return cWrapperList;
    }//end formContactList.
    
    /*
    * Method queries Department Line Items & Its Embellishments.
    * 
    * returns   list of FitSessionWrapper.DepartmentWrapper objects. 
    */
    private List<FitSessionWrapper.DepartmentWrapper> formDepartmentsList(List<Department__c> departments,
                                                                          Set<Id> departMentIds) {
        String que = '';
        List<FitSessionWrapper.DepartmentWrapper> dWrapperList 
                                                              = new List<FitSessionWrapper.DepartmentWrapper>();
                                                              
        /*
        * ID here is Department Id.
        */
        Map<Id,List<Department_Line_Item__c>> departmentLineItemsMap = new Map<Id,List<Department_Line_Item__c>>();
        
        que = ProcessQueryUtil.getSkinnyQueryForDepartmentLineItem();
        que = que + ' Where Department__c in: departmentIds '+
                    ' AND Department__c != NULL ';
        
        List<Department_Line_Item__c> departmentLineItems = Database.Query(que);
        
        //Form Map of line item id and its related embellishments.                                                  
        for(Department_Line_Item__c dLineItem : departmentLineItems) {
            List<Department_Line_Item__c> tempDepartmentLineItems;
               
            if(departmentLineItemsMap.get(dLineItem.Department__c) != null) {
                tempDepartmentLineItems = departmentLineItemsMap.get(dLineItem.Department__c);
                tempDepartmentLineItems.add(dLineItem);
                departmentLineItemsMap.put(dLineItem.Department__c,tempDepartmentLineItems);
            }else{
                tempDepartmentLineItems = new List<Department_Line_Item__c>();
                tempDepartmentLineItems.add(dLineItem);
                departmentLineItemsMap.put(dLineItem.Department__c,tempDepartmentLineItems);
            }
        }    
        
        //If related departments is not null set, Add into Wrapper class.
        if(departments != null && !departments.isEmpty()){
            for(Department__c department : departments) {
                FitSessionWrapper.DepartmentLineItemWrapper dLineItemWrapper;
                List<FitSessionWrapper.DepartmentLineItemWrapper> dLineItemWrapperList 
                                                              = new List<FitSessionWrapper.DepartmentLineItemWrapper>();
                
                FitSessionWrapper.DepartmentWrapper dWrapper;
                
                //Get Department Line Items for each Department.                                              
                List<Department_Line_Item__c> tempDepartmentLineItems = departmentLineItemsMap.get(department.Id);
                
                if(tempDepartmentLineItems != NULL && !tempDepartmentLineItems.isEmpty()) {
                    for(Department_Line_Item__c dLineItem : tempDepartmentLineItems) {
                        dLineItemWrapper = new FitSessionWrapper.DepartmentLineItemWrapper(dLineItem,
                                                                                           dLineItem.Department_Embellishments__r);
                        dLineItemWrapperList.add(dLineItemWrapper);
                    }
                    
                }else{
                    //Do nothing.
                }  
                     
                dWrapper = new FitSessionWrapper.DepartmentWrapper(department,
                                                                   dLineItemWrapperList);
                dWrapperList.add(dWrapper);         
            }
        }        
        
        return dWrapperList;
    }//end formDepartmentsList
    
    /*
    * Method holds implementation logic for WSgetFitSessionInformation.
    * 
    * @param    accountId    Account Id for which we need to fet FitSession information.
    * @return   result       result String as success/failure message.
    */    
    public String closeFitSession(String accountId) {
        String result = System.Label.Fit_Session_Closed;
        
        /*
        * This is extra feature provided for this challenge.
        * If different Unique Identifier is provided in custom setting then get that field,
        * else use 'Id' by default as described in requirement doc.
        */ 
        String accountField = (CustomSettingUtil.getWebServiceParams().Account_Field_API_Name__c != NULL) 
                              ? CustomSettingUtil.getWebServiceParams().Account_Field_API_Name__c  
                              :'Id';
        //build dynamic query.
        String query = ProcessQueryUtil.getSkinnyAccountFieldsQuery();
        query = query + 'Where '+ accountField + ' =: accountId';
        
        try{
            //get account.
            List<Account> acc = Database.Query(query);
                           
            if(!acc.isEmpty()) { 
                //If Current Opportunity is not null, mark sizing complete to true.
                if(acc[0].Current_Opportunity__c != null) {
                    acc[0].Current_Opportunity__r.Sizing_Complete__c = true;            
                    update acc[0].Current_Opportunity__r;      
                }else{  
                    result = System.Label.Current_Opportunity_Not_Found;
                }
            }else{
                result  = System.Label.Account_ID_not_found;
            }
            
            //for Unexpected Exception Testing for Test Class.
            if(TestClassSetup.throwTestException){
                throw new ServiceException('Test Exception');
            }
        }catch(Exception e){
            throw e;
        }
        return result;
    }//end closeFitSession
    
}//end class.