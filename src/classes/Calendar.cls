global class Calendar{
    
    public List<TaskWrapper> tasks;
    public List<EventWrapper> events;
    public boolean isSuccess;
    public string message;
    
    public Calendar(){
    	isSuccess = false;
      	message = '';
    }
    
    public Calendar(List<TaskWrapper> tasks, List<EventWrapper> events){
    	this();
        isSuccess = true;
        this.tasks = tasks;
        this.events = events;
    }
}