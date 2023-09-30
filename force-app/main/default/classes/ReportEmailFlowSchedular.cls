public class ReportEmailFlowSchedular {    
    
    @InvocableMethod
    public static void EmailSchedular(){
        
        Datetime today = System.now();
        String dayOfWeek = today.format('EEEE');
        System.debug('Today is ' + dayOfWeek);
        
        if (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') {
            
        } 
        else {
            // 9 AM Scheduler
            Datetime scheduledTime9AM = today.addHours(9); // Set the time to 9 am
            String cronExpression9AM = '0 0 9 * * ?';
            string count='1';
            System.schedule('Send Report 9-AM'+ cronExpression9AM, cronExpression9AM, new ReportEmailSchedular(count));
            
        
            // 2 PM Scheduler
            Datetime scheduledTime2PM = today.addHours(14); // Set the time to 2 pm
            String cronExpression2PM = '0 0 14 * * ?';
            count='2';
            System.schedule('Send Report 2-PM'+ cronExpression2PM, cronExpression2PM, new ReportEmailSchedular(count));
            
        
            // 6 PM Scheduler
            Datetime scheduledTime6PM = today.addHours(18); // Set the time to 6 pm
            String cronExpression6PM = '0 0 18 * * ?';
            count='3';
            System.schedule('Send Report 6-PM'+ cronExpression6PM, cronExpression6PM, new ReportEmailSchedular(count));            
        }
    }
}