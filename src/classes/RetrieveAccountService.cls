/**
* This rest service is used to retrive account details
*/
@RestResource(urlMapping='/Accounts/RetrieveAccount')
global with sharing class RetrieveAccountService{
 
    /**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static AccountWrapper retrieveAccount() {
        AccountWrapper response;
        RestRequest request = RestContext.request;
        String accountId = request.params.get(ServiceUtils.ACCOUNT_ID_PARAMETER );
        
        Map<Id,Attachment__c[]> mapNoteAttachments = new Map<Id,Attachment__c[]>();
        Map<Id, Quote[]> mapOpportunityQuotes = new Map<Id, Quote[]>();
        
        /**
        * If accountId is null then return error message
        */
        if(accountId == null || accountId == ''){
            response = new AccountWrapper(Label.AccountId_Required_Msg);
        }    
        else{
            /**
            * Fetch account details
            */
            List<Account> accountList = [Select Id, Name, 
                                                Type, 
                                                Account_Alias__c, 
                                                Phone, OwnerId, 
                                                ShippingStreet, 
                                                ShippingCity, 
                                                ShippingState, 
                                                ShippingCountry, 
                                                ShippingPostalCode, 
                                                Account_Rank__c, 
                                                Website, 
                                                Account_Classification__c, 
                                                D_B_Phone__c, 
                                                Number_of_Wearers__c, 
                                                Top_25__c, 
                                                X2_Digit_Industry__c, 
                                                Sweet_Spot__c, 
                                                Lead_Source__c, 
                                                Account_Part_of_APEX__c, 
                                                Direct_Mail_Opt_Out__c, 
                                                Store__c, 
                                                Large_Account_Identifier__c, 
                                                Attachment_Indicator__c, 
                                                Status__c, 
                                                GK_Employees_Here__c, 
                                                Estimated_Cash_Value__c,
                                                Agreement_Name__c, 
                                                Agreement_Classification__c,
                                                Agreement_Number__c, 
                                                Program_Type_1__c, 
                                                Competitor_1__c, 
                                                Other_Incumbent__c, 
                                                CED_1__c, 
                                                Program_Type_2__c, 
                                                Competitor_2__c, 
                                                CED_2__c,
                                                // newly added fields
                                                LastActivityDate, 
                                                D_B_Employees_Total__c, 
                                                Mega_Segment__c, 
                                                D_B_Location_Type__c, 
                                                Number_of_Child_Locations__c,
                                                Date_Quit__c, 
                                                Account_Quit_Reason__c, 
                                                Mobile_1__c, 
                                                Mobile_2__c, 
                                                Mobile_3__c, 
                                                Sales_Stage__c, 
                                                Incumbent_DP__c,
                                                Credit_Check_Complete__c, 
                                                Soil_Evaluation_Complete__c, 
                                                Emblem_Complete__c, 
                                                Service_Agreement_Complete__c,
                                                Fit_Session_Complete__c,
                                                Language__c,
                                                Product_Type__c, 
                                                Agreement_Detail__c,
                                                //(Select StageName from Opportunities Order by CreatedDate desc limit 1),
                                                 
                                                 // Contacts
                                                 (SELECT Id, Account.Name, Name, Title, Phone, Phone_Extension__c, Email, 
                                                  Primary_Contact__c, Role__c, MobilePhone, Act_On_Lead_Score__c, Area_of_Interest__c, HasOptedOutOfEmail
                                                  FROM Contacts),
                                                  
                                                  // Notes
                                                  (SELECT Id, LastModifiedDate, Name, Text__c FROM Notes__r),
                                                  
                                                  // Activities
                                                  // Tasks
                                                  (SELECT Id, WhatId, Subject, StartActivityDate__c, ActivityDate, Status, Description, Priority, OwnerId FROM Tasks),
                                                  
                                                  // Events 
                                                  (SELECT Id, WhatId, Subject, WhoId, StartDateTime, EndDateTime, Event_Status__c, Event_Comments__c, Description, Location, ShowAs, IsAllDayEvent, OwnerId FROM Events),
                                                  
                                                  // Opportunities
                                                  (Select Id, AccountId, Name, Description, StageName, Amount, Probability, CloseDate, Type, 
                                                  Primary_Customer_Promise__c, Close_Reason__c, Who_Won__c, Who_Won_Other__c,
                                                  Expected_Install_Date__c, OwnerId, Competitors__c From Opportunities)
                                         From Account 
                                         where id =: accountId];
            if(accountList.size() == 0) {
                response = new AccountWrapper(Label.Account_Not_Found_Msg);
            }                             
            else {
                //Retrieve guided Elements.
                List<Guided_Enablement__c> enablementRecs = createEnablementRecords(accountList[0]);
                List<Guided_Enablement__c> enablementKnowList = new List<Guided_Enablement__c>();
                List<Guided_Enablement__c> enablementSayList = new List<Guided_Enablement__c>();
                List<Guided_Enablement__c> enablementShowList = new List<Guided_Enablement__c>();
                
                //Process records to divide in 3 lists with limit 3.
                for(Guided_Enablement__c rec : enablementRecs) {
                    if(rec.Guided_Output__c.equals(ApplicationConstants.GUIDED_OUTPUT_KNOW)) {
                        if(enablementKnowList.size() == 3){
                            continue;
                        }else{
                            enablementKnowList.add(rec);
                        }
                    }else if(rec.Guided_Output__c.equals(ApplicationConstants.GUIDED_OUTPUT_SAY)) {
                        if(enablementSayList.size() == 3){
                            continue;
                        }else{
                            enablementSayList.add(rec);
                        }
                    }else if(rec.Guided_Output__c.equals(ApplicationConstants.GUIDED_OUTPUT_SHOW)) {
                        if(enablementShowList.size() == 3){
                            continue;
                        }else{
                            enablementShowList.add(rec);
                        }
                    }
                }
                
                // Retrieve related Acctachments and Qoutes
                for(Account account : accountList) {
                    for(Note__c note : account.Notes__r) {
                        mapNoteAttachments.put(note.Id, new Attachment__c[] {});
                    }
                    
                    for(Opportunity opportunity : account.Opportunities) {
                        mapOpportunityQuotes.put(opportunity.Id, new Quote[] {});
                    }
                }
                
                for(Attachment__c attachment : [
                    SELECT Id, Note__c, Content__c FROM Attachment__c WHERE Note__c IN : mapNoteAttachments.keySet()
                ]) {
                    mapNoteAttachments.get(attachment.Note__c).add(attachment);
                }
                
                for(Quote quote : [
                    SELECT Id, AccountId, OpportunityId, Apttus_Proposal_Proposal_Name__c, CreatedDate, 
                    Apttus_Proposal_Amount__c, Apttus_Proposal_Valid_Until_Date__c, of_Wearers__c, 
                    Apttus_Proposal_Description__c FROM Quote WHERE OpportunityId IN : mapOpportunityQuotes.keySet()
                ]) {
                    mapOpportunityQuotes.get(quote.OpportunityId).add(quote);
                }
                response = new AccountWrapper(accountList[0], mapNoteAttachments, mapOpportunityQuotes,
                                              enablementKnowList,enablementSayList,enablementShowList);
            }
        }
        return response;
    }
    
    /*
    * This method forms list of Guided enablement records as per conditions.
    */
    public static List<Guided_Enablement__c> createEnablementRecords(Account accToCompare) {
        Map<String,Enablement_Query__c> listOfWhereConditions = Enablement_Query__c.getAll();
        String query = 'Select Id,Name,'+
                                  'SFDC_File_URL__c,'+
                                  'External_File_URL__c,'+
                                  'Snippet_Content__c,'+
                                  'Language__c,'+
                                  'Guided_Output__c'+
                           ' From Guided_Enablement__c Where ';
                                   
        if(listOfWhereConditions.isEmpty()) {
            //Default implementation as descripted in requirements.
            query = (accToCompare.Competitor_1__c != null) ? 
                   (query + 'Competitors__c = ' + '\''+ accToCompare.Competitor_1__c + '\'' + ' And ') :
                   (query + 'Competitors__c = ' + accToCompare.Competitor_1__c + ' And ');

            query = (accToCompare.Product_Type__c != null) ? 
                   (query + 'Product_Type__c = ' + '\''+ accToCompare.Product_Type__c + '\'' + ' And ') :
                   (query + 'Product_Type__c = ' + accToCompare.Product_Type__c + ' And ');

            query = (accToCompare.X2_Digit_Industry__c != null) ? 
                   (query + 'X2_Digit_Industry__c = ' + '\''+ accToCompare.X2_Digit_Industry__c + '\'' + ' And ') :
                   (query + 'X2_Digit_Industry__c = ' + accToCompare.X2_Digit_Industry__c + ' And ');
            
            query = (accToCompare.ShippingCountry != null) ? 
                   (query + 'Country__c  = ' + '\''+ accToCompare.ShippingCountry + '\'' + ' And ') :
                   (query + 'Country__c = ' + accToCompare.ShippingCountry + ' And ');
                   
            query = (accToCompare.Program_Type_1__c != null) ? 
                   (query + 'Program_Type__c = ' + '\''+ accToCompare.Program_Type_1__c + '\'' + ' And ') :
                   (query + 'Program_Type__c = ' + accToCompare.Program_Type_1__c + ' And ');
            
            query = (accToCompare.Agreement_Detail__c != null) ? 
                   (query + 'Agreement_Detail__c = ' + '\''+ accToCompare.Agreement_Detail__c + '\'' + ' And ') :
                   (query + 'Agreement_Detail__c = ' + accToCompare.Agreement_Detail__c + ' And ');
            
            query = (accToCompare.Mega_Segment__c != null) ? 
                   (query + 'Mega_Segment__c = ' + '\''+ accToCompare.Mega_Segment__c + '\'' + ' And ') :
                   (query + 'Mega_Segment__c = ' + accToCompare.Mega_Segment__c + ' And ');
            
            query = (accToCompare.Sales_Stage__c != null) ? 
                   (query + 'Sales_Stage__c = ' + '\''+ accToCompare.Sales_Stage__c + '\'' + ' And ') :
                   (query + 'Sales_Stage__c = ' + accToCompare.Sales_Stage__c + ' And ');
            
            query = (accToCompare.Language__c != null) ? 
                   (query + 'Language__c = ' + '\''+ accToCompare.Language__c + '\'' + ' And ') :
                   (query + 'Language__c = ' + accToCompare.Language__c + ' And ');
        }else {
            /*
            * This is very dynamic implementation where Where clause is formed using Custom setting values.
            * This gives amazing flexibility to match any field on Account with any field on Guided Enablement Object.
            * This is kind of extra feature provided for solution.
            * If no custom settings are defined. Default implementation will be executed.
            */
            
            try{
                for(String key : listOfWhereConditions.keyset()) {
                    Object fieldValue = accToCompare.get(listOfWhereConditions.get(key).Account_Field_API_Name__c);

                    query = (fieldValue != null ) ? (query + key + ' = '+ '\''+fieldValue+'\'') : (query + key + ' = ' + fieldValue);
                    query = query + ' And ';
                }
            }catch(Exception e){
                
            }
        } 
        
        //Check NO Blanks for Language.
        query = query + ' Language__c != NULL AND';
        
        //Ignore all records where Agreement != null.
        query = query + ' Agreement_Detail__c = NULL AND';      
        
        //Check NO BLANKS for guided output.
        query = query + ' Guided_Output__c != NULL';
        
        //Order Query by Priority in DESC Order
        query = query + ' Order By Guided_Output__c DESC';
        
        System.debug(LoggingLevel.INFO,' Built Query '+query);
        
        List<Guided_Enablement__c> retVal = Database.query(query);
        
        System.debug(LoggingLevel.INFO,' Resultset '+retVal);
        
        return retVal;
    }
    
    /**
    * This wrapper stores account data which is send as response
    */           
    global class AccountWrapper{
        public String id;
        public String name;
        public String type;
        public String alias;
        public String phone;
        public String ownerId;
        public String shippingAddress;
        public String rank;
        public String website;
        public String classification;
        public String dbPhone;
        public Integer numberOfWearers;
        public String top25;
        public String twoDigitIndustry;
        public String sweetSpot;
        public String leadSource;
        public String activeCampaign;
        public String directMailOptOut;
        public String storeNumber;
        public String largeAccountIdentifier;
        public String attachmentIndicator;
        public String opportunityStage;
        public String status;
        public Integer gkEmployeesHere;
        public String estimatedCashValue;
        public String agreementName;
        public String agreementClassification;
        public String agreementNumber;
        public String programType1;
        public String incumbent1;
        public String otherEncumbent;
        public Date ced1Date;
        public String programType2;
        public String incumbent2;
        public Date ced2Date;
        
        public Date lastActivityDate;
        public Integer dBEmployeesTotal;
        public String megaSegment;
        public String dBLocationType;
        public Integer numberOfChildLocations;
        public Date dateQuit;
        public String accountQuitReason;
        public String mobile1;
        public String mobile2;
        public String mobile3;
        public String salesStage;
        public String incumbentDP;
        public Boolean creditCheckComplete;
        public Boolean soilEvaluationComplete;
        public Boolean emblemComplete;
        public Boolean serviceAgreementComplete;
        public Boolean fitSessionComplete;

        public List<EnablementWrapper> enablementKnowList;
        public List<EnablementWrapper> enablementSayList;        
        public List<EnablementWrapper> enablementShowList;
        
        public ContactWrapper[] contacts;
        public NoteWrapper[] notes;
        public ActivityWrapper[] activities;
        public OpportunityWrapper[] opportunities;
        
        public Boolean isSuccess;
        public String message;
        
        /**
        * Constructor used for error message
        */
        public AccountWrapper(String message){
            this.message = message;
            isSuccess = false;
        }
        
        public AccountWrapper(Account account, Map<Id,Attachment__c[]> mapNoteAttachments, Map<Id, Quote[]> mapOpportunityQuotes,
                              List<Guided_Enablement__c> knowList, 
                              List<Guided_Enablement__c> sayList,
                              List<Guided_Enablement__c> showList) {
            //Call to earlier Constructor. Backward compatibility.
            this(account, mapNoteAttachments, mapOpportunityQuotes);
            
            //Create Enablement Record List to return in JSON.
            enablementKnowList = new List<EnablementWrapper>();
            enablementSayList = new List<EnablementWrapper>();
            enablementShowList = new List<EnablementWrapper>();
            
            for(Guided_Enablement__c rec : knowList) {
                this.enablementKnowList.add(new EnablementWrapper(rec.Id,
                                                             rec.Name,
                                                             rec.SFDC_File_URL__c,
                                                             rec.External_File_URL__c,
                                                             rec.Snippet_Content__c,
                                                             rec.Language__c));
            }
            
            for(Guided_Enablement__c rec : sayList) {
                this.enablementSayList.add(new EnablementWrapper(rec.Id,
                                                             rec.Name,
                                                             rec.SFDC_File_URL__c,
                                                             rec.External_File_URL__c,
                                                             rec.Snippet_Content__c,
                                                             rec.Language__c));
            }
            
            for(Guided_Enablement__c rec : showList) {
                this.enablementShowList.add(new EnablementWrapper(rec.Id,
                                                             rec.Name,
                                                             rec.SFDC_File_URL__c,
                                                             rec.External_File_URL__c,
                                                             rec.Snippet_Content__c,
                                                             rec.Language__c));
            }
        }
        /**
        * Constructor used to store account details
        */
        public AccountWrapper(Account account, Map<Id,Attachment__c[]> mapNoteAttachments, Map<Id, Quote[]> mapOpportunityQuotes){
            isSuccess = true;
            message = '';
            id = account.Id;
            name = account.Name;
            type = ServiceUtils.getNotNullValue(account.Type);
            alias = ServiceUtils.getNotNullValue(account.Account_Alias__c);
            phone = ServiceUtils.getNotNullValue(account.Phone);
            ownerId = account.OwnerId;
            shippingAddress = getShippingAddress(account);
            rank = account.Account_Rank__c;
            website = ServiceUtils.getNotNullValue(account.Website);
            classification = ServiceUtils.getNotNullValue(account.Account_Classification__c);
            dbPhone = ServiceUtils.getNotNullValue(account.D_B_Phone__c);
            numberOfWearers = ServiceUtils.getIntegerValue(account.Number_of_Wearers__c);
            top25 = ServiceUtils.getStringValue(account.Top_25__c);
            twoDigitIndustry = ServiceUtils.getNotNullValue(account.X2_Digit_Industry__c);
            sweetSpot = ServiceUtils.getNotNullValue(account.Sweet_Spot__c);
            leadSource = ServiceUtils.getNotNullValue(account.Lead_Source__c);
            activeCampaign = ServiceUtils.getStringValue(account.Account_Part_of_APEX__c);
            directMailOptOut = ServiceUtils.getStringValue(account.Direct_Mail_Opt_Out__c);
            storeNumber = ServiceUtils.getNotNullValue(account.Store__c);
            largeAccountIdentifier = ServiceUtils.getNotNullValue(account.Large_Account_Identifier__c);
            attachmentIndicator = ServiceUtils.getNotNullValue(String.valueof(account.Attachment_Indicator__c));
            
            /* 
            opportunityStage = '';
            if(account.Opportunities.size() > 0 && account.Opportunities[0].StageName != null){
                opportunityStage = account.Opportunities[0].StageName;
            }
            */
            
            status = ServiceUtils.getNotNullValue(account.Status__c);
            gkEmployeesHere = ServiceUtils.getIntegerValue(account.GK_Employees_Here__c);
            estimatedCashValue = ServiceUtils.getNotNullValue(account.Estimated_Cash_Value__c);
            agreementName = ServiceUtils.getNotNullValue(account.Agreement_Name__c); 
            agreementClassification = ServiceUtils.getNotNullValue(account.Agreement_Classification__c);
            agreementNumber = ServiceUtils.getNotNullValue(account.Agreement_Number__c);
            programType1 = ServiceUtils.getNotNullValue(account.Program_Type_1__c);
            incumbent1 = ServiceUtils.getNotNullValue(account.Competitor_1__c);
            otherEncumbent = ServiceUtils.getNotNullValue(account.Other_Incumbent__c);
            ced1Date = account.CED_1__c;
            programType2 = ServiceUtils.getNotNullValue(account.Program_Type_2__c);
            incumbent2 = ServiceUtils.getNotNullValue(account.Competitor_2__c);
            ced2Date = account.CED_2__c;
            
            lastActivityDate = account.LastActivityDate;
            dBEmployeesTotal = ServiceUtils.getIntegerValue(account.D_B_Employees_Total__c);
            megaSegment = ServiceUtils.getNotNullValue(account.Mega_Segment__c);
            dBLocationType = ServiceUtils.getNotNullValue(account.D_B_Location_Type__c);
            numberOfChildLocations = ServiceUtils.getIntegerValue(account.Number_of_Child_Locations__c);
            dateQuit = account.Date_Quit__c;
            accountQuitReason = account.Account_Quit_Reason__c;
            mobile1 = account.Mobile_1__c;
            mobile2 = account.Mobile_2__c;
            mobile3 = account.Mobile_3__c;
            salesStage = ServiceUtils.getNotNullValue(account.Sales_Stage__c);
            incumbentDP = ServiceUtils.getNotNullValue(account.Incumbent_DP__c);
            creditCheckComplete = account.Credit_Check_Complete__c;
            soilEvaluationComplete = account.Soil_Evaluation_Complete__c;
            emblemComplete = account.Emblem_Complete__c;
            serviceAgreementComplete = account.Service_Agreement_Complete__c;
            fitSessionComplete = account.Fit_Session_Complete__c;
            
            contacts = new ContactWrapper[] {};
            for(Contact contact : account.Contacts) {
               contacts.add(new ContactWrapper(contact));
            }
            
            notes = new NoteWrapper[] {};
            for(Note__c note : account.Notes__r) {
               notes.add(new NoteWrapper(note, mapNoteAttachments.get(note.Id)));
            }
            
            activities = new ActivityWrapper[] {};
            for(Event event : account.Events) {
               activities.add(new ActivityWrapper('Event', event, null));
            }
            
            for(Task task : account.Tasks) {
               activities.add(new ActivityWrapper('Task', null, task));
            }
            
            opportunities = new OpportunityWrapper[] {};
            for(Opportunity opportunity : account.Opportunities) {
               opportunities.add(new OpportunityWrapper(opportunity, mapopportunityQuotes.get(opportunity.Id)));
            }
        }
        
        /**
        * This method return the shipping address of account
        * @account: Account instance from where shipping address is retrieved
        * @return: Concatenation of shipping address fields
        */ 
        String getShippingAddress(Account account){
            String shippingAddress = '';
            shippingAddress += account.ShippingStreet != null ? account.ShippingStreet + ', ' : '';
            shippingAddress += account.ShippingCity != null ? account.ShippingCity + ', ' : '';
            shippingAddress += account.ShippingState != null ? account.ShippingState + ', ' : '';
            shippingAddress += account.ShippingCountry != null ? account.ShippingCountry + ', ' : '';
            shippingAddress += account.ShippingPostalCode != null ? account.ShippingPostalCode + ', ' : '';
            shippingAddress.removeEnd(', ');
            return shippingAddress;
        }
    }
    
    global class EnablementWrapper {
        public String id;
        public String title;
        public String sfContentLink;
        public String externalContentLink;
        public String description;
        public String language;
        
        public EnablementWrapper(String id, String title, String sfContentLink,
                                 String externalContentLink, String description, String language) {
            this.id = id;
            this.title = title;
            this.sfContentLink = sfContentLink;
            this.externalContentLink = externalContentLink;
            this.description = description;
            this.language = language;
        }
    }
    
    global class ContactWrapper {
        public String id;
        public String accountName;
        public String name;
        public String title;
        public String phone;
        public String phoneExtension;
        public String email;
        public Boolean primaryContact;
        public String role;
        public String mobilePhone;
        public String actOnLeadScore;
        public String areaOfInterest;
        public Boolean hasOptedOutOfEmail;
        
        public ContactWrapper(Contact contact) {
            id = contact.Id;
            accountName = contact.Account.Name;
            name = contact.Name;
            title = contact.Title;
            phone = contact.Phone;
            phoneExtension = String.valueOf(contact.Phone_Extension__c);
            email = contact.Email;
            primaryContact = contact.Primary_Contact__c;
            role = contact.Role__c;
            mobilePhone = contact.MobilePhone;
            actOnLeadScore = String.valueOf(contact.Act_On_Lead_Score__c);
            areaOfInterest = contact.Area_of_Interest__c;
            hasOptedOutOfEmail = contact.HasOptedOutOfEmail;
        }
    }
    
    global class NoteWrapper {
        public String id;
        public DateTime lastModifiedDate;
        public String name;
        public String text;
        public AttachmentWrapper[] attachments;
        
        public NoteWrapper(Note__c note, Attachment__c[] lstAttachment) {
            id = note.Id;
            lastModifiedDate = note.LastModifiedDate;
            name = note.Name;
            text = note.Text__c;
            
            attachments = new AttachmentWrapper[] {};
            for(Attachment__c attachment : lstAttachment) {
                attachments.add(new AttachmentWrapper(attachment));
            }
        }
    }
    
    global class AttachmentWrapper {
        public String id;
        public String noteId;
        public String contentId;
        
        public AttachmentWrapper(Attachment__c attachment) {
            id = attachment.Id;
            noteId = attachment.Note__c;
            contentId = attachment.Content__c;
        }
    }
    
    global class ActivityWrapper {
        public String type;
        public String id;
        public String what;
        public String subject;
        public String who;
        public DateTime startDateTime;
        public DateTime endDateTime;
        public String status;
        public String eventComments;
        public String description;
        public String location;
        public String priority;
        public String showAs;
        public Boolean isAllDayEvent;
        public String owner;
        public Date startActivityDate;
        public Date activityDate;
        
        public ActivityWrapper(String type, Event event, Task task) {
            this.type = type;
            if(event != null) {
                id = event.Id;
                what = event.WhatId;
                subject = event.Subject;
                who = event.WhoId;
                startDateTime = event.StartDateTime;
                endDateTime = event.EndDateTime;
                status = event.Event_Status__c;
                eventComments = event.Event_Comments__c;
                description = event.Description;
                location = event.Location;
                showAs = event.ShowAs;
                isAllDayEvent = event.IsAllDayEvent;
                owner = event.OwnerId;
            }
            if(task != null) {
                id = task.Id;
                what = task.WhatId;
                subject = task.Subject;
                status = task.Status;
                description = task.Description;
                priority = task.Priority;
                owner = task.OwnerId;
                startActivityDate = task.StartActivityDate__c;
                activityDate = task.ActivityDate;
            }
        }
    }
    
    global class OpportunityWrapper {
        public String id;
        public String name;
        public String account;
        public Decimal amount;
        public String stageName;
        public Date closeDate;
        public Decimal probability;
        public String type;
        public String primaryCustomerPromise;
        public String closeReason;
        public String whoWon;
        public String whoWonOther;
        public String competitors;
        public Date expectedInstallDate;
        public String owner;
        public QuoteWrapper[] quotes;
        
        OpportunityWrapper(Opportunity opportunity, Quote[] lstQuote) {
            id = opportunity.Id;
            name = opportunity.Name;
            account = opportunity.AccountId;
            amount = opportunity.Amount;
            stageName = opportunity.StageName;
            closeDate = opportunity.CloseDate;
            probability = opportunity.Probability;
            type = opportunity.Type;
            primaryCustomerPromise = opportunity.Primary_Customer_Promise__c;
            closeReason = opportunity.Close_Reason__c;
            whoWon = opportunity.Who_Won__c;
            whoWonOther = opportunity.Who_Won_Other__c;
            competitors = opportunity.Competitors__c;
            expectedInstallDate = opportunity.Expected_Install_Date__c;
            owner = opportunity.OwnerId;
            quotes = new QuoteWrapper[] {};
            for(Quote quote : lstQuote) {
                quotes.add(new QuoteWrapper(quote));
            }
        }
    }
    
    global class QuoteWrapper {
        public String account;
        public String opportunityId;
        public String id;
        public String apttusProposalProposalName;
        public DateTime createdDate;
        public Decimal apttusProposalAmount;
        public Date apttusProposalValidUntilDate;
        public Integer ofWearers;
        public String apttusProposalDescription;
        
        public QuoteWrapper(Quote quote) {
            account = quote.AccountId;
            opportunityId = quote.OpportunityId;
            Id = quote.Id;
            apttusProposalProposalName = quote.Apttus_Proposal_Proposal_Name__c;
            createdDate = quote.CreatedDate;
            apttusProposalAmount = quote.Apttus_Proposal_Amount__c;
            apttusProposalValidUntilDate = quote.Apttus_Proposal_Valid_Until_Date__c;
            ofWearers = ServiceUtils.getIntegerValue(quote.of_Wearers__c);
            apttusProposalDescription = quote.Apttus_Proposal_Description__c;
        }
    }
}