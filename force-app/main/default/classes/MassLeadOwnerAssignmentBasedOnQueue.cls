public class MassLeadOwnerAssignmentBasedOnQueue {
    
      public List<Lead> getIDs;
    public String accIds{get;set;}    
    public MassLeadOwnerAssignmentBasedOnQueue(ApexPages.StandardSetController controller){
        System.debug('Get Selected');
        getIDs = controller.getSelected();
        accIds = '';  
        for(Lead acc : getIDs){
            accIds += acc.Id + ','; 
        }
        accIds = accIds.removeEnd(','); 
        System.debug('Account ID : '+accIds);
    } 

}