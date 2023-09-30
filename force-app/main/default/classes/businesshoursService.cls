/*********************************************************************************************
* @author          Thinqloud Solutions (Vaibhav Hinge)
* @description     This class is used for update datetime fields within the businessHours for no action flows in dispositions
* @date            27/04/2023 (April,2023)    
* @testClass:  
**********************************************************************************************/
public class BusinesshoursService 
{
    @testvisible  Public static BusinessHours defaultBH
    {
        // getter method for the "defaultBH" property
        get 
        {
            //checks if "defaultBH" is null
            If(defaultBH == null)
                //ID of the business hours named "Auxilo Business Hours"
                defaultBH = [SELECT Id FROM BusinessHours WHERE Name ='Auxilo Bussiness Hours']; 
            return defaultBH;
        }
        // sets "defaultBH" to the queried value
        private set;
    }
    public static dateTime getesclatetime(dateTime currentTime,integer esclateTimeMin)
    {
        //businessHours To set Id,Current Time and Minute to convert it from minutes to milliseconds.
        return businessHours.add(defaultBH.id,currentTime,esclateTimeMin*60*1000L);
    }
}