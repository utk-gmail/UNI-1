/*
* This class defines default JSON structure for Webservice Response.
*/
global virtual class Response {
    
    global String status {get; set;}
    global String errorCode {get; set;}
    global String message {get; set;}

    global Response() {
        status = null;
        errorCode = 'NO_ERROR';
        message = null;
    }

}