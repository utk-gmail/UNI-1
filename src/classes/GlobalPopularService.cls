/**
* This rest service is used to retrive popular Contents
*/
@RestResource(urlMapping='/Global/Popular')
global class GlobalPopularService {
    /**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static void retrivePopular() {
        // Retrieve the popular contents
        ContentWrapper[] lstContentWrapper = new ContentWrapper[] {};
        for(ContentVersion contentVersion : [
            SELECT Title
                 , TagCsv
                 , IsLatest
                 , ContentUrl
              FROM ContentVersion
             WHERE IsLatest = true
             ORDER BY LastModifiedDate DESC 
        ]) {
            if(String.isNotEmpty(contentVersion.TagCsv) && contentVersion.TagCsv.containsIgnoreCase('popular') && lstContentWrapper.size() < 5) {
                lstContentWrapper.add(new ContentWrapper(contentVersion.Title, contentVersion.ContentUrl));
            }
        }
        
        // Create a JSONGenerator object
        JSONGenerator gen = JSON.createGenerator(true);
        // Write data to the JSON string.
        gen.writeStartObject();
        gen.writeObjectField('popular', lstContentWrapper);
        gen.writeEndObject();
        
        // Add the generated JSON to response
        if(Test.isRunningTest()) {
            RestContext.response = new RestResponse();
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(gen.getAsString());
    }
    
    /**
    * This wrapper stores account data which is send as response
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