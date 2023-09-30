public class CaseTriggerHandler {
    public static void opportunityFilterMethod(List<Case> listOfCase,Map<Id,Case> oldMap){
        Map<Id,List<Id>> mapOfAccountIdVSOpportunityId = new Map<Id,List<Id>>();
        Set<Id> setOfAccount = new Set<Id>();
        for(Case newCase:listOfCase){
            if(newCase.AccountId != NULL && newCase.LAN__c != NULL ){
                setOfAccount.add(newCase.AccountId);
            }
            for(Co_Applicant__c applicant:[SELECT Id,Account__c,Deal__c FROM Co_Applicant__c WHERE Account__c IN:setOfAccount AND Deal__c != NULL]){
                if(!mapOfAccountIdVSOpportunityId.containsKey(applicant.Account__c)){
                    mapOfAccountIdVSOpportunityId.put(applicant.Account__c,new Id[] {applicant.Deal__c});
                } else{
                    mapOfAccountIdVSOpportunityId.get(applicant.Account__c).add(applicant.Deal__c);
                } 
            }
            system.debug('Map of Account VS Opp'+mapOfAccountIdVSOpportunityId);
            for(Case caseRec : listOfCase){
                if(mapOfAccountIdVSOpportunityId.IsEmpty() & caseRec.LAN__c != null){
                    caseRec.addError('Please select an Deal related to the particular Account.'); 
                }  
                if(((!oldMap.isEmpty() && caseRec.LAN__c != oldMap.get(caseRec.Id).LAN__c) || oldMap.isEmpty()) && !mapOfAccountIdVSOpportunityId.isEmpty()){
                    if( !mapOfAccountIdVSOpportunityId.get(caseRec.AccountId).contains(caseRec.LAN__c)){
                        caseRec.addError('Please select an Deal related to the particular Account.');
                    }
                }
            }
        }
    }
    public static void updateMilestoneCompletionTime(Map<Id, Case> caseNewMap,Map<Id, Case> caseOldMap){
        Set<Id> setOfCaseId = new Set<Id>();
        Set<Id> setOfCaseIdOfOpenStatus = new Set<Id>();
        Set<Id> setOfCaseIdPA = new Set<Id>();
        for(Case newCase:caseNewMap.values()){
            If(newCase.Status == 'Closed' && caseOldMap.get(newCase.Id).Status != newCase.Status){
                setOfCaseId.add(newCase.Id);
            }
            If(newCase.Status == 'Open' && caseOldMap.get(newCase.Id).Status != newCase.Status){
                setOfCaseIdOfOpenStatus.add(newCase.Id);
            }
            If(newCase.Status == 'Pending Approval' && caseOldMap.get(newCase.Id).Status != newCase.Status){
                setOfCaseIdPA.add(newCase.Id);
            }
        }
        System.debug('Open Status Set Id'+setOfCaseIdOfOpenStatus);
        If(setOfCaseId.size() > 0){
            List<CaseMilestone> caseMilestoneList = [SELECT ID,caseId, CompletionDate FROM CaseMilestone WHERE caseId IN: setOfCaseId AND CompletionDate = NULL];
            for(CaseMilestone CM: caseMilestoneList){
                CM.CompletionDate = System.now();
            }
            if(!caseMilestoneList.isEmpty()){
                Update caseMilestoneList;    
            }
        }
        
        If(setOfCaseIdOfOpenStatus.size()>0){
            List<CaseMilestone> caseMilestoneList = [SELECT ID,caseId, CompletionDate FROM CaseMilestone WHERE caseId IN: setOfCaseIdOfOpenStatus AND CompletionDate = NULL];
            for(CaseMilestone CM: caseMilestoneList){
                CM.CompletionDate = System.now();
            }
            if(!caseMilestoneList.isEmpty()){
                Update caseMilestoneList;    
            }
        }
        
        If(setOfCaseIdPA.size()>0){
            List<CaseMilestone> caseMilestoneList = [SELECT ID,caseId, CompletionDate FROM CaseMilestone WHERE caseId IN:setOfCaseIdPA  AND CompletionDate = NULL];
            for(CaseMilestone CM: caseMilestoneList){
                CM.CompletionDate = System.now();
            }
            if(!caseMilestoneList.isEmpty()){
                Update caseMilestoneList;    
            } 
        }
        
        
        
    }
}