/*******************************************************************************************************
* @author          Thinqloud Solutions (Dhanshri Pimplapure)
* @description     This class we are using to create Document Checklist Records
* @date            26/06/2023    
* @testClass: 
********************************************************************************************************/
public class CreateDocumentChecklistRecords {
/********************************************************************************************************
* @author          Dhanshri Pimplapure
* @description     This Method is use to create the Document Checklist Record and return the New 
				   List of Document Checklist
* @param           Id leadid, string applicantId
* @return		   List<Document_Checklist__c> : List of new created Document Checklist Record
*                       
* @date            26/06/2023  
*********************************************************************************************************/
    public static List<Document_Checklist__c> documentCheklistmaster(Id leadid,string applicantId){
        system.debug('test');
        String leadIdStr = String.valueOf(leadid);
        Opportunity opp;
        if(!leadIdStr.startsWith('00Q')){
        	opp = [SELECT Id,Lead__c FROM Opportunity WHERE Id =: leadIdStr];
        }
        Co_Applicant__c applicantname = [Select Id, Type__c, Account__c, Account__r.FirstName,Account__r.LastName from Co_Applicant__c
                                         where Id =: applicantId];
        system.debug('test 22   '+applicantId);
        
        List<Document_Checklist_Master__c> listDCLMaster = [Select id,Applicant_Type__c,Document_Sub_Type__c,Auto_Create_Checklist__c,Document_Type__c,File_Size__c,
                                                            File_Types__c,Instruction_To_Upload_Documents__c,IsMandetory__c from
                                                            Document_Checklist_Master__c where Applicant_Type__c =:applicantname.Type__c and Auto_Create_Checklist__c=true ];
        
        List<Document_Name_DMS__mdt> documentNames = [SELECT Id,Label,Applicant_Type__c,Document_Type__c FROM Document_Name_DMS__mdt WHERE Applicant_Type__c =: applicantname.Type__c];
        
        List<Document_Checklist__c> finalList = new list<Document_Checklist__c>();
        if(listDCLMaster != null && listDCLMaster.size() > 0 ){
            for(Document_Checklist_Master__c dcm :listDCLMaster){
                Document_Checklist__c dc = new Document_Checklist__c();
                dc.Applicant_Name__c =applicantname.Account__r.FirstName + ' '+applicantname.Account__r.LastName;
                system.debug('test35    '+dc.Applicant_Name__c);
                dc.Applicant_Type__c = dcm.Applicant_Type__c;
                dc.Applicant__c =applicantId;
                system.debug('test38    '+applicantId);
                dc.Doc_Sub_Type__c = dcm.Document_Sub_Type__c;
                dc.Document_Checklist_Master__c=dcm.id;
                dc.Document_Type__c =dcm.Document_Type__c;
                dc.File_Size__c = dcm.File_Size__c;
                dc.File_Types__c=dcm.File_Types__c;
                dc.Status__c = 'Pending';
                dc.Document_Instruction__c=dcm.Instruction_To_Upload_Documents__c;
                if(leadIdStr.startsWith('00Q')){
                    dc.Lead__c = leadid;
                }else{
                    dc.Lead__c = opp.Lead__c;
                    dc.Deal__c = leadid;
                }
                
                dc.IsMandatory__c = dcm.IsMandetory__c;
                
                //Assign document name as per document type
                for(Document_Name_DMS__mdt currName : documentNames){
                    if(dcm.Document_Sub_Type__c == currName.Document_Type__c){
                        dc.Document_DMS_Name__c = currName.Label;
                        break;
                    }
                }
                finalList.add(dc);
            }  
        }
        if( finalList != null && finalList.size() > 0){
            insert finalList;
        }
        return finalList;
    }
}