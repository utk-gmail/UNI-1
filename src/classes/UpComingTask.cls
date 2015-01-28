global class UpComingTask{
    
    public List<TaskWrapper> tasks;
    public boolean isSuccess;
    public string message;
    
    public UpComingTask(){
        isSuccess = false;
    }
     
    public UpComingTask(List<TaskWrapper> tasks){
        isSuccess = true;
        message = '';
        this.tasks = tasks;
    }
}