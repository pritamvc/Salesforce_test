@IsTest
public class LosUtilsTest {
    @IsTest
    static void testGenerateData() {
        // Create test data
          
        TestDataFactory.createLOSMapData();
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity');
        testOpportunity.StageName = System.Label.Opportunity_Stage_Lead_Convert ;
        testOpportunity.CloseDate = System.today();
        
        insert testOpportunity;
        
        
     /*   LosApiMaster__c testApiMaster = new LosApiMaster__c(ApiName__c = 'Test API');
        insert testApiMaster;
        
        LosApiMap__c testApiMap = new LosApiMap__c(
            LosLable__c = 'Test Label',
            SalesforceLable__c = 'Test Field',
            Default__c = 'Test Default',
            LosDataType__c = 'Test DataType',
            TableName__c = 'Test Table',
            LosApiMaster__c = testApiMaster.Id
        );
        insert testApiMap;*/

        // Call the method with test data
        Map<String, Object> result = LosUtils.generateData(testOpportunity);

        // Assert the expected results
        System.assertEquals('Expected Value', result.get('COUNTRY'));

        
    }
}