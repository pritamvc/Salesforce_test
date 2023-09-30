/*********************************************************************************************
* @author          Vaibhav Hinge
* @description     This Class used for a Custom validation purpose.
* @date            02 May 2023  
* @testClass:      
**********************************************************************************************/
public class CustomValidationHandler {
    
    /********************************************************************************************************
    * @author          Vaibhav Hinge
    * @description     This method used to apply validation on Analytical Score,Language score and University/Institute/course
    * @param           list<lead> leadList   
    * @date            02 May 2023   
    ********************************************************************************************************/
    public static void customValidationMethod( list<lead> leadList){
        
        
        // Create map with Score_Category as a Key and related data as a value
        Map<String,Analytics_Score_Setting__mdt> analyticsScoreSetting = new  Map<String,Analytics_Score_Setting__mdt>();
        Map<String,Analytical_Score_GRE_Setting__mdt> analyticsScoreGRESetting = new  Map<String,Analytical_Score_GRE_Setting__mdt>();
        Map<String,Language_Score_Setting__mdt> languageScoreSetting = new  Map<String,Language_Score_Setting__mdt>();
        
        // Call method and Get a Analytical and Language Score_Category and related data
        analyticsScoreSetting = getAnalyticalScore();
        analyticsScoreGRESetting = getAnalyticalScoreGRE();
        languageScoreSetting = getLanguageScoreCategory();
        
        //Iterate through the list of Lead 
        for(lead lead :leadList){
            
            //TO check Analytics_Score_Category__c is filled or not
            if(lead.Analytics_Score_Category__c != null){
                //To check Entered Analytics_Score_Category is in the analyticsScoreSetting Collection  or not
                if(lead.Analytics_Score_Category__c != 'NA'){
                if(lead.Analytics_Score_Category__c == analyticsScoreSetting.get(lead.Analytics_Score_Category__c).Analytical_Category__c){
                   // To check entered value is in between the upper and lower range 
                    if((lead.Analytics_Test_Score__c == null)||(analyticsScoreSetting.get(lead.Analytics_Score_Category__c).Start_Range__c > lead.Analytics_Test_Score__c) || ( lead.Analytics_Test_Score__c > analyticsScoreSetting.get(lead.Analytics_Score_Category__c).End_Range__c)){
                      if(analyticsScoreSetting.get(lead.Analytics_Score_Category__c).Error_Message__c != null){
                          //Fetch the error msg from Custom MetaData type
                         lead.Analytics_Test_Score__c.adderror(analyticsScoreSetting.get(lead.Analytics_Score_Category__c).Error_Message__c);
                        }else{
                           lead.Analytics_Test_Score__c.adderror(CommonConstant.ANALYTICS_TEST_SCORE);
                       }   
               		 }  
               	   }
            }
               //To check Entered Analytics_Score_Category is in the analyticsScoreGRESetting Collection  or not
              
                if(analyticsScoreGRESetting.get(lead.Analytics_Score_Category__c) != null) {
                 if(lead.Analytics_Score_Category__c == analyticsScoreGRESetting.get(lead.Analytics_Score_Category__c).Analytical_Category_GRE__c){
                   // To check entered value is in between the upper and lower range 
                    if((lead.Verbal_Score__c==null)||(analyticsScoreGRESetting.get(lead.Analytics_Score_Category__c).Start_Range__c > lead.Verbal_Score__c) || ( lead.Verbal_Score__c > analyticsScoreGRESetting.get(lead.Analytics_Score_Category__c).End_Range__c)){
                           lead.Verbal_Score__c.adderror(analyticsScoreGRESetting.get(lead.Analytics_Score_Category__c).Verbal_score_error_msg__c);
                    }
                    if((lead.Quantitative_Score__c==null)||(analyticsScoreGRESetting.get(lead.Analytics_Score_Category__c).Start_Range__c > lead.Quantitative_Score__c) || ( lead.Quantitative_Score__c > analyticsScoreGRESetting.get(lead.Analytics_Score_Category__c).End_Range__c)){
                           lead.Quantitative_Score__c.adderror(analyticsScoreGRESetting.get(lead.Analytics_Score_Category__c).Quantitative_score_error_msg__c);
                    }
                 }     
                }
            }
            
            //TO check Language_Score_Category__c is filled or not
            if(lead.Language_Score_Category__c != null){
                 // To check entered value is in between the upper and lower range
                if(lead.Language_Score_Category__c != 'NA'){
                      if((lead.Language_Test_Score__c == null)||(languageScoreSetting.get(lead.Language_Score_Category__c).Start_Range__c > lead.Language_Test_Score__c) || ( lead.Language_Test_Score__c > languageScoreSetting.get(lead.Language_Score_Category__c).End_Range__c)){
                      if(languageScoreSetting.get(lead.Language_Score_Category__c).Error_Message__c != null){
                         lead.Language_Test_Score__c.adderror(languageScoreSetting.get(lead.Language_Score_Category__c).Error_Message__c);
                       }else{
                           lead.Language_Test_Score__c.adderror(CommonConstant.LANGUAGE_TEST_SCORE);
                    }       
            	  }    	  
                }
              }    
        }
    }
     /********************************************************************************************************
    * @author          Vaibhav Hinge
    * @description     This method create a map of Analytical_Category__c having mand field is Analytics_Test_Score__c
    * @return           Map<String,Analytics_Score_Setting__mdt>   
    * @date            02 May 2023   
    ********************************************************************************************************/
     public static Map<String,Analytics_Score_Setting__mdt> getAnalyticalScore(){  
        //create a custom metadata list
        list<Analytics_Score_Setting__mdt> analyticsScore  = new list<Analytics_Score_Setting__mdt>();
        analyticsScore =[SELECT id,Analytical_Category__c,End_Range__c,Start_Range__c,Error_Message__c FROM Analytics_Score_Setting__mdt];
        
        Map<String,Analytics_Score_Setting__mdt> analyticsScoreObject = new  Map<String,Analytics_Score_Setting__mdt>();   
        //Iterate through the list of Analytics_Score_Setting custom MetaData
        for(Analytics_Score_Setting__mdt analyticsScoreSetting: analyticsScore){
            //Create a map collection and save the value Analytical_Category__c as a key and total data as a value
              analyticsScoreObject.put(analyticsScoreSetting.Analytical_Category__c,analyticsScoreSetting);
        }        
        return analyticsScoreObject;
    }
     /********************************************************************************************************
    * @author          Vaibhav Hinge
    * @description     This method create a map of Analytical_Category__c having mand field is Analytics_Test_Score__c
    * @return          Map<String,Analytical_Score_GRE_Setting__mdt> getAnalyticalScoreGRE()  
    * @date            02 May 2023   
    ********************************************************************************************************/ 
     public static Map<String,Analytical_Score_GRE_Setting__mdt> getAnalyticalScoreGRE(){        
        //create a custom metadata list
         list<Analytical_Score_GRE_Setting__mdt> analyticsScore  = new list<Analytical_Score_GRE_Setting__mdt>();
        analyticsScore =[SELECT id,Analytical_Category_GRE__c,End_Range__c,Start_Range__c,Verbal_score_error_msg__c,Quantitative_score_error_msg__c FROM Analytical_Score_GRE_Setting__mdt];
        
        Map<String,Analytical_Score_GRE_Setting__mdt> analyticsScoreGREObject = new  Map<String,Analytical_Score_GRE_Setting__mdt>();       
        //Iterate through the list of Analytical_Score_GRE_Setting__mdt custom MetaData
         for(Analytical_Score_GRE_Setting__mdt analyticsScoreSetting: analyticsScore){				 
              analyticsScoreGREObject.put(analyticsScoreSetting.Analytical_Category_GRE__c,analyticsScoreSetting);
        }        
        return analyticsScoreGREObject;
    }
     /********************************************************************************************************
    * @author          Vaibhav Hinge
    * @description     This method create a map of Language Score Category having mand field is Language Test Score
    * @return          Map<String,Language_Score_Setting__mdt> getLanguageScoreCategory()  
    * @date            02 May 2023   
    ********************************************************************************************************/     
     public static Map<String,Language_Score_Setting__mdt> getLanguageScoreCategory(){        
        //create a custom metadata list
         list<Language_Score_Setting__mdt> languageScore  = new list<Language_Score_Setting__mdt>();
        languageScore =[SELECT id,Language_Category__c,End_Range__c,Start_Range__c,Error_Message__c FROM Language_Score_Setting__mdt];
        
        Map<String,Language_Score_Setting__mdt> languageScoreGREObject = new  Map<String,Language_Score_Setting__mdt>(); 
         //Iterate through the list of Language_Score_Setting__mdt custom MetaData
        for(Language_Score_Setting__mdt languageScoreSetting: languageScore){				 
              languageScoreGREObject.put(languageScoreSetting.Language_Category__c,languageScoreSetting);
        }        
        return languageScoreGREObject;
    }
}