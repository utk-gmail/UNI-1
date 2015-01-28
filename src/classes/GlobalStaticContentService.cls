/**
* This rest service is used to retrive global static content
*/
@RestResource(urlMapping='/Global/StaticContent')
global with sharing class GlobalStaticContentService {
 
    /**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static void retrieveContent() {
        // Retrieve custom setting values
        Map<String, String> mapResponse = new Map<String, String>();
        Map<String, CompassHomepageSettings__c> mapStaticLink = 
            CompassHomepageSettings__c.getAll();
        Set<String> tags = new Set<String>();
        for(String key: mapStaticLink.keySet()) {
            mapResponse.put(key, mapStaticLink.get(key).Content_Item_URL__c);
            if(String.isNotEmpty(mapStaticLink.get(key).Tag__c)) {
                tags.add(mapStaticLink.get(key).Tag__c);
            }
        }
        
        // Retrieve Content Data
        Map<String, ContentWrapper[]> mapContentTag = new Map<String, ContentWrapper[]>();
        for(ContentVersion contentVersion : [
            SELECT Title
                 , TagCsv
                 , IsLatest
                 , ContentUrl
            	 , ContentDocumentId
              FROM ContentVersion
             WHERE IsLatest = true
        ]) {
            if(String.isNotEmpty(contentVersion.TagCsv)){
                for(String tag : contentVersion.TagCsv.split(',')) {
                    if(tags.contains(tag)) {
                        if(mapContentTag.containsKey(tag)) {
                            if(mapContentTag.get(tag).size() < 4) {
                                mapContentTag.get(tag).add(new ContentWrapper(contentVersion.Title, contentVersion.ContentUrl));
                            }
                        } else {
                            mapContentTag.put(tag, new ContentWrapper[]{new ContentWrapper(contentVersion.Title, contentVersion.ContentUrl)});
                        }
                    }
                }
            }
        }
        
        // Create a JSONGenerator object
        JSONGenerator gen = JSON.createGenerator(true);
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeFieldName('data');
        gen.writeStartObject();
        
        for(String category : mapResponse.keySet()) {
            gen.writeObjectField(category, mapResponse.get(category));
        }
        
        for(String tag : mapContentTag.keySet()) {
            gen.writeObjectField(tag, mapContentTag.get(tag));
        }
        
        gen.writeEndObject();
        gen.writeEndObject();
        
        // Add the generated JSON to response
        if(Test.isRunningTest()) {
            RestContext.response = new RestResponse();
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(gen.getAsString());
    }

    /**
    * This wrapper stores Content data which is send as response
    */           
    global class ContentWrapper {
        public String title;
        public String url;
        
        public ContentWrapper(String title, String url) {
            this.title = title;
            this.url = url;
        }
    }
}