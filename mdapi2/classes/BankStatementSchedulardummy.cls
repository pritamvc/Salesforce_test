public class BankStatementSchedulardummy implements Schedulable {
    private String apiName;
    private String docId;
    private Id leadId;
    private Id accId;
    private string response;
    private String fileName;
    private string base64;
    private string  password;
    public BankStatementSchedulardummy(String apiName, String docId, Id leadId, Id accId ,String fileName ,String password) {
        this.apiName = apiName;
        this.docId = docId;
        this.leadId = leadId;
        this.accId = accId;
        this.fileName = fileName;
        this.base64=base64;
        this.password=password;
    }

    public void execute(SchedulableContext sc) {
        
        if (apiName.equals('Upload PDF Binary')){
            system.debug('leadId'+ leadId+'accId'+ 'apiName' + apiName + 'password'+ password+'fileName'+fileName+'docId'+docId);
            BankStatementAnalyzerdummy.uploadBinaryPDF(leadId ,accId, apiName , docId, password, fileName);
        } else if (apiName.equals('Download Report Data Excel')) {
            BankStatementAnalyzerdummy.downloadFileExcel(leadId, accId, apiName, docId,fileName);
        }
            else if (apiName.equals('Download Report Data')) {
           BankStatementAnalyzerdummy.downloadFile(apiName, docId, leadId, accId, fileName);
        }
        //remove schedular
        Id jobId = sc.getTriggerId();
            System.abortJob(jobId);
    }
        
    }