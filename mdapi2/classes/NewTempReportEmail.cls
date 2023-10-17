public class NewTempReportEmail {
    public static void sendReport1() {
    Id managerRoleId = [SELECT Id FROM UserRole WHERE Name = :CommonConstant.CREDIT_MANAGER AND ParentRoleId != null LIMIT 1].Id;
        system.debug('Id '+ managerRoleId);
        List<User> groupMembers = [SELECT Id, Name, Email FROM User WHERE UserRoleId = :managerRoleId];
         system.debug('list '+ groupMembers);
        List<String> emailIds = new List<String>();
        for (User member : groupMembers) {
            emailIds.add(member.Email);
        }
        system.debug('Email Id'+emailIds);
    }
}