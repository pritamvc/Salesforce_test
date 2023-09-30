public class ReportEmailSchedular implements Schedulable{
    private string count;
    
    public reportEmailSchedular(string count) {
        this.count=count;        
    }

    public void execute(SchedulableContext sc) {
        
        if (count.equals('1')) {
            system.debug('1');
            ReportEmail.sendReport();
            //ReportEmailFlowSchedular.sendReport();
           
        } else if (count.equals('2')) {
            system.debug('2');
            ReportEmail.sendReport();
            //ReportEmailFlowSchedular.sendReport();
                    }
        else if (count.equals('3'))
        {
            system.debug('3');
            ReportEmail.sendReport();
            //ReportEmailFlowSchedular.sendReport();
            
        }
        //remove schedular
        Id jobId = sc.getTriggerId();
            System.abortJob(jobId);
    }
        
    }