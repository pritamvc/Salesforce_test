/*********************************************************************************************
* @author          Sohail Solapure
* @description     This class is to convert Lead to Opportunity with checking the checklist
* @date            9 Feb 2023  
* @testClass:      ConvertLeadToOpportunityTest
**********************************************************************************************/
public class ConvertLeadToOpportunity {
    
    /********************************************************************************************************
* @author          Sohail Solapure
* @description     This method will convert Lead to Deal if checklist is done
* @param           myLeads (List<Lead>) : List of Leads     
* @return          No-return
* @date            9 Feb 2023   
********************************************************************************************************/    
    @InvocableMethod
    public static List<String> convertLead(List<Id> myLeads) {
        List<Lead> myLeadList = [Select Id,Email,MobilePhone,OwnerId,CreatedDate from Lead where Id In :myLeads];  
        
        for (Id leadId : myLeads) {
            String applicantId = getApplicantIdFromLead(leadId); // Get the applicant Id dynamically based on your logic
            documentCheklistmaster(leadId, applicantId);
            attachPdfDocumentChecklist(myLeads);
            //sendEmailDocChck(leadId); 
        }
        
        LeadStatus leadStatus = [Select Id,MasterLabel from LeadStatus where isConverted=true limit 1];
        List<Opportunity> oppList = new List<Opportunity>();
        Co_Applicant__c acc;
        List<String> oppId = new List<String>();
        /*********/
        Id managerRoleId = [SELECT Id FROM UserRole WHERE Name = :CommonConstant.DETAENTRY_MANAGER AND ParentRoleId != null LIMIT 1].Id;
        Group dataEntryTeam = [SELECT Id, Name FROM Group WHERE Name = :CommonConstant.DATAENTERYQUEUE LIMIT 1];
        List<User> managers = [SELECT Id FROM User WHERE UserRoleId = :managerRoleId AND Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :dataEntryTeam.Id) AND IsActive = TRUE ];
        /************************/
        try{
            acc = [SELECT Id,Type__c,Account__c FROM Co_Applicant__c WHERE Lead__c =: myLeads AND Type__c =: System.Label.Applicant_Type LIMIT 1];
        }catch(Exception e){
            e.getMessage();
        }
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.Label.Opportunity_B2C_Record_Type).getRecordTypeId();
        
        // Get all related tasks for the leads
        List<Task> tasksToUpdate = [SELECT Id, Status, WhoId FROM Task WHERE WhoId IN :myLeadList AND Status != 'Completed'];
        if(tasksToUpdate != null){
            updateLeadTaskStatus(tasksToUpdate);
        }
        List<Id> oppListCon=new List<Id>();
        for(Lead l:myLeadList){
            Database.LeadConvert leadConvert = new Database.LeadConvert();
            
            leadConvert.setLeadId(l.Id);
            leadConvert.setConvertedStatus(leadStatus.MasterLabel);
            if(acc != Null){
                leadConvert.setAccountId(acc.Account__c);
            }
            String leadEmail = l.Email;
            String leadMobile = l.MobilePhone;
            
            Database.LeadConvertResult lcr = Database.convertLead(leadConvert);            
            
            
            if(lcr.isSuccess()){               
                
                Opportunity o = new Opportunity();
                o.Id = lcr.getOpportunityId();
                oppId.add(lcr.getOpportunityId());
                o.Applicant_Email__c = leadEmail;
                o.RecordTypeId = recordTypeId ;
                o.Applicant_Mobile_Number__c = leadMobile;
                o.Lead__c = l.Id;
                o.Deal_stage_owner_Id__c = dataEntryTeam.Id;
                o.Status__c = System.Label.Opportunity_Status_Lead_Convert ;
                o.StageName = System.Label.Opportunity_Stage_Lead_Convert ;
                o.Stage_Restrict_DateTime__c=system.now();
                o.login_date_and_time__c = system.today();
                // o.Lead_Created_Date__c = l.CreatedDate.date();
                if (!managers.isEmpty()) {
                    o.Stage_Owner__c =managers[0].Id;
                }
                oppList.add(o);  
                oppListCon.add(lcr.getOpportunityId());
            }
        }
        
        
        if(!oppList.IsEmpty() && oppList.size() > 0){            
            Database.update(oppList);
            copyLeadDataWithChildToDeal(oppList);
        }
        
        
        
        // Call to create Work Item API
        if(System.Label.Call_LOS.equalsIgnoreCase('true')){
            Database.executeBatch(new BatchToCreateWIForDeal(myLeads),1);  
        }// Commented by Chandrakant after discussion with Asim
        
        //added by harsh
        if (!myLeads.isEmpty() &&myLeads.size()>0) {
            String leadIds = String.valueOf(myLeads[0]);
            BatchPennyDropAPI batch = new BatchPennyDropAPI(leadIds);
            if(!Test.isRunningTest()){
                Database.executeBatch(batch,1);
            }
        }
        /*if (!myLeads.isEmpty() &&myLeads.size()>0) {
            String leadIds = String.valueOf(myLeads[0]);
            BatchBankStatement batch = new BatchBankStatement(leadIds);
            Database.executeBatch(batch,1);
        }*/
        //end by Harsh
        //Added  by Rahul
        if(!oppListCon.IsEmpty() && oppListCon.size() > 0){  
            SendEmailOnDealCreation.sendEmailDocChck(oppListCon);
        }
        //Ended  by Rahul
        
        return oppId;
    }
    
    /********************************************************************************************************
    * @author          Chandrakant More
    * @description     updateLeadLineItemToOpportunity this method is used to create map lead related data to the converted opportunity.
    * @param           convertedOpportunityList (List) : used to pass the list of converteds opportunity to the method as parameter.
    * @date            23/03/2023   
    ********************************************************************************************************/
    public static void copyLeadDataWithChildToDeal(List<Opportunity> convertedOpportunityList){
        //try-Block for exception handling
        try {
            Map<Id,Id> mapLeadIdAndOpportunityId = new Map<Id,Id>();
            List<Co_Applicant__c> applicantList = new List<Co_Applicant__c>();
            List<Co_Applicant__c> updatedApplicantList = new List<Co_Applicant__c>(); 
            List<Reference__c> referenceList = new List<Reference__c>();
            List<Reference__c> updatedReferenceList = new List<Reference__c>();
            List<ContactPointAddress> addressList = new List<ContactPointAddress>();
            List<ContactPointAddress> updatedAddressList = new List<ContactPointAddress>();
            List<Bank_Details__c> bankAccountList = new List<Bank_Details__c>();
            List<Bank_Details__c> updatedBankAccountList = new List<Bank_Details__c>();
            List<Asset> assetList = new List<Asset>();
            List<Asset> updatedAssetList = new List<Asset>();
            List<Education_Details__c> educationDetailsList = new List<Education_Details__c>();
            List<Education_Details__c> updatedEducationDetailsList = new List<Education_Details__c>();
            List<Employment_Details__c> employmentDetailsList = new List<Employment_Details__c>();
            List<Employment_Details__c> updatedEmploymentDetailsList = new List<Employment_Details__c>();
            List<Liability__c> liabilityList = new List<Liability__c>();
            List<Liability__c> updatedLiabilityList = new List<Liability__c>();
            List<Demography__c> demographyList = new List<Demography__c>();
            List<Demography__c> updatedDemographyList = new List<Demography__c>();
            List<Document_Checklist__c> docCheckList = new List<Document_Checklist__c>();
            List<Document_Checklist__c> updateDocCheckList = new List<Document_Checklist__c>();
            List<Note> attachedNotes = new List<Note>();
            List<Note> updatedAttachedNotes = new List<Note>();
            
            // map for leadId and converted opportunityId
            if(!convertedOpportunityList.IsEmpty() && convertedOpportunityList.size() > 0){
                for(Opportunity objectOpportunity : convertedOpportunityList){
                    mapLeadIdAndOpportunityId.put(objectOpportunity.Lead__c,objectOpportunity.Id);
                }
            }
            
            // get the all related object of lead indormation to map converted opportunity
            if(!mapLeadIdAndOpportunityId.IsEmpty() && mapLeadIdAndOpportunityId.size() > 0){
                applicantList =[SELECT Id,Lead__c,Deal__c FROM Co_Applicant__c where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                referenceList =[SELECT Id,Lead__c,Deal__c FROM Reference__c where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                addressList =[SELECT Id,Lead__c,Deal__c FROM ContactPointAddress where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                bankAccountList =[SELECT Id,Lead__c,Deal__c FROM Bank_Details__c where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                assetList =[SELECT Id,Lead__c,Deal__c FROM Asset where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                educationDetailsList =[SELECT Id,Lead__c,Deal__c FROM Education_Details__c where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                employmentDetailsList =[SELECT Id,Lead__c,Deal__c FROM Employment_Details__c where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                liabilityList =[SELECT Id,Lead__c,Deal__c FROM Liability__c where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                demographyList =[SELECT Id,Lead__c,Deal__c FROM Demography__c where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                docCheckList = [SELECT Id,Lead__c,Deal__c FROM Document_Checklist__c where Lead__c In: mapLeadIdAndOpportunityId.keySet()];
                attachedNotes = [SELECT Id,Body,ParentId FROM Note WHERE ParentId IN:mapLeadIdAndOpportunityId.keySet()];
            }
            
            //iterations on related object to update converted opportunityId
            for(Co_Applicant__c objectApplicant : applicantList){
                if (mapLeadIdAndOpportunityId.containsKey(objectApplicant.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectApplicant.Lead__c) != null){
                        objectApplicant.Deal__c=mapLeadIdAndOpportunityId.get(objectApplicant.Lead__c);
                    }
                    updatedApplicantList.add(objectApplicant);
                } 
            }
            for(Reference__c objectReference : referenceList){
                if (mapLeadIdAndOpportunityId.containsKey(objectReference.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectReference.Lead__c) != null){
                        objectReference.Deal__c=mapLeadIdAndOpportunityId.get(objectReference.Lead__c);
                    }
                    updatedReferenceList.add(objectReference);
                } 
            }
            for(ContactPointAddress objectAddress : addressList){
                if (mapLeadIdAndOpportunityId.containsKey(objectAddress.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectAddress.Lead__c) != null){
                        objectAddress.Deal__c=mapLeadIdAndOpportunityId.get(objectAddress.Lead__c);  
                    }
                    updatedAddressList.add(objectAddress);
                } 
            }
            for(Bank_Details__c objectBankAccount : bankAccountList){
                if (mapLeadIdAndOpportunityId.containsKey(objectBankAccount.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectBankAccount.Lead__c) != null){
                        objectBankAccount.Deal__c=mapLeadIdAndOpportunityId.get(objectBankAccount.Lead__c); 
                    }
                    updatedBankAccountList.add(objectBankAccount);
                } 
            }
            for(Asset objectAsset : assetList){
                if (mapLeadIdAndOpportunityId.containsKey(objectAsset.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectAsset.Lead__c) != null){
                        objectAsset.Deal__c=mapLeadIdAndOpportunityId.get(objectAsset.Lead__c);
                    } 
                    updatedAssetList.add(objectAsset);
                } 
            }
            for(Education_Details__c objectEducationDetail : educationDetailsList){
                if (mapLeadIdAndOpportunityId.containsKey(objectEducationDetail.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectEducationDetail.Lead__c) != null){
                        objectEducationDetail.Deal__c=mapLeadIdAndOpportunityId.get(objectEducationDetail.Lead__c);  
                    } 
                    updatedEducationDetailsList.add(objectEducationDetail);
                } 
            }
            for(Employment_Details__c objectEmploymentDetail : employmentDetailsList){
                if (mapLeadIdAndOpportunityId.containsKey(objectEmploymentDetail.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectEmploymentDetail.Lead__c) != null){
                        objectEmploymentDetail.Deal__c=mapLeadIdAndOpportunityId.get(objectEmploymentDetail.Lead__c);  
                    }
                    updatedEmploymentDetailsList.add(objectEmploymentDetail);
                } 
            }
            for(Liability__c objectLiability : liabilityList){
                if (mapLeadIdAndOpportunityId.containsKey(objectLiability.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectLiability.Lead__c) != null){
                        objectLiability.Deal__c=mapLeadIdAndOpportunityId.get(objectLiability.Lead__c);  
                    }
                    updatedLiabilityList.add(objectLiability);
                } 
            }
            for(Demography__c objectDemography : demographyList){
                if (mapLeadIdAndOpportunityId.containsKey(objectDemography.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectDemography.Lead__c) != null){
                        objectDemography.Deal__c=mapLeadIdAndOpportunityId.get(objectDemography.Lead__c);   
                    }
                    updatedDemographyList.add(objectDemography);
                } 
            }
            for(Document_Checklist__c objectDocChecklist : docCheckList){
                if (mapLeadIdAndOpportunityId.containsKey(objectDocChecklist.Lead__c)) {
                    if(mapLeadIdAndOpportunityId.get(objectDocChecklist.Lead__c) != null){
                        objectDocChecklist.Deal__c=mapLeadIdAndOpportunityId.get(objectDocChecklist.Lead__c);   
                    }
                    updateDocCheckList.add(objectDocChecklist);
                } 
            }
            for(Note currNote : attachedNotes){
                if (mapLeadIdAndOpportunityId.containsKey(currNote.ParentId)) {
                    if(mapLeadIdAndOpportunityId.get(currNote.ParentId) != null){
                        currNote.ParentId =mapLeadIdAndOpportunityId.get(currNote.ParentId);
                    }
                    updatedAttachedNotes.add(currNote);
                } 
            }
            
            //update list of related object with converted opportunityId
            if(!updatedApplicantList.IsEmpty() && updatedApplicantList.size() > 0){
                Update updatedApplicantList;       
            }
            if(!updatedReferenceList.IsEmpty() && updatedReferenceList.size() > 0){
                Update updatedReferenceList;       
            }
            if(!updatedAddressList.IsEmpty() && updatedAddressList.size() > 0){
                Update updatedAddressList;       
            }
            if(!updatedBankAccountList.IsEmpty() && updatedBankAccountList.size() > 0){
                Update updatedBankAccountList;       
            }
            if(!updatedAssetList.IsEmpty() && updatedAssetList.size() > 0){
                Update updatedAssetList;       
            }
            if(!updatedEducationDetailsList.IsEmpty() && updatedEducationDetailsList.size() > 0){
                Update updatedEducationDetailsList;       
            }
            if(!updatedEmploymentDetailsList.IsEmpty() && updatedEmploymentDetailsList.size() > 0){
                Update updatedEmploymentDetailsList;       
            }
            if(!updatedLiabilityList.IsEmpty() && updatedLiabilityList.size() > 0){
                Update updatedLiabilityList;       
            }
            if(!updatedDemographyList.IsEmpty() && updatedDemographyList.size() > 0){
                Update updatedDemographyList;       
            }
            if(!updateDocCheckList.IsEmpty() && updateDocCheckList.size() > 0){
                Update updateDocCheckList;       
            }
            if(!updatedAttachedNotes.IsEmpty() && updatedAttachedNotes.size() > 0){
                Update updatedAttachedNotes;       
            }
            //catch-Block for exception handling
        } catch (Exception e) {
            e.getMessage();
        }
    } 
    
    /**
     * Author: Chandrakant More
     * @description This method is used to create a map of lead-related data to the converted opportunity.
     * 
     * This method takes a list of converted opportunities as input and creates a map that links
     * lead-related data to each converted opportunity. The map can be used for reference or further processing.
     * 
     * @param tasks The list of converted opportunities to be mapped.
     * @date 23/03/2023
     */
    public static void updateLeadTaskStatus (List<Task> tasks){
        
        List<Task> updatedTasks = new List<Task>();
        try {
            for (Task tsks : tasks) {
                tsks.Status = 'Completed';
                updatedTasks.add(tsks);
            }
            update updatedTasks;
            
        } catch (Exception ex) {
            // Handle the exception here (you can log it or take appropriate action)
            ex.getMessage();
        }
    }
    
    /**
     * Author: Rahul Shukla
     * @description This method is attach pdf
     * 
     * This method takes a list of converted opportunities as input and creates a map that links
     * lead-related data to each converted opportunity. The map can be used for reference or further processing.
     * 
     * @param leadids The list of converted opportunities to be mapped.
     * @date 23/03/2023
     */
    public static void attachPdfDocumentChecklist(List<ID> leadids){ 
        PageReference pdfPage = Page.LoanApplicationPDF;
        pdfPage.getParameters().put('id',Leadids[0]);
        List<Id> leadid = new List<Id>();
        leadid.add(leadids[0]);
        Lead leadRecord = [SELECT Id, FirstName, LastName FROM Lead WHERE Id = :leadids[0] LIMIT 1];
        List<Document_Checklist__c> docchklist=[select id from 	Document_Checklist__c where Document_Type__c='Other Document' and Doc_Sub_Type__c='Application Form' and Lead__c=:leadid];   
        
        Blob pdfBlob;
        if (!Test.isRunningTest()) {
            pdfBlob = pdfPage.getContent();
        } else {
            pdfBlob = Blob.valueOf('Some Text for a boring PDF file...');
        }
        
        // Create a ContentVersion record
        ContentVersion contentVersion = new ContentVersion(
            Title = leadRecord.FirstName + ' ' + leadRecord.LastName + '-Loan Application Form.pdf',
            VersionData = pdfBlob,
            PathOnClient = leadRecord.FirstName + ' ' + leadRecord.LastName + '-Loan Application Form.pdf'
        );
        insert contentVersion;
        List<ContentDistribution> lstContentDistribution = new List<ContentDistribution>();
        ContentDistribution cd = new ContentDistribution();
        cd.Name = contentVersion.Title;
        cd.ContentVersionId = contentVersion.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        lstContentDistribution.add(cd);
        insert lstContentDistribution; 
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        
        For(Document_Checklist__c doc: docchklist){
            createContentDocumenlink(doc.id,conDoc);
        }
        
    }
    
    /**
     * Author: Rahul Shukla
     * @description This method is attach pdf
     * 
     * This method takes a list of converted opportunities as input and creates a map that links
     * lead-related data to each converted opportunity. The map can be used for reference or further processing.
     * 
     * @param recordid 
     * @param conDoc
     * @date 23/03/2023
     */
    public static void createContentDocumenlink(String recordid,String conDoc){
        // Create a ContentDocumentLink to associate the ContentVersion with the Lead record
        ContentDocumentLink newContentLink = new ContentDocumentLink(
            ContentDocumentId = conDoc,
            LinkedEntityId = recordid,
            ShareType = 'V'
        );
        insert newContentLink;
        
    }
    
    /**
     * Author: Rahul Shukla
     * @description This method is attach pdf
     * 
     * This method takes a list of converted opportunities as input and creates a map that links
     * lead-related data to each converted opportunity. The map can be used for reference or further processing.
     * 
     * @param leadid 
     * @param applicantId
     * @date 23/03/2023
     */
    public static List<Document_Checklist__c> documentCheklistmaster(Id leadid,string applicantId){
        
        Co_Applicant__c applicantname = [Select Id, Type__c, Account__c, Account__r.FirstName,Account__r.LastName from Co_Applicant__c where Id =: applicantId];
        
        List<Document_Checklist_Master__c> listDCLMaster = [Select id,Applicant_Type__c,Document_Sub_Type__c,Auto_Create_Checklist__c,Document_Type__c,File_Size__c,
                                                            File_Types__c,Instruction_To_Upload_Documents__c,IsMandetory__c from
                                                            Document_Checklist_Master__c where Applicant_Type__c ='Applicant' and Auto_Create_Checklist__c = false and Document_Type__c='Other Document' and Document_Sub_Type__c='Application Form'];
        
        //Get the document names list as per type of applicant
        List<Document_Name_DMS__mdt> documentNames = [SELECT Id,Label,Applicant_Type__c,Document_Type__c FROM Document_Name_DMS__mdt WHERE Applicant_Type__c ='Applicant' AND Document_Type__c='Application Form' ];
        
        List<Document_Checklist__c> finalList = new list<Document_Checklist__c>();
        if(listDCLMaster != null && listDCLMaster.size() > 0 ){
            for(Document_Checklist_Master__c dcm :listDCLMaster){
                Document_Checklist__c dc = new Document_Checklist__c();
                dc.Applicant_Name__c =applicantname.Account__r.FirstName + ' '+applicantname.Account__r.LastName;
                dc.Applicant_Type__c = dcm.Applicant_Type__c;
                dc.Applicant__c =applicantId;
                dc.Doc_Sub_Type__c = dcm.Document_Sub_Type__c;
                dc.Document_Checklist_Master__c=dcm.id;
                dc.Document_Type__c =dcm.Document_Type__c;
                dc.File_Size__c = dcm.File_Size__c;
                dc.File_Types__c=dcm.File_Types__c;
                dc.Status__c = 'Uploaded';
                
                dc.Document_Instruction__c=dcm.Instruction_To_Upload_Documents__c;
                dc.Lead__c = leadid;
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
    
    /**
     * Author: Rahul Shukla
     * @description This method is attach pdf
     * 
     * This method takes a list of converted opportunities as input and creates a map that links
     * lead-related data to each converted opportunity. The map can be used for reference or further processing.
     * 
     * @param leadId 
     * @date 23/03/2023
     */
    public static String getApplicantIdFromLead(Id leadId) {
        String applicantId = '';
        
        // Query the related Applicant__c record based on the leadId
        List<Co_Applicant__c> coApplicants = [SELECT Id FROM Co_Applicant__c WHERE Lead__c = :leadId LIMIT 1];
        
        // Check if a Applicant__c record was found
        if (!coApplicants.isEmpty()) {
            applicantId = coApplicants[0].Id;
        }
        
        return applicantId;
    }
    
    
}