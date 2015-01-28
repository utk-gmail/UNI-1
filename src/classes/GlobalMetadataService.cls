/**
* This rest service is used to retrive options for picklists
*/
@RestResource(urlMapping='/Global/Metadata')
global class GlobalMetadataService {
    /**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static void retriveMetadata() {
        // Form Map of Objects and related Fields
        Map<String, Map<String, Schema.SObjectField>> mapObjectField =
            new Map<String, Map<String, Schema.SObjectField>>{
                SObjectType.Account.Name => SObjectType.Account.fields.getMap(),
                SObjectType.Contact.Name => SObjectType.Contact.fields.getMap(),
                SObjectType.Opportunity.Name => SObjectType.Opportunity.fields.getMap(),
                SObjectType.Lead.Name => SObjectType.Lead.fields.getMap()
            };
        // Form Map of Objects and related Picklist Fields
        Map<String, Set<String>> mapObjectFieldSet =
            new Map<String, Set<String>>{
                SObjectType.Account.Name => new Set<String> {
                    '' + Account.Status__c, 
                    '' + Account.Sales_Stage__c, 
                    '' + Account.Estimated_Cash_Value__c, 
                    '' + Account.Program_Type_1__c, 
                    '' + Account.Competitor_1__c, 
                    '' + Account.Competitor_2__c, 
                    '' + Account.Incumbent_DP__c, 
                    '' + Account.Mega_Segment__c
                },
                SObjectType.Contact.Name => new Set<String> {
                    '' + Contact.Role__c 
                },
                SObjectType.Opportunity.Name => new Set<String> {
                    '' + Opportunity.Type, 
                    '' + Opportunity.Primary_Customer_Promise__c, 
                    '' + Opportunity.Close_Reason__c, 
                    '' + Opportunity.Who_Won__c, 
                    '' + Opportunity.Competitors__c
                },
                SObjectType.Lead.Name => new Set<String> {
                    '' + Lead.Salutation, 
                    '' + Lead.Status, 
                    '' + Lead.Industry
                }
            };
        
        // Prepare Map of Picklist field and related Options
        Map<String, String[]> mapPicklistOptions = new Map<String, String[]>();
        
        for(String objectName : mapObjectField.keySet()) {
            for(String fieldName : mapObjectFieldSet.get(objectName)) {
                Schema.DescribeFieldResult describeFieldResult = mapObjectField.get(objectName).get(fieldName).getDescribe();
                if('PICKLIST'.equalsIgnoreCase(String.valueOf(describeFieldResult.getType()))) {
                    String field = objectName + '.' + describeFieldResult.getName();
                    for(Schema.PicklistEntry picklistEntry : describeFieldResult.getPicklistValues()) {
                        if(mapPicklistOptions.containsKey(field)) {
                            mapPicklistOptions.get(field).add(picklistEntry.getLabel());
                        } else {
                            mapPicklistOptions.put(field, new String [] {picklistEntry.getLabel()});
                        }
                    }
                }
            }
        }
        
        // Prepare the list of Fields for sorting
        List<String> lstFields = new List<String> (mapPicklistOptions.keySet());
        lstFields.sort();
        
        // Create a JSONGenerator object
        JSONGenerator gen = JSON.createGenerator(true);
        // Write data to the JSON string.
        gen.writeStartObject();
        
        for(String fieldName : lstFields) {
            gen.writeObjectField(fieldName, mapPicklistOptions.get(fieldName));
        }
        gen.writeEndObject();
        // Add the generated JSON to response
        if(Test.isRunningTest()) {
            RestContext.response = new RestResponse();
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(gen.getAsString());
    }
}