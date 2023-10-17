public with sharing class RedirectTaskController {

    string recordId = '';

    public RedirectTaskController() {
        System.debug(' ################################### ');
        recordId = ApexPages.currentPage().getParameters().get('rId');
        
        System.debug(' ################################### Record Id :: '+recordId);
    }

    public PageReference redirectToTask() {
        System.debug(' &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&  ');
        PageReference activityPage = new PageReference('/' + recordId);

        Task[] recentTasks = [SELECT Id, CreatedDate 
                              FROM Task WHERE WhatId = :recordId 
                              ORDER BY CreatedDate DESC LIMIT 1];

        // Check that the new Task if fairly recent.
        if (recentTasks.Size() == 1 && 
                recentTasks[0].CreatedDate.addHours(1) > Datetime.now()) {
            activityPage = new PageReference('/' + recentTasks[0].Id);
        }

        activityPage.setRedirect(true);
        return activityPage;
    }
}