public class BankStatementSchedular implements Schedulable {
    private String apiName;
    private String docId;
    private Id leadId;
    private Id accId;
    private string response;
    private String fileName;
    private string password;
    public bankStatementSchedular(String apiName, String docId, Id leadId, Id accId ,String fileName,string password) {
        this.apiName = apiName;
        this.docId = docId;
        this.leadId = leadId;
        this.accId = accId;
        this.fileName = fileName;
        this.password=password;
        
    }

    public void execute(SchedulableContext sc) {
        
        if (apiName.equals('Download Report Data')) {
            //system.debug('leadId'+ leadId+'accId'+ 'apiName' + apiName + 'password'+ password+'fileName'+fileName+'docId'+docId);
           BankStatementAnalyzer.downloadFile(apiName, docId, leadId, accId, fileName);
        } else if (apiName.equals('Download Report Data Excel')) {
            //system.debug('leadId'+ leadId+'accId'+ 'apiName' + apiName + 'password'+ password+'fileName'+fileName+'docId'+docId);
            BankStatementAnalyzer.downloadFileExcel(leadId, accId, apiName, docId,fileName);
        }
        else if (apiName.equals('Upload PDF Binary'))
        {//docid-=base64
            //system.debug('leadId'+ leadId+'accId'+ 'apiName' + apiName + 'password'+ password+'fileName'+fileName+'docId'+docId);
			BankStatementAnalyzer.uploadBinaryPDF(leadId ,accId, apiName , docId,password,fileName);
        }
        //remove schedular
        Id jobId = sc.getTriggerId();
            System.abortJob(jobId);
    }
        
    }