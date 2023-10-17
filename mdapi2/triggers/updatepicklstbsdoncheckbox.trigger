trigger updatepicklstbsdoncheckbox  on Document_Checklist__c (before insert,before update) {

  for(Document_Checklist__c doc :Trigger.new){
      if(doc.Doc_Sub_Type__c=='Aadhar Card' && doc.Is_Aadhar_back_Side_Uploaded__c && doc.Is_Aadhar_Front_Uploaded__c){
         doc.Status__c= 'Accepted';
         doc.IsDocumentComplete__c = true;
      } else if(doc.Doc_Sub_Type__c=='Aadhar Card' &&(!doc .Is_Aadhar_back_Side_Uploaded__c && !doc.Is_Aadhar_Front_Uploaded__c)||(!doc .Is_Aadhar_back_Side_Uploaded__c && doc.Is_Aadhar_Front_Uploaded__c)||(doc .Is_Aadhar_back_Side_Uploaded__c && !doc.Is_Aadhar_Front_Uploaded__c)) {
         doc.Status__c= 'Rejected';
         doc.IsDocumentComplete__c = false;
      }   
      else if(doc.Doc_Sub_Type__c=='Electricity Bill' && doc.Older_Than_One_Year__c && doc.Older_Than_Three_Month__c){
         doc.Status__c= 'Accepted';
         doc.IsDocumentComplete__c = true;
      } else if(doc.Doc_Sub_Type__c=='Electricity Bill' &&(!doc.Older_Than_One_Year__c && !doc.Older_Than_Three_Month__c)||(!doc.Older_Than_One_Year__c && doc.Older_Than_Three_Month__c)||(doc.Older_Than_One_Year__c && !doc.Older_Than_Three_Month__c)) {
         doc.Status__c= 'Rejected';
         doc.IsDocumentComplete__c = false;
      }   
      
      else if(doc.Doc_Sub_Type__c=='PAN Card' && doc.Ensure_that_the_photograph_is_clear__c && doc.Check_the_PAN_card_number__c) {
         doc.Status__c= 'Accepted';
         doc.IsDocumentComplete__c = true;
      }   
      else if(doc.Doc_Sub_Type__c=='PAN Card' &&(!doc.Ensure_that_the_photograph_is_clear__c && !doc.Check_the_PAN_card_number__c)||(!doc.Ensure_that_the_photograph_is_clear__c && doc.Check_the_PAN_card_number__c)||(doc.Ensure_that_the_photograph_is_clear__c && !doc.Check_the_PAN_card_number__c)) {
         doc.Status__c= 'Rejected';
         doc.IsDocumentComplete__c = false;
      }   
      else if(doc.Doc_Sub_Type__c=='Passport' && doc.Passport_Validity_less_than_6_Month__c && doc.Passport_Validity_More_Than_6_Month__c) {
         doc.Status__c= 'Accepted';
         doc.IsDocumentComplete__c = true;
      }   
      else if(doc.Doc_Sub_Type__c=='Passport' &&(!doc.Passport_Validity_less_than_6_Month__c && !doc.Passport_Validity_More_Than_6_Month__c)||(!doc.Passport_Validity_less_than_6_Month__c && doc.Passport_Validity_More_Than_6_Month__c)||(doc.Passport_Validity_less_than_6_Month__c && !doc.Passport_Validity_More_Than_6_Month__c)) {
         doc.Status__c= 'Rejected';
         doc.IsDocumentComplete__c = false;
      }  
      
      else if(doc.Doc_Sub_Type__c=='Driving License' && doc.License_Validity_less_than_3_months__c && doc.License_Validity_less_than_6_Month__c && doc.License_Validity_More_Than_6_Month__c) {
         doc.Status__c= 'Accepted';
         doc.IsDocumentComplete__c = true;
      }   
      else if(doc.Doc_Sub_Type__c=='Driving License' &&(!doc.License_Validity_less_than_3_months__c && !doc.License_Validity_less_than_6_Month__c && !doc.License_Validity_More_Than_6_Month__c)||
              (!doc.License_Validity_less_than_3_months__c && !doc.License_Validity_less_than_6_Month__c && doc.License_Validity_More_Than_6_Month__c)||
              (doc.License_Validity_less_than_3_months__c && !doc.License_Validity_less_than_6_Month__c && !doc.License_Validity_More_Than_6_Month__c)||
              (!doc.License_Validity_less_than_3_months__c && doc.License_Validity_less_than_6_Month__c && !doc.License_Validity_More_Than_6_Month__c))
              {
         doc.Status__c= 'Rejected';
         doc.IsDocumentComplete__c = false;
      }   
   } 
}