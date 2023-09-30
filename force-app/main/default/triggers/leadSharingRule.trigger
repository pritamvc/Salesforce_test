trigger leadSharingRule on Lead (before insert,before update) {
    if(trigger.IsUpdate){
        List<LeadShare> leadList = new list<LeadShare>();
        Group g =[select Id, Name from Group where  Type = 'Queue' AND Group.Name='MUMBAI Login Desk'];
        for(lead currRec : trigger.new )
        {
            if(currRec.Service_Branch__c !=Trigger.oldMap.get(currRec.id).Service_Branch__c && currRec.Service_Branch__c =='MUMBAI'){
                LeadShare leadShare = new LeadShare();
                leadShare.LeadId = currRec.Id;
                leadShare.UserOrGroupId = g.id;
                leadShare.LeadAccessLevel ='edit';
              //leadShare.RowCause=Schema.LeadShare.RowCause.Manual;
                leadList.add(leadShare);
            }
        }
        Database.SaveResult[] leadShareInsertRecord = Database.insert(leadList,false);
    }
    if(trigger.IsUpdate){
        List<LeadShare> leadList = new list<LeadShare>();
        Group g =[select Id, Name from Group where  Type = 'Queue' AND Group.Name='DELHI Login Desk'];
        for(lead currRec : trigger.new )
        {
            if(currRec.Service_Branch__c !=Trigger.oldMap.get(currRec.id).Service_Branch__c && currRec.Service_Branch__c =='DELHI'){
                LeadShare leadShare = new LeadShare();
                leadShare.LeadId = currRec.Id;
                leadShare.UserOrGroupId = g.id;
                leadShare.LeadAccessLevel ='edit';
              //leadShare.RowCause=Schema.LeadShare.RowCause.Manual;
                leadList.add(leadShare);
            }
        }
        Database.SaveResult[] leadShareInsertRecord = Database.insert(leadList,false);
    }
    if(trigger.IsUpdate){
        List<LeadShare> leadList = new list<LeadShare>();
        Group g =[select Id, Name from Group where  Type = 'Queue' AND Group.Name='HYDERABAD Login Desk'];
        for(lead currRec : trigger.new )
        {
            if(currRec.Service_Branch__c !=Trigger.oldMap.get(currRec.id).Service_Branch__c && currRec.Service_Branch__c =='HYDERABAD'){
                LeadShare leadShare = new LeadShare();
                leadShare.LeadId = currRec.Id;
                leadShare.UserOrGroupId = g.id;
                leadShare.LeadAccessLevel ='edit';
              //leadShare.RowCause=Schema.LeadShare.RowCause.Manual;
                leadList.add(leadShare);
            }
        }
        Database.SaveResult[] leadShareInsertRecord = Database.insert(leadList,false);
    }
    
    if(trigger.IsUpdate){
        List<LeadShare> leadList = new list<LeadShare>();
        Group g =[select Id, Name from Group where Type = 'Queue' AND Group.Name=:'CHENNAI Login Desk'];
        for(lead currRec : trigger.new )
        {
            if(currRec.Service_Branch__c !=Trigger.oldMap.get(currRec.id).Service_Branch__c && currRec.Service_Branch__c =='CHENNAI'){
                LeadShare leadShare = new LeadShare();
                leadShare.LeadId = currRec.Id;
                leadShare.UserOrGroupId = g.id;
                leadShare.LeadAccessLevel ='edit';
              //leadShare.RowCause=Schema.LeadShare.RowCause.Manual;
                leadList.add(leadShare);
            }
        }
        Database.SaveResult[] leadShareInsertRecord = Database.insert(leadList,false);
    }
    if(trigger.IsUpdate){
        List<LeadShare> leadList = new list<LeadShare>();
        Group g =[select Id, Name from Group where Type = 'Queue' AND Group.Name=:'BENGALURU Login Desk'];
        for(lead currRec : trigger.new )
        {
            if(currRec.Service_Branch__c !=Trigger.oldMap.get(currRec.id).Service_Branch__c && currRec.Service_Branch__c =='BENGALURU'){
                LeadShare leadShare = new LeadShare();
                leadShare.LeadId = currRec.Id;
                leadShare.UserOrGroupId = g.id;
                leadShare.LeadAccessLevel ='edit';
              //leadShare.RowCause=Schema.LeadShare.RowCause.Manual;
                leadList.add(leadShare);
            }
        }
        Database.SaveResult[] leadShareInsertRecord = Database.insert(leadList,false);
    }
    if(trigger.IsUpdate){
        List<LeadShare> leadList = new list<LeadShare>();
        Group g =[select Id, Name from Group where Type = 'Queue' AND Group.Name=:'PUNE Login Desk'];
        for(lead currRec : trigger.new )
        {
            if(currRec.Service_Branch__c !=Trigger.oldMap.get(currRec.id).Service_Branch__c && currRec.Service_Branch__c =='PUNE'){
                LeadShare leadShare = new LeadShare();
                leadShare.LeadId = currRec.Id;
                leadShare.UserOrGroupId = g.id;
                leadShare.LeadAccessLevel ='edit';
              //leadShare.RowCause=Schema.LeadShare.RowCause.Manual;    AHMEDABAD
                leadList.add(leadShare);
            }
        }
        Database.SaveResult[] leadShareInsertRecord = Database.insert(leadList,false);
    }
    if(trigger.IsUpdate){
        List<LeadShare> leadList = new list<LeadShare>();
        Group g =[select Id, Name from Group where Type = 'Queue' AND Group.Name=:'AHMEDABAD Login Desk'];
        for(lead currRec : trigger.new )
        {
            if(currRec.Service_Branch__c !=Trigger.oldMap.get(currRec.id).Service_Branch__c && currRec.Service_Branch__c =='AHMEDABAD'){
                LeadShare leadShare = new LeadShare();
                leadShare.LeadId = currRec.Id;
                leadShare.UserOrGroupId = g.id;
                leadShare.LeadAccessLevel ='edit';
              //leadShare.RowCause=Schema.LeadShare.RowCause.Manual;    
                leadList.add(leadShare);
            }
        }
        Database.SaveResult[] leadShareInsertRecord = Database.insert(leadList,false);
    }
    
}