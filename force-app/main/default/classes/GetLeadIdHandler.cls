public class GetLeadIdHandler {
    @AuraEnabled(cacheable=true)
    public static Account getLeadDetails(Id recordId) {
        system.debug('recordId    ###'+recordId);
        List<Account> lstLead = [SELECT Id, Name FROM Account WHERE Id = :recordId];
         system.debug('lstLead  ######'+lstLead[0]);
        return lstLead[0];
    }
    @AuraEnabled
     public static void updateLead(String leadId, String firstName,  String email) {
         // Lead lead = new Lead();
         Account lead =new Account();
          lead.Id = leadId;
          lead.FirstName = firstName;
         // lead.Email = email;
  
          Database.SaveResult result = Database.update(lead);
  
          if (result.isSuccess()) {
              // Record updated successfully
          } else {
              // Handle the errors
              for(Database.Error error : result.getErrors()) {
                  String message = 'Error updating record: ' + error.getStatusCode() + ' - ' + error.getMessage();
                  System.debug(message);
                  // You can throw an exception or return an error message to the client here
              }
          }
      }
}