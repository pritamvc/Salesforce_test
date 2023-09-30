public class LeadDispositionHandler {
    public static void updateStageStatusFromDisposition(List<Task> myTasks) {
        
        Map<Id,Lead> leadListToUpdate = new Map<Id,Lead>();
        Set<Id> leadIds = new Set<Id>();
        Map<Lead,Task> mapLeadvsTask = new Map<Lead,Task>();
        for(Task currentTask : myTasks){
            if(currentTask.Call_Result__c != null){
                leadIds.add(currentTask.WhoId);
            }            
        }
        
        //Creating Map of Leads
        Map<Id,Lead> leadMap = new Map<Id,Lead>([SELECT Id, Status, Status__c, Bad_Call_Count__c, Country_of_Study__c, Admission_Status__c,Call_Back_Count__c, University_Name__c, Institute_Name__c, Course_Id__c, Course_Stream__c, Course_Level__c, Loan_Required_A_B__c, Language_Score_Category__c, Language_Test_Score__c, Analytics_Score_Category__c, Analytics_Test_Score__c, Co_Applicant_Mobile__c, Co_Applicant_Name__c, Co_Applicant_Email__c, Service_Branch__c, OwnerId, Relationship_with_Applicant__c, In_hand_salary__c, Quantitative_Score__c, Verbal_Score__c, Occupation_Type__c From Lead WHERE Id In :leadIds]);
        
        //If Map is not null
        if(leadMap != NULL){            
            //Iterate through the list of Tasks
            for(Task objTask : myTasks){ 
                if(leadMap.get(objTask.WhoId) != null){
                    mapLeadvsTask.put(leadMap.get(objTask.WhoId),objTask);
                }               
            }           
            //If Lead record is present
            if(mapLeadvsTask != NULL){
                system.debug(mapLeadvsTask );
                leadListToUpdate = handleTaskDispostion(mapLeadvsTask);     
                system.debug(leadListToUpdate  );  
            }
            //If List have data to Update
            if(leadListToUpdate.size() > 0){            
                update leadListToUpdate.values();   
            }
        }
    }
    public static Map<Id,Lead> handleDispostion(Map<Lead,Task> mapLeadvsTask){
        Map<Id,Lead> leadListToUpdate = new Map<Id,Lead>();
        Map<String,Disposition_Type__mdt> mapDispostionvsObject = new  Map<String,Disposition_Type__mdt>();
        mapDispostionvsObject = getStageStatusFromDisposition();
        
        for(Lead objLead: mapLeadvsTask.keyset()){          
            String dispositionStageStatus = mapLeadvsTask.get(objLead).Call_Result__c+'#'+objLead.Status+'#'+objLead.Status__c;
            if(mapDispostionvsObject.get(dispositionStageStatus) != null){
                if(mapDispostionvsObject.get(dispositionStageStatus).New_Stage__c != null){
                    objLead.Status = mapDispostionvsObject.get(dispositionStageStatus).New_Stage__c;
                }
                if(mapDispostionvsObject.get(dispositionStageStatus).New_Status__c != null){
                    objLead.Status__c =  mapDispostionvsObject.get(dispositionStageStatus).New_Status__c;
                }
                leadListToUpdate.put(objLead.Id,objLead);
            }
        }
        return leadListToUpdate;
    }   
    
    public static Map<Id,Lead> handleTaskDispostion(Map<Lead,Task> mapLeadvsTask){
        Map<Id,Lead> leadListToUpdate = new Map<Id,Lead>();
        Map<String,Disposition_Type__mdt> mapDispostionvsObject = new  Map<String,Disposition_Type__mdt>();
        mapDispostionvsObject = getStageStatusFromDisposition();
      
        for(Lead objLead: mapLeadvsTask.keyset()){          
            String dispositionStageStatus = mapLeadvsTask.get(objLead).Call_Result__c+'#'+objLead.Status+'#'+objLead.Status__c;
            if(mapDispostionvsObject.get(dispositionStageStatus) != null){
                if(mapDispostionvsObject.get(dispositionStageStatus).Required_Fields__c  != null){
                    String requiredField = mapDispostionvsObject.get(dispositionStageStatus).Required_Fields__c;
                    system.debug('requiredField '+requiredField );
                    List<String> lstrequiredField = new List<String>();
                    lstrequiredField = requiredField.split(',');
                    Boolean requiredcheck = false;
                    for(String strRequiredField: lstrequiredField){
                        String[] checkRelationField = strRequiredField.split('\\.'); 
                        if(checkRelationField.size() >1 ){                        
                            Task objtask = mapLeadvsTask.get(objLead);
                            system.debug(checkRelationField[1]);
                            system.debug(objtask.get(checkRelationField[1]));
                            if (objtask.get(checkRelationField[1]) == null) {
                                system.debug('value is null');
                                if(requiredcheck == false){
                                    requiredcheck = true;
                                }
                                
                            }
                        }else{
                            if (objLead.get(strRequiredField) == null) {
                                system.debug('value is null');
                                if(requiredcheck == false){
                                    requiredcheck = true;
                                }                                
                            }
                        }
                    }
                    if(requiredcheck == false){
                        if(mapDispostionvsObject.get(dispositionStageStatus).New_Stage__c != null){
                            objLead.Status = mapDispostionvsObject.get(dispositionStageStatus).New_Stage__c;
                        }
                        if(mapDispostionvsObject.get(dispositionStageStatus).New_Status__c != null){
                            objLead.Status__c =  mapDispostionvsObject.get(dispositionStageStatus).New_Status__c;
                        }
                        leadListToUpdate.put(objLead.Id,objLead);
                    }else{
                       // exception queue part 
                    }                    
                }else{
                    if(mapDispostionvsObject.get(dispositionStageStatus).New_Stage__c != null){
                        objLead.Status = mapDispostionvsObject.get(dispositionStageStatus).New_Stage__c;
                    }
                    if(mapDispostionvsObject.get(dispositionStageStatus).New_Status__c != null){
                        objLead.Status__c =  mapDispostionvsObject.get(dispositionStageStatus).New_Status__c;
                    }
                    leadListToUpdate.put(objLead.Id,objLead);
                }
            }
        }
        return leadListToUpdate;
    }  
    public static Map<String,Disposition_Type__mdt> getStageStatusFromDisposition(){        
        list<Disposition_Type__mdt> lstdispositionStageStatus = new list<Disposition_Type__mdt>();
        lstdispositionStageStatus =[SELECT id,Disposition__c,Existing_Stage__c,Existing_Status__c,New_Stage__c,New_Status__c,Call_Count__c,Required_Fields__c FROM Disposition_Type__mdt];
        
        Map<String,Disposition_Type__mdt> mapDispostionvsObject = new  Map<String,Disposition_Type__mdt>();       
        for(Disposition_Type__mdt objDispositionType: lstdispositionStageStatus){               
            mapDispostionvsObject.put(objDispositionType.Disposition__c+'#'+objDispositionType.Existing_Stage__c+'#'+objDispositionType.Existing_Status__c,objDispositionType);
        }        
        //system.debug('dynamic disposition ======= '+json.serializePretty(mapDispostionvsObject));
        return mapDispostionvsObject;
    }
}