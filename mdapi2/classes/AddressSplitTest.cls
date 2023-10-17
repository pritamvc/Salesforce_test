@isTest
public class AddressSplitTest {
    @isTest
    public static void testSplitAddress() {
        Test.startTest();
        ContactPointAddress testAddress = TestDataFactory.createContactPointAddress(true);
        ContactPointAddress testAddress1 = TestDataFactory.createContactPointAddress(false);
        testAddress1.Address_1__c = '027, PADAMATI GUDEM, BEERISHETTI GUDEM, Danthalapalle, Dantalapalli, Warangal, Narsimhulapet, Andhra Pradesh, 506324';
        insert testAddress1;
        Test.stopTest();
    }
}