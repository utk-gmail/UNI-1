/*
* This rest service is used for global search
*/

@RestResource(urlMapping='/Global/Search')
global class GlobalSearchService {

    // Variables
    public static final String SEARCHTERM_PARAMETER = 'searchTerm';
    public static final String CATEGORY_PARAMETER = 'category';
    public static final String SUBCATEGORY_PARAMETER = 'subcategory';
    public static final Integer RECORD_LIMIT = 5;
    
    public static final Map<String, List<String>> mapAllObjects = new Map<String, List<String>> {
        'Account' => new List<String> {
        '' + Account.Name,
        '' + Account.Phone,
        '' + Account.Account_Alias__c,
        '' + Account.Status__c,
        '' + Account.Estimated_Cash_Value__c,
        '' + Account.Program_Type_1__c,
        '' + Account.Agreement_Name__c,
        '' + Account.Mega_Segment__c,
        '' + Account.D_B_Location_Type__c,
        '' + Account.Account_Quit_Reason__c,
        '' + Account.Mobile_1__c,
        '' + Account.Mobile_2__c,
        '' + Account.Mobile_3__c,
        '' + Account.ShippingStreet,
        '' + Account.ShippingCity,
        '' + Account.ShippingState,
        '' + Account.ShippingCountry,
        '' + Account.ShippingPostalCode,
        '' + Account.Sales_Stage__c,
        '' + Account.LastModifiedDate
        }, 
        'Contact' => new List<String> {
            '' + Contact.Name,
            '' + Contact.Title,
            '' + Contact.Phone,
            '' + Contact.Phone_Extension__c,
            '' + Contact.Email,
            '' + Contact.Role__c,
            '' + Contact.MobilePhone,
            '' + Contact.LastModifiedDate,
            'Account.Name'
        },
        'Opportunity' => new List<String> {
            '' + Opportunity.Name,
            '' + Opportunity.StageName,
            '' + Opportunity.Type,
            '' + Opportunity.Primary_Customer_Promise__c,
            '' + Opportunity.Close_Reason__c,
            '' + Opportunity.Who_Won__c,
            '' + Opportunity.Who_Won_Other__c,
            '' + Opportunity.Competitors__c,
            '' + Opportunity.OwnerId,
            '' + Opportunity.LastModifiedDate,
            'Account.Name'
        },
        'Lead' => new List<String> {
            '' + Lead.Company,
            '' + Lead.Name,
            '' + Lead.Email,
            '' + Lead.Phone,
            '' + Lead.Title,
            '' + Lead.Status,
            '' + Lead.Description,
            '' + Lead.Industry,
            '' + Lead.Street,
            '' + Lead.City,
            '' + Lead.State,
            '' + Lead.Country,
            '' + Lead.PostalCode,
            '' + Lead.Comments__c,
            '' + Lead.OwnerId,
            '' + Lead.Reason_for_Contacting__c,
            '' + Lead.LeadSource,
            '' + Lead.DomainSource__c,
            '' + Lead.PageSource__c,
            '' + Lead.LastModifiedDate
        },
        'Quote' => new List<String> {
            '' + Quote.Name,
            '' + Quote.Apttus_Proposal_Proposal_Name__c,
            '' + Quote.Apttus_Proposal_Amount__c,
            '' + Quote.Apttus_Proposal_Description__c,
            '' + Quote.LastModifiedDate,
            'Account.Name'
        },
        'ContentVersion' => new List<String> {
            '' + ContentVersion.Title,
            '' + ContentVersion.TagCsv,
            '' + ContentVersion.IsLatest,
            '' + ContentVersion.ContentUrl,
            '' + ContentVersion.ContentSize,
            '' + ContentVersion.FileType,
            '' + ContentVersion.ContentDocumentId,
            '' + ContentVersion.Id,
            '' + ContentVersion.ContentModifiedDate
        }
    };
    
    /**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static ResponseWrapper globalSearch() {
        // Create Response
        ResponseWrapper response = new ResponseWrapper();
        response.accounts = new AccountWrapper[] {};
        response.contacts = new ContactWrapper[] {};
        response.opportunities = new OpportunityWrapper[] {};
        response.leads = new LeadWrapper[] {};
        response.quotes = new QuoteWrapper[] {};
        response.contents = new ContentWrapper[] {};
        
        // Form the Object list for performing search
        String[] objectList = new String[] {
            'Account',
            'Contact',
            'Opportunity',
            'Lead',
            'Quote',
            'ContentVersion'
        };
        
        // Get the request params
        RestRequest request = RestContext.request;
        String searchTerm = request.params.get(SEARCHTERM_PARAMETER);
        String category = request.params.get(CATEGORY_PARAMETER);
        String subCategory = request.params.get(SUBCATEGORY_PARAMETER);
        
        if(String.isEmpty(searchTerm) && String.isEmpty(category) && String.isEmpty(subCategory)) {
            // return all recently modified records 
            return getRecentlyModifiedObjectsOfEachType(response);
        } else if (String.isNotEmpty(searchTerm) && String.isEmpty(category) && String.isEmpty(subCategory)) {
            // perform search on all objects
            String searchquery = 'FIND\''+searchTerm+'*\'IN ALL FIELDS RETURNING ';

            List<String> lstReturningClause = new List<String>();
            for(String objectApiName: objectList) {
                lstReturningClause.add(objectApiName + '(' + String.join(mapAllObjects.get(objectApiName), ', ') + ')');
            } 
            searchquery += String.join(lstReturningClause, ', ');
            
            List<List<SObject>> searchList = search.query(searchQuery);
            for(Account account : (Account[])searchList[0]) {
                response.accounts.add(new AccountWrapper(account));
            }

            for(Contact contact : (Contact[])searchList[1]) {
                response.contacts.add(new ContactWrapper(contact));
            }

            for(Opportunity opportunity : (Opportunity[])searchList[2]) {
                response.opportunities.add(new opportunityWrapper(opportunity));
            }

            for(Lead lead : (Lead[])searchList[3]) {
                response.leads.add(new LeadWrapper(lead));
            }

            for(Quote quote : (Quote[])searchList[4]) {
                response.quotes.add(new QuoteWrapper(quote));
            }
            
            for(ContentVersion contentVersion : (ContentVersion[])searchList[5]) {
                if(String.isNotEmpty(contentVersion.TagCsv) && contentVersion.IsLatest) {
                    for(String tag : contentVersion.TagCsv.split(',')) {
                        response.contents.add(
                            new ContentWrapper(
                                contentVersion.Title, contentVersion.ContentDocumentId, 'Content', tag,
                                tag, false, contentVersion.ContentSize, contentVersion.ContentUrl, contentVersion.FileType, contentVersion.ContentModifiedDate
                            )
                        );
                    }
                }
            }
        } else if (String.isNotEmpty(searchTerm) && String.isNotEmpty(category) && String.isEmpty(subCategory)) {
            // perform search specified object
            String searchquery = 'FIND\''+searchTerm+'*\'IN ALL FIELDS RETURNING ';
            
            category = 'Content'.equalsIgnoreCase(category) ? 'ContentVersion' : category;
            
            if(mapAllObjects.containsKey(category)) {
                searchquery += category + '(' + String.join(mapAllObjects.get(category), ', ') + ')';
                List<List<SObject>> searchList = search.query(searchQuery);
            
                if('Account'.equals(category)) {
                    for(Account account : (Account[])searchList[0]) {
                        response.accounts.add(new AccountWrapper(account));
                    }
                } else if('Contact'.equals(category)){
                    for(Contact contact : (Contact[])searchList[0]) {
                        response.contacts.add(new ContactWrapper(contact));
                    }
                } else if('Opportunity'.equals(category)){
                    for(Opportunity opportunity : (Opportunity[])searchList[0]) {
                        response.opportunities.add(new opportunityWrapper(opportunity));
                    }
                } else if('Lead'.equals(category)) {
                    for(Lead lead : (Lead[])searchList[0]) {
                        response.leads.add(new LeadWrapper(lead));
                    }
                } else if('Quote'.equals(category)) {
                    for(Quote quote : (Quote[])searchList[0]) {
                        response.quotes.add(new QuoteWrapper(quote));
                    }
                } else if('ContentVersion'.equals(category)) {
                    for(ContentVersion contentVersion : (ContentVersion[])searchList[0]) {
                        if(String.isNotEmpty(contentVersion.TagCsv) && contentVersion.IsLatest) {
                            for(String tag : contentVersion.TagCsv.split(',')) {
                                response.contents.add(
                                    new ContentWrapper(
                                        contentVersion.Title, contentVersion.ContentDocumentId, 'Content', tag,
                                        tag, false, contentVersion.ContentSize, contentVersion.ContentUrl, contentVersion.FileType, contentVersion.ContentModifiedDate
                                    )
                                );
                            }
                        }
                    }
                }
            }
        } else if (String.isNotEmpty(searchTerm) && String.isNotEmpty(subCategory)) {
            // perform search on content item
            String searchquery = 'FIND\''+searchTerm+'*\'IN ALL FIELDS RETURNING ';
            
            searchquery += ' ContentVersion (' + String.join(mapAllObjects.get('ContentVersion'), ', ') + ')';
            List<List<SObject>> searchList = search.query(searchQuery);
            
            for(ContentVersion contentVersion : (ContentVersion[])searchList[0]) {
                if(String.isNotEmpty(contentVersion.TagCsv) && contentVersion.IsLatest) {
                    for(String tag : contentVersion.TagCsv.split(',')) {
                        if(subCategory.equalsIgnoreCase(tag)) {
                            response.contents.add(
                                new ContentWrapper(
                                    contentVersion.Title, contentVersion.ContentDocumentId, 'Content', subCategory,
                                    tag, false, contentVersion.ContentSize, contentVersion.ContentUrl, contentVersion.FileType, contentVersion.ContentModifiedDate
                                )
                            );
                        }
                    }
                }
            }
        } else if (String.isEmpty(searchTerm) && String.isNotEmpty(category) && String.isEmpty(subCategory)) {
            // return recently modified records of specified type
            category = 'Content'.equalsIgnoreCase(category) ? 'ContentVersion' : category;
            if('Account'.equals(category)) {
                for(Account account : getRecentlyModifiedObjectsForAccount()) {
                    response.accounts.add(new AccountWrapper(account));
                }
            } else if('Contact'.equals(category)){
                for(Contact contact : getRecentlyModifiedObjectsForContact()) {
                    response.contacts.add(new ContactWrapper(contact));
                }
            } else if('Opportunity'.equals(category)){
                for(Opportunity opportunity : getRecentlyModifiedObjectsForOpportunity()) {
                    response.opportunities.add(new opportunityWrapper(opportunity));
                }
            } else if('Lead'.equals(category)) {
                for(Lead lead : getRecentlyModifiedObjectsForLead()) {
                    response.leads.add(new LeadWrapper(lead));
                }
            } else if('Quote'.equals(category)) {
                for(Quote quote : getRecentlyModifiedObjectsForQuote()) {
                    response.quotes.add(new QuoteWrapper(quote));
                }
            } else if('ContentVersion'.equals(category)) {
                for(ContentVersion contentVersion : getRecentlyModifiedObjectsForContent()) {
                    if(String.isNotEmpty(contentVersion.TagCsv) && contentVersion.IsLatest) {
                        for(String tag : contentVersion.TagCsv.split(',')) {
                            response.contents.add(
                                new ContentWrapper(
                                    contentVersion.Title, contentVersion.ContentDocumentId, 'Content', tag,
                                    tag, false, contentVersion.ContentSize, contentVersion.ContentUrl, contentVersion.FileType, contentVersion.ContentModifiedDate
                                )
                            );
                        }
                    }
                }
            }
        } else if (String.isEmpty(searchTerm) && String.isNotEmpty(subCategory)) {
            // return recently modified contents
            for(ContentVersion contentVersion : getRecentlyModifiedObjectsForContent()) {
                if(String.isNotEmpty(contentVersion.TagCsv) && contentVersion.IsLatest) {
                    for(String tag : contentVersion.TagCsv.split(',')) {
                        if(subCategory.equalsIgnoreCase(tag)) {
                            response.contents.add(
                                new ContentWrapper(
                                    contentVersion.Title, contentVersion.ContentDocumentId, 'Content', subCategory,
                                    tag, false, contentVersion.ContentSize, contentVersion.ContentUrl, contentVersion.FileType, contentVersion.ContentModifiedDate
                                )
                            );
                        }
                    }
                }
            }
        }
        return response;
    }
    
    // Method used for getting recently modified records for all types
    public static ResponseWrapper getRecentlyModifiedObjectsOfEachType(ResponseWrapper response) {
        for(Account account : getRecentlyModifiedObjectsForAccount()) {
            response.accounts.add(new AccountWrapper(account));
        }
        for(Contact contact : getRecentlyModifiedObjectsForContact()) {
            response.contacts.add(new ContactWrapper(contact));
        }
        for(Opportunity opportunity : getRecentlyModifiedObjectsForOpportunity()) {
            response.opportunities.add(new opportunityWrapper(opportunity));
        }
        for(Lead lead : getRecentlyModifiedObjectsForLead()) {
            response.leads.add(new LeadWrapper(lead));
        }
        for(Quote quote : getRecentlyModifiedObjectsForQuote()) {
            response.quotes.add(new QuoteWrapper(quote));
        }
        for(ContentVersion contentVersion : getRecentlyModifiedObjectsForContent()) {
            if(String.isNotEmpty(contentVersion.TagCsv)) {
                for(String tag : contentVersion.TagCsv.split(',')) {
                    response.contents.add(
                        new ContentWrapper(
                            contentVersion.Title, contentVersion.ContentDocumentId, 'Content', '',
                            tag, false, contentVersion.ContentSize, contentVersion.ContentUrl, contentVersion.FileType, contentVersion.ContentModifiedDate
                        )
                    );
                }
            }
        }
        return response;
    }
    
    // Method used for getting recently modified records for Accounts
    public static Account[] getRecentlyModifiedObjectsForAccount() {
        String accountQuery = ''
            + 'SELECT '
            + String.join(mapAllObjects.get('Account'), ', ')
            + ' FROM Account '
            + ' ORDER BY ' + Account.LastModifiedDate + ' DESC'
            + ' LIMIT ' + RECORD_LIMIT;
        return (Account[])Database.query(accountQuery);
    }
    
    // Method used for getting recently modified records for Contacts
    public static Contact[] getRecentlyModifiedObjectsForContact() {
        String contactQuery = ''
            + 'SELECT '
            + String.join(mapAllObjects.get('Contact'), ', ')
            + ' FROM Contact '
            + ' ORDER BY ' + Contact.LastModifiedDate + ' DESC'
            + ' LIMIT ' + RECORD_LIMIT;
        return (Contact[])Database.query(contactQuery);
    }
    
    // Method used for getting recently modified records for Opportunities
    public static Opportunity[] getRecentlyModifiedObjectsForOpportunity() {
        String opportunityQuery = ''
            + 'SELECT '
            + String.join(mapAllObjects.get('Opportunity'), ', ')
            + ' FROM Opportunity '
            + ' ORDER BY ' + Opportunity.LastModifiedDate + ' DESC'
            + ' LIMIT ' + RECORD_LIMIT;
        return (Opportunity[])Database.query(opportunityQuery);
    }
    
    // Method used for getting recently modified records for Leads
    public static Lead[] getRecentlyModifiedObjectsForLead() {
        String leadQuery = ''
            + 'SELECT '
            + String.join(mapAllObjects.get('Lead'), ', ')
            + ' FROM Lead '
            + ' ORDER BY ' + Lead.LastModifiedDate + ' DESC'
            + ' LIMIT ' + RECORD_LIMIT;
        return (Lead[])Database.query(leadQuery);
    }
    
    // Method used for getting recently modified records for Quotes
    public static Quote[] getRecentlyModifiedObjectsForQuote() {
        String quoteQuery = ''
            + 'SELECT '
            + String.join(mapAllObjects.get('Quote'), ', ')
            + ' FROM Quote '
            + ' ORDER BY ' + Quote.LastModifiedDate + ' DESC'
            + ' LIMIT ' + RECORD_LIMIT;
        return (Quote[])Database.query(quoteQuery);
    }
    
    // Method used for getting recently modified records for Contents
    public static ContentVersion[] getRecentlyModifiedObjectsForContent() {
        String contentQuery = ''
            + 'SELECT '
            + String.join(mapAllObjects.get('ContentVersion'), ', ')
            + ' FROM ContentVersion '
            + ' WHERE ' + ContentVersion.IsLatest + ' = true'
            + ' ORDER BY ' + ContentVersion.LastModifiedDate + ' DESC'
            + ' LIMIT ' + RECORD_LIMIT;
        return (ContentVersion[])Database.query(contentQuery);
    }
    
    /**
    * This wrapper stores actual response data
    */
    global class ResponseWrapper {
        public AccountWrapper[] accounts;
        public ContactWrapper[] contacts;
        public OpportunityWrapper[] opportunities;
        public LeadWrapper[] leads;
        public QuoteWrapper[] quotes;
        public ContentWrapper[] contents;
    }
    
    global abstract class BaseWrapper {
        public String title;
        public String id;
        public String category;
        public DateTime lastModifiedDate;
    }
    
    global class AccountWrapper extends BaseWrapper {
        public Account account;
        public AccountWrapper(Account account) {
            this.title = account.Name;
            this.id = account.Id;
            this.category = 'Account';
            this.account = account;
            this.lastModifiedDate = account.lastModifiedDate;
        }
    }
    
    global class ContactWrapper extends BaseWrapper {
        public Contact contact;
        public ContactWrapper(Contact Contact) {
            this.title = contact.Name;
            this.id = contact.Id;
            this.category = 'Contact';
            this.contact = contact;
            this.lastModifiedDate = contact.lastModifiedDate;
        }
    }
    
    global class OpportunityWrapper extends BaseWrapper {
        public Opportunity opportunity;
        public OpportunityWrapper(Opportunity opportunity) {
            this.title = opportunity.Name;
            this.id = opportunity.Id;
            this.category = 'Opportunity';
            this.opportunity = opportunity;
            this.lastModifiedDate = opportunity.lastModifiedDate;
        }
    }
    
    global class LeadWrapper extends BaseWrapper {
        public Lead lead;
        public LeadWrapper(Lead lead) {
            this.title = lead.Name;
            this.id = lead.Id;
            this.category = 'Lead';
            this.lead = lead;
            this.lastModifiedDate = lead.lastModifiedDate;
        }
    }
    
    global class QuoteWrapper extends BaseWrapper {
        public Quote quote;
        public QuoteWrapper(Quote quote) {
            this.title = quote.Name;
            this.id = quote.Id;
            this.category = 'Quote';
            this.quote = quote;
            this.lastModifiedDate = quote.lastModifiedDate;
        }
    }
    
    global class ContentWrapper extends BaseWrapper {
        public String subCategory;
        public String tags;
        public Boolean canEmail;
        public Integer fileSize;
        public String url;
        public String fileType;
        public ContentWrapper(String title, String id, String category, String subCategory, String tags, Boolean canEmail, Integer fileSize, String url, String fileType, DateTime lastModifiedDate) {
            this.title = title;
            this.id = id;
            this.category = category;
            this.subCategory = subCategory;
            this.tags = tags;
            this.canEmail = canEmail;
            this.fileSize = fileSize;
            this.url = url;
            this.fileType = fileType;
            this.lastModifiedDate = lastModifiedDate;
        }
    }
}