@isTest
public class SourceTriggerHandlerTest {
    @isTest
    static void testSourceTriggerHandler(){
        integer lenght = 10;
        String oldCategporyValue = '15' ;
        Test.startTest();
        Partner_Naming_Configrations__c customSettingPartnerNamingConfigrations = TestDataFactory.CreatePartnerNamingConfigrationsCustomSetting(true);
        List<Source__c> newlstSource = new List<Source__c>();
        newlstSource.add(TestDataFactory.createSource(False));
        newlstSource.add(TestDataFactory.createSourceWithoutPartner(False));
        Account AccountObj2 = TestDataFactory.createPersonAccount(true);
        Account AccountObj3 = TestDataFactory.createPersonAccount(true);
        Source__c SourceObject = TestDataFactory.createSourceWithoutPartner(true);
        SourceObject.Partner_Name__c =AccountObj2.Id;
        SourceObject.Sub_Source_Type__c ='AI Driven';
        Update SourceObject;
        newlstSource.add(SourceObject);
        Source__c SourceObject2 = TestDataFactory.createSourceWithoutPartner(true);
        SourceObject2.Partner_Name__c =AccountObj3.Id;
        SourceObject2.Sub_Source_Type__c ='AI Driven';
        Update SourceObject2;
        newlstSource.add(SourceObject2);
        SourceTriggerHandler.singleSourceOnAccount(newlstSource);
        SourceTriggerHandler.updateSourceAccountDetailsAsPerConfigration(newlstSource);
        SourceTriggerHandler.generateIncrementedFinalValue(lenght,oldCategporyValue);
        Test.stopTest();      
    }
}