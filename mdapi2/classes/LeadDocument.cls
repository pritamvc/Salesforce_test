/*********************************************************************************************
* @author          Vaibhav Hinge
* @description     This Class used for Document validation purpose.
* @date            22 May 2023  
* @testClass:      
**********************************************************************************************/

public class LeadDocument {
    //method use for document validation
    @AuraEnabled
    public static String mandatoryDocumentValidation(String leadId){
        String message = '';
        
        // To fetch all co-applicants related to the leadId
        List<Co_Applicant__c> applicantsWithLeadIdRec = new  List<Co_Applicant__c>();
        applicantsWithLeadIdRec = [Select Id, Name,Type__c, Account__r.Id,Insertion_Order__c
                                   from Co_Applicant__c where Lead__r.Id =: leadId];
        
        //Create map to save AccountId vs Insertion_Order__c
        Map<Id,Decimal> mapAccIdvsOrder= new Map<Id,Decimal>();
        
        //Iterate through the list applicantsWithLeadIdRec and in map to save AccountId vs Insertion_Order__c
        for(Co_Applicant__c objCoApp: applicantsWithLeadIdRec ){
            mapAccIdvsOrder.put(objCoApp.Account__r.Id,objCoApp.Insertion_Order__c);
        } 
        // create map for Applicant name vs remaining document list
        Map<string, list<String>> accountFiles = new Map<string, list<String>>();
        
        //Iterate through the list of Account object to check not null fields 
        for (Account a: [SELECT Id,Name,Aadhar_Number__c,PAN_Number__c,Driving_License_Number__c,Passport_Number__c,Passport_File_Number__c,Voter_ID__c,
                         (SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize,ContentDocument.FileType FROM 
                          ContentDocumentLinks) FROM Account where Id in:mapAccIdvsOrder.keyset()]) {
                              
                              List<String> fileNames = new List<String>(); 
                              fileNames.add('Photo');
                              if(a.Aadhar_Number__c != null){
                                  fileNames.add('Aadhar_card_front'); 
                                  fileNames.add('Aadhar_card_back');    
                              }
                              if(a.PAN_Number__c != null){
                                  fileNames.add('pan_card');    
                              }
                              
                              if(a.Driving_License_Number__c != null){
                                  fileNames.add('Driving_license');
                              }
                              
                              if(a.Passport_Number__c != null || a.Passport_File_Number__c != null){
                                  fileNames.add('passport_back');
                                  fileNames.add('passport_front');    
                              }
                              if(a.Voter_ID__c != null){
                                  fileNames.add('voter_card_front');
                                  fileNames.add('voter_card_back');    
                              }
                              
                              Boolean found;
                              
                              List<String> remainingDocuments = new List<String>();
                              List<String> remainingFile = new List<String>();
                              
                              //Iterate through the list of fileNames which are mand for that applicant          
                              for (String fileName : fileNames) {
                                  found = false;
                                  //Iterate through the list of ContentDocumentLinks to check document available or not
                                  for (ContentDocumentLink cdl: a.ContentDocumentLinks) {
                                      String title = cdl.ContentDocument.Title;
                                      if (title.substring(0, title.indexOf('.')).contains(fileName)) {
                                          found = true;
                                          break;
                                      }
                                  }
                                  //if doc not available then create a remainingFile file.
                                  if (!found) {
                                      remainingFile.add(fileName);
                                  }  
                              } 
                              //Iterate through the list of remainingFile and give a easily readable doc name    
                              for(String file : remainingFile){
                                  if(file.startsWith('Photo')){                           
                                      remainingDocuments.add('Passport size photo');
                                  }
                                  if(file.startsWith('Aadhar_card_front')){                           
                                      remainingDocuments.add('Aadhar card front');
                                  }
                                  if(file.startsWith('Aadhar_card_back')){                            
                                      remainingDocuments.add('Aadhar card back');
                                  }
                                  if(file.startsWith('pan_card')){
                                      system.debug('check123   =>'+file.startsWith('pan'));                            
                                      remainingDocuments.add('Pan Card');
                                  }
                                  if(file.startsWith('Driving_license')){                           
                                      remainingDocuments.add('Driving license');
                                  }
                                  if(file.startsWith('passport_front')){                           
                                      remainingDocuments.add('Passport front');
                                  }
                                  if(file.startsWith('passport_back')){                           
                                      remainingDocuments.add('Passport back');
                                  }
                                  if(file.startsWith('voter_card_front')){                           
                                      remainingDocuments.add('Voter Id front');
                                  }
                                  if(file.startsWith('voter_card_back')){                           
                                      remainingDocuments.add('Voter Id back');
                                  }
                              }
                              
                              accountFiles.put(a.Name,remainingDocuments);    
                          } 
        String result = '';
        
        //Iterate through the list of accountFiles for creating return string message
        for (String key : accountFiles.keySet()) {
            List<String> values = accountFiles.get(key);
            system.debug('Size'+values.size());
            if(values.size()>0){
                result += key + ':';
                for (Integer i = 0; i < values.size(); i++) {
                    result += values[i];
                    if (i < values.size() - 1) {
                        result += ',';
                    }else{
                        result += ' & ';
                    }
                }
            }  
        }
        
        
        
        
        // Check result if null then return success msg else send string
        system.debug('result'+result);
        if(result==''){
            message='success';
        }else{
            String inputString = result;
            String[] parts = inputString.split('&');
            String outputString = parts[0];
            message=outputString;
        }
        return message;
    }
    // method use for lead weightage percentage
    @AuraEnabled
    public static Lead updateDocumentCheck(String leadId,Boolean isCheck){
        Lead Doc = [SELECT Id,Document_Checked__c FROM Lead WHERE Id =: leadId];
        Doc.Document_Checked__c = isCheck;
        update Doc;
        return Doc;
    }
    
    // Method used for checking lead weightage for checking all section are fill or not 
    @AuraEnabled
    public static Decimal getLeadWeightage(Id leadId) {
        Decimal perc;
        Lead myLead = [SELECT Lead_form_Weightage__c FROM Lead WHERE Id = :leadId];
        if (myLead != null) {
            perc = myLead.Lead_form_Weightage__c;
        } 
        return perc ;
    }
    
    //Method use for checking at least one financial co-applicant.
    @AuraEnabled
    public static Decimal getFinancialCoApplicants(Id leadId){
        List<Co_Applicant__c> financialCoApplicants = new  List<Co_Applicant__c>();
        //string applicantType = system.Label.Applicant_Type;
        financialCoApplicants = [Select Id,Name,Account__r.Name,Lead__r.Id,Account__r.Id,Type__c from Co_Applicant__c where Type__c != 'Applicant' AND Lead__r.Id = :leadId AND Is_Income_Considered_Financial__c = 'Yes'];
        
        return financialCoApplicants.size();         
    }
    
}