@IsTest
public class RecommendedtoCMTest {
   @IsTest
	static void testGetRecommendedToCMField() {
    // Create test data
    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opportunity';
    opp.StageName = 'Prospecting';
    opp.CloseDate = Date.today(); // Set a valid CloseDate
    insert opp;
    List<String> dealIds = new List<String>();
    dealIds.add(opp.Id);
    // Invoke the method being tested
    List<RecommendedtoCM.DealWrapper> dealWrappers = RecommendedtoCM.getRecommendedToCMField(dealIds);
}


    @IsTest
    static void testGetRecommendedToCMFieldNullFields() {
        // Create test data with a null field
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today();
        insert opp;
        List<String> dealIds = new List<String>();
        dealIds.add(opp.Id);
        // Invoke the method being tested
        List<RecommendedtoCM.DealWrapper> dealWrappers = RecommendedtoCM.getRecommendedToCMField(dealIds);
    }
}