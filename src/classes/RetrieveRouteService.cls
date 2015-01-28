/**
* This rest service is used to retrieve route information
*/
@RestResource(urlMapping='/Routes/RoutesForToday')
global with sharing class RetrieveRouteService{
 	
 	/**
    * This method gets called when get http method is performed
    */
    @HttpGet
    global static Routes retrieveRoute() {
        Routes response;
        RestRequest request = RestContext.request;
        String dateStringParam = request.params.get(ServiceUtils.DATE_PARAMETER);
        String ownerIdParam = request.params.get(ServiceUtils.OWNER_ID_PARAMETER);
        try{
            
            /**
        	* Pass user id parameter value and true to notify that ownerId is used as a parameter.
        	* This boolean is used to show different error message for ownerId as parameter and userId as parameter 
        	*/
            String ownerId = ServiceUtils.getUserParameter(ownerIdParam, true);
            
            /**
            * If date is not passed then current date is used
            */
            Date dateParam = ServiceUtils.getDate(dateStringParam);
            
            /**
            * Fetch route
            */ 
            List<Route__c> routeList = [Select Id, Name, OwnerId 
                                        from Route__c 
                                        where OwnerId =: ownerId
                                        and day_only(convertTimezone(createdDate)) =: dateParam];
            response = new Routes(routeList);
            
        }
        catch(Exception ex){
            response = new Routes(ex.getMessage());
        }
        return response;
        
    }
    
    /**
    * This wrapper stores route response
    */
    global class Routes{
        public List<RouteWrapper> routes;
        public String message;
        public boolean isSuccess;
        
        Routes(List<Route__c> routeList){
            routes = new List<RouteWrapper>();
            for(Route__c route: routeList){
                routes.add(new RouteWrapper(route));
            }
            message = '';
            isSuccess = true;
        }
        
        Routes(String message){
            this.message = message;
            isSuccess = false;
        }
    }
    
    /**
    * This wrapper stores route information
    */
    public class RouteWrapper{
        String id;
        String name;
        String ownerId;
        
        RouteWrapper(Route__c route){
            id = route.Id;
            name = route.Name;
            ownerId = route.OwnerId;
        }
    }       
}