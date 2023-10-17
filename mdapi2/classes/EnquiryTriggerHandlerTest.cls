/*********************************************************************************************
 * @author          Sohail Solapure
 * @description     This EnquiryTriggerHandlerTest test class is written for EnquiryTriggerHandler class
 * @date            21 Feb 2023  
**********************************************************************************************/
@isTest
public with sharing class EnquiryTriggerHandlerTest {
    @testSetup 
    static void setup() {
        // Create common test Leads
        List<Lead> leadList = new List<Lead>();

        for(Integer i=0;i<5;i++) {
            Lead l = new Lead();
            l.LastName = 'Test'+i;
            l.Email = 'test@gmail.com';
            l.MobilePhone = '9876543212';
            leadList.add(l);
       }
        insert leadList;        
    }

    //Method to test enquiry trigger
    testMethod public static void testEnquiryTrigger(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        Task t = new Task();
        t.WhoId = l.Id;
        t.Subject = 'Call';
        t.CallDisposition = 'Call Back';
        insert t;
    }

    //Create Task with Disposiiton
    public static Task createTask(String disposition,Lead l){
        Task t = new Task();
        t.WhoId = l.Id;
        t.Subject = 'Call';
        t.CallDisposition = disposition;
        return t;
    }

    //Method to test Call Back disposition
    testMethod public static void testCallBack(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;

        Task t = createTask('Call Back', l);
        insert t;
    }

    //Method to test Call Back disposition
    testMethod public static void testCallBack1(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Sales Processing';
        l.Status__c = 'New';
        update l;

        Task t = createTask('Call Back', l);
        insert t;
    }

    //Method to test Call Back disposition
    testMethod public static void testCallBack2(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Sales Processing';
        l.Status__c = 'Active';
        update l;

        Task t = createTask('Call Back', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testNotInterested(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'Escalated';
        update l;

        Task t = createTask('Customer Denied the Loan ( not interested)', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testFutureProspect(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Future Prospect', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testFutureProspect1(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Sales Processing';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Future Prospect', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testFutureProspect2(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Suspect';
        l.Status__c = 'Contacted';
        update l;
    
        Task t = createTask('Future Prospect', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testFutureProspect3(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Sales Processing';
        l.Status__c = 'Active';
        update l;
    
        Task t = createTask('Future Prospect', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testFutureProspect4(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Sales Processing';
        l.Status__c = 'Escalated';
        update l;
    
        Task t = createTask('Future Prospect', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testInvalid(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Invalid', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testNotDoable(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Not Doable By Auxilo', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testPassive(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Passive Transfer to CEM', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testTriparty(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Sales Processing';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Tri Party Call', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testWilling(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Willing To Apply', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testActive(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Active Transfer to CEM', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testApp(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Applying';
        l.Status__c = 'Active';
        update l;
    
        Task t = createTask('Application Formalities Completed', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testDup(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Duplicate Lead', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testBad(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Bad Call', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testBad1(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Prospect';
        l.Status__c = 'Inactive';
        update l;
    
        Task t = createTask('Bad Call', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testBad2(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Applying';
        l.Status__c = 'Inactive';
        update l;
    
        Task t = createTask('Bad Call', l);
        insert t;
    }

    //Method to test Not interested disposition
    testMethod public static void testReadyToApply(){
        Lead l = [SELECT Id,Status,Status__c from Lead where Name = 'Test0' LIMIT 1];
        l.Status = 'Fresh';
        l.Status__c = 'New';
        update l;
    
        Task t = createTask('Ready to Apply', l);
        insert t;
    }
}