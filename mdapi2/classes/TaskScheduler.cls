public class TaskScheduler implements Queueable {
    private Task taskToInsert;
    private Integer delaySeconds;

    public TaskScheduler(Task taskToInsert, Integer delaySeconds) {
        this.taskToInsert = taskToInsert;
        this.delaySeconds = delaySeconds;
    }

    public void execute(QueueableContext context) {
        // Wait for the specified delay
        Long futureTime = System.currentTimeMillis() + (delaySeconds * 1000);
        while (System.currentTimeMillis() < futureTime) {
            // Wait for the delay to pass
        }
        
        insert taskToInsert;
    }
}