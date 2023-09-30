/**
* @author      : Thinqloud Solutions (Rahul Shukla)
* @description : This Class called in ApplicantPDFGenerator,this class used to Fetch Values from different Object and display on PDF.
* @date        : 22/06/2023    
* @testClass:  : ApplicantPDFGeneratorTest
*/
public class ApplicantPDFGenerator {
    
    public List<Lead> leadData { get; set; } //list of lead records associated with the loan application
    public list<lead>leadRecord{get;set;} //The list of lead records associated with the loan application.
    public List<Co_Applicant__c> applicantRecd { get; set; }//list of lead records for co-applicants associated with the loan application
    public List<Demography__c> demography { get; set; }//The list of demography records associated with the loan application
    public List<ContactPointAddress> addressCurrent { get; set; }//The list of current contact point addresses associated with the loan application.
    public List<ContactPointAddress> addressPermt { get; set; }//The list of permanent contact point addresses associated with the loan application
    public List<ContactPointAddress> officeAddress { get; set; }//The list of office contact point addresses associated with the loan application
    public List<Education_Details__c> educationRecrds { get; set; }//The list of education details records associated with the loan application.
    public List<Employment_Details__c> appEmploymentRecrd { get; set; }//The list of employment details records associated with the loan application.
    public List<Asset> appAsset { get; set; }//The list of asset records associated with the loan application.
    public List<Liability__c> appLiabilities { get; set; }//The list of liability records associated with the loan application.
    public List<Reference__c> appReference { get; set; }//The list of reference records associated with the loan application.
    
    public list<Asset> appCollateral{get;set;}//The list of Asset records associated with the loan application.
    public list<Bank_Details__c> appBankDetail{get;set;}//The list of Bank Detail records associated with the loan application
    public String leadid {get;set;}//The unique identifier for the lead associated with the loan application.
    public Set<String> filesDownloadURL {set;get;}//The set of download URLs for files related to the loan application for Applicant Photo.
    public Set<String> filesCoAppDownloadURL {set;get;}//The set of download URLs for files related to co-applicants in the loan application.
    public List<WrpLoanApplicationForm> lstWrpLoanApplicationForm  {set;get;}//The list of loan application form records associated with the loan application.
    public Map<Id,Demography__c> mapAppvsDemography {get; set;}// The mapping of application IDs to demography records for the loan application.
    public Map<Id,Co_Applicant__c> mapAppvsCoApp {get; set;}//The mapping of application IDs to co-applicant records for the loan application.
    public Map<Id,Employment_Details__c> mapAppvsEmployment {get; set;}//The mapping of application IDs to employment details records for the loan application.
    public Map<Id,ContactPointAddress> mapAppvsAddressCurrent {get; set;}//The mapping of application IDs to current contact point addresses for the loan application.
    public Map<Id,ContactPointAddress> mapAppvsAddressPermt {get; set;}//The mapping of application IDs to permanent contact point addresses for the loan application.
    public Map<Id,ContactPointAddress> mapAppvsOfficeaddress {get; set;}//The mapping of application IDs to office contact point addresses for the loan application.
    public Map<Id,List<Bank_Details__c>> mapAppvsBankDetails {get; set;}//The mapping of application IDs to lists of bank details records for the loan application.
    public Map<Id,List<Asset>> mapAppvsAsset {get; set;}//The mapping of application IDs to lists of asset records for the loan application.
    public Map<Id,List<Asset>> mapAppvsCollateral {get; set;}//The mapping of application IDs to lists of collateral asset records for the loan application.
    public Map<Id,List<Liability__c>> mapAppvsLiabilities {get; set;}//The mapping of application IDs to lists of liability records for the loan application
    public Map<Id,Reference__c> mapAppvsReferences {get; set;}//The mapping of application IDs to reference records for the loan application.
    public Map<Id,String> mapAccountPhoto {get; set;}//The mapping of application IDs to account photo URLs for the loan application.
    
    
    /**
* Constructs an instance of the ApplicantPDFGenerator class.
* @param : Controller The standard controller for the page that the PDF is being generated for.
* @description: This class is responsible for generating a PDF document containing applicant details.
*/
    public ApplicantPDFGenerator(ApexPages.StandardController Controller) {
        // Initializing variables and collections
        lstWrpLoanApplicationForm = new List<WrpLoanApplicationForm>();
        mapAppvsDemography = new Map<Id,Demography__c>();
        mapAccountPhoto = new Map<Id,String>();
        mapAppvsCoApp = new Map<Id,Co_Applicant__c>();
        mapAppvsEmployment = new Map<Id,Employment_Details__c>();
        mapAppvsAddressPermt = new Map<Id,ContactPointAddress>();
        mapAppvsAddressCurrent = new Map<Id,ContactPointAddress>();
        mapAppvsOfficeaddress = new Map<Id,ContactPointAddress>();
        mapAppvsAsset = new Map<Id,List<Asset>>();
        mapAppvsCollateral = new Map<Id,List<Asset>>();
        mapAppvsLiabilities = new Map<Id,List<Liability__c>>();
        mapAppvsReferences = new Map<Id,Reference__c>();
        mapAppvsBankDetails =new Map<Id,List<Bank_Details__c>>();
        appEmploymentRecrd =new List<Employment_Details__c>();
        appAsset = new List<Asset>();
        appLiabilities = new List<Liability__c>();
        appReference = new List<Reference__c>();
        filesCoAppDownloadURL =new Set<String>();
        appCollateral= new list<Asset>();
        appBankDetail = new list<Bank_Details__c>();
        
        List<Document_Checklist__c> docList = new List<Document_Checklist__c>();
        
        List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();
        try{
            // Retrieve the Lead record associated with the controller
            Lead l = (Lead)controller.getRecord();
            leadid = l.Id;
            
            // Retrieve the Lead record again to get the name
            Lead leadData = [SELECT Id, Name FROM Lead WHERE Id = :leadid LIMIT 1];
            String leadName = leadData.Name;
            // Set the desired file name for the generated PDF
            String myGeneratedFileName = leadName+'-Loan Application Form.pdf';
            // Set the 'content-disposition' header to specify the file name when downloaded
            Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+myGeneratedFileName);
            
            // Query Document_Checklist__c records related to the Lead and specific criteria
            
            docList = [select id, Applicant_Name__c, Lead__c, Applicant_Type__c, Doc_Sub_Type__c, 
                       Applicant__r.Account__c from Document_Checklist__c where 
                       Lead__c = :leadid AND Applicant__r.Type__c = 'Applicant'
                       AND Doc_Sub_Type__c = 'Photo' ];
            
            if(docList.size() > 0){
                cdLinks =[Select id,ContentDocument.LatestPublishedVersionID from 
                          ContentDocumentLink where LinkedEntityId=:docList[0].Id ORDER BY SystemModstamp DESC LIMIT 1 ];
            }
            // Generate the download URLs for the files associated with the ContentDocumentLink records
            filesDownloadURL =new Set<String>();
            for(ContentDocumentLink cdl: cdLinks){
                filesDownloadURL.add(URL.getSalesforceBaseUrl().toExternalForm() +'/sfc/servlet.shepherd/version/download/'+cdl.ContentDocument.LatestPublishedVersionID);
            }
            
            // Assuming you have Attachments
            
            List<Attachment> attachmentLink = [Select id from Attachment where ParentId=:leadid ];
            
            for(Attachment recattmt: attachmentLink){
                filesDownloadURL.add(URL.getSalesforceBaseUrl().toExternalForm() +'/servlet/servlet.FileDownload?file='+recattmt.Id);
            }
            
            coapplicantDetails(leadid);// Retrieving co-applicant details
            leadDetails(leadid);// Retrieving lead details
            educationDetails(leadid);// Retrieving education details
            employmentDetails(leadid);// Retrieving employment details
            bankAccountDetails(leadid);// Retrieving bank account details
            assetsDetails(leadid);// Retrieving asset details
            liabilityDetails(leadid);// Retrieving liability details
            collateralDetails(leadid);// Retrieving collateral details
            referenceDetails(leadid);// Retrieving reference details
            
            
            
            // Populating the loan application form objects
            for(Co_Applicant__c recCoApp: mapAppvsCoApp.Values()){
                WrpLoanApplicationForm objWrpLoanApplicationForm = new WrpLoanApplicationForm();
                objWrpLoanApplicationForm.objCoAppicant = recCoApp;
                // Populating demography details if available
                if (mapAppvsDemography.containsKey(recCoApp.Account__c) && mapAppvsDemography.get(recCoApp.Account__c) != null) {
                    objWrpLoanApplicationForm.objDemography = mapAppvsDemography.get(recCoApp.Account__c);
                }
                if (mapAccountPhoto.containsKey(recCoApp.Account__c) && mapAccountPhoto.get(recCoApp.Account__c) != null) {
                    
                    objWrpLoanApplicationForm.cPhotolink = mapAccountPhoto.get(recCoApp.Account__c);
                }
                
                // Populating employment details if available
                if (mapAppvsEmployment.containsKey(recCoApp.Account__c) && mapAppvsEmployment.get(recCoApp.Account__c) != null) {
                    
                    objWrpLoanApplicationForm.objEmployment = mapAppvsEmployment.get(recCoApp.Account__c);
                }
                // Populating current address details if available
                if (mapAppvsAddressCurrent.containsKey(recCoApp.Account__c) && mapAppvsAddressCurrent.get(recCoApp.Account__c) != null) {
                    objWrpLoanApplicationForm.objAddressCurrent = mapAppvsAddressCurrent.get(recCoApp.Account__c);
                }
                // Populating permanent address details if available
                if (mapAppvsAddressPermt.containsKey(recCoApp.Account__c) && mapAppvsAddressPermt.get(recCoApp.Account__c) != null) {  
                    objWrpLoanApplicationForm.objAddressPermt = mapAppvsAddressPermt.get(recCoApp.Account__c);
                }
                // Populating office address details if available
                if (mapAppvsOfficeaddress.containsKey(recCoApp.Account__c) && mapAppvsOfficeaddress.get(recCoApp.Account__c) != null) {
                    objWrpLoanApplicationForm.objOfficeaddress = mapAppvsOfficeaddress.get(recCoApp.Account__c);
                }
                // Populating bank details if available
                if (mapAppvsBankDetails.containsKey(recCoApp.Account__c) && mapAppvsBankDetails.get(recCoApp.Account__c) != null) {
                    objWrpLoanApplicationForm.objBankDetails = mapAppvsBankDetails.get(recCoApp.Account__c);
                }
                // Populating asset details if available
                if (mapAppvsAsset.containsKey(recCoApp.Account__c) && mapAppvsAsset.get(recCoApp.Account__c) != null) {
                    objWrpLoanApplicationForm.objAsset = mapAppvsAsset.get(recCoApp.Account__c);
                }
                // Populating Collateral details if available
                if (mapAppvsCollateral.containsKey(recCoApp.Account__c) && mapAppvsCollateral.get(recCoApp.Account__c) != null) {
                    objWrpLoanApplicationForm.objCollateral = mapAppvsCollateral.get(recCoApp.Account__c);
                }
                // Populating Liabilities details if available
                if (mapAppvsLiabilities.containsKey(recCoApp.Account__c) && mapAppvsLiabilities.get(recCoApp.Account__c) != null) {
                    objWrpLoanApplicationForm.objLiabilities = mapAppvsLiabilities.get(recCoApp.Account__c);
                }
                // Populating reference details if available
                if (mapAppvsReferences.containsKey(recCoApp.Account__c) && mapAppvsReferences.get(recCoApp.Account__c) != null) {
                    objWrpLoanApplicationForm.objReferences = mapAppvsReferences.get(recCoApp.Account__c);
                }
                lstWrpLoanApplicationForm.add(objWrpLoanApplicationForm);
            }
            applicantDetails(leadid);
            
        } 
        
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
    }
    
    
    
    
    /**
* @author : Rahul Shukla
* @description : ApplicantDetails method used to retrieves applicant details associated with the given lead ID. 
* @param      : leadid The ID of the lead associated with the applicant.  
* @date       : 22/06/2023   
*/
    public void applicantDetails(String leadid){
        
        try{
            applicantRecd=[select Lead__r.Intake__c,Name,Is_Income_Considered_Financial__c,Account__c,Account__r.PersonMobilePhone,Account__r.Mobile_Abroad__c,Account__r.NREG_Number__c,Account__r.Driving_License_Number__c,Account__r.Voter_ID__c,Account__r.CKYC_Number__c,Account__r.Name,Account__r.Passport_File_Number__c,Account__r.Passport_Number__c,Account__r.LastName,Account__r.Aadhar_Number__c,Account__r.PAN_Number__c,Account__r.Date_of_Birth__c,Account__r.MiddleName,Account__r.PersonEmail, Account__r.Gender__c, Account__r.Marital_Status__c,Account__r.Salutation,Account__r.FirstName from Co_Applicant__c where Type__c ='Applicant' and Lead__c=:leadid limit 1];
            demography=[select S_TITLE__c, M_TITLE__c, F_TITLE__c, Spouse_s_First_Name__c,Spouse_s_Middle_name__c,Spouse_s_Last_Name__c,Father_s_First_Name__c,Father_s_Last_Name__c, Father_s_Middle_Name__c,Mother_s_First_Name__c,Mother_s_Last_Name__c,Mother_s_Middle_Name__c,Account__c from Demography__c where Account__c=: applicantRecd[0].Account__c and Lead__c=:leadid order by LastModifiedDate desc limit 1];
            addressCurrent=[SELECT Years_In_The_Address__c,Account__c,Pin_Code__r.Name,Address_1__c,State__c,State,Street,City,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c, Country,City__c,  Landmark__c,Country__c,AddressType FROM ContactPointAddress where Address_Type__c='Current Address' and Account__c=:applicantRecd[0].Account__c and Lead__c=:leadid Limit 1];
            
            addressPermt=[SELECT Account__c,Pin_Code__r.Name,Address_1__c,Same_as_Current_Address__c,State__c,State,Street,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c, City__c,  Landmark__c,Country,Country__c,AddressType,Is_Communication_address__c,   Years_In_The_Address__c FROM ContactPointAddress where Address_Type__c='Permanent Address' and Account__c=:applicantRecd[0].Account__c and Lead__c=:leadid Limit 1];
            
            officeAddress=[SELECT Account__c,Address_1__c,Pin_Code__r.Name,State,State__c,Street,City,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c,  City__c,Country,  Landmark__c,Country__c,Address_Type__c FROM ContactPointAddress where Address_Type__c='Office' and Account__c=:applicantRecd[0].Account__c and Lead__c=:leadid Limit 1];
            
            if(mapAppvsEmployment.containskey(applicantRecd[0].Account__c) && mapAppvsEmployment.get(applicantRecd[0].Account__c) !=null){
                Employment_Details__c objEmployment = mapAppvsEmployment.get(applicantRecd[0].Account__c);
                appEmploymentRecrd.add(objEmployment);
            }
            if(mapAppvsAsset.containskey(applicantRecd[0].Account__c) && mapAppvsAsset.get(applicantRecd[0].Account__c) !=null){
                appAsset = mapAppvsAsset.get(applicantRecd[0].Account__c);
            }
            if(mapAppvsCollateral.containskey(applicantRecd[0].Account__c) && mapAppvsCollateral.get(applicantRecd[0].Account__c) !=null){
                appCollateral = mapAppvsCollateral.get(applicantRecd[0].Account__c);
            }
            if(mapAppvsReferences.containskey(applicantRecd[0].Account__c) && mapAppvsReferences.get(applicantRecd[0].Account__c) !=null){
                Reference__c objReference = mapAppvsReferences.get(applicantRecd[0].Account__c);
                appReference.add(objReference );
            }
            if(mapAppvsBankDetails.containskey(applicantRecd[0].Account__c) && mapAppvsBankDetails.get(applicantRecd[0].Account__c) !=null){
                appBankDetail = mapAppvsBankDetails.get(applicantRecd[0].Account__c);
            }
            if(mapAppvsLiabilities.containskey(applicantRecd[0].Account__c) && mapAppvsLiabilities.get(applicantRecd[0].Account__c) !=null){
                appLiabilities = mapAppvsLiabilities.get(applicantRecd[0].Account__c);
            }
        } 
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
        
    }
    /**
* @author : Rahul Shukla
* @description: CoApplicantDetails method used to Retrieves Co-applicant/Gaurantor details associated with the given lead ID. 
* @param:  leadid The ID of the lead associated with the co-applicant details.  
* @date  : 22/06/2023   
*/
    
    public void coApplicantDetails(String leadid){
        
        try{
            List<ContentDocumentLink> cdcoAppLinks = new List<ContentDocumentLink>();
            List<Document_Checklist__c> doccoAppList = new List<Document_Checklist__c>();        
            
            
            Set<id> coappAccountid=new Set<id>();
            Set<id> coappid=new Set<id>();
            List<Co_Applicant__c> coapplicantRecd=[select Id,QUALIFICATION__c,Is_Income_Considered_Financial__c,Account__r.PersonMobilePhone,Account__r.Mobile_Abroad__c,Type__c,Relationship_Proof__c,Relation_with_applicant__c,Date_of_Birth__c,Account__c,Account__r.NREG_Number__c,Account__r.Driving_License_Number__c,Account__r.Voter_ID__c,Account__r.CKYC_Number__c,Account__r.Name,Account__r.Passport_File_Number__c,Account__r.Aadhar_Number__c,Account__r.Passport_Number__c,Account__r.PAN_Number__c,Account__r.Date_of_Birth__c,Account__r.MiddleName,Account__r.LastName,Account__r.PersonEmail, Account__r.Gender__c, Account__r.Marital_Status__c,Account__r.Salutation,Account__r.FirstName from Co_Applicant__c where (Type__c =:CommonConstant.COAPPLICANT OR Type__c = 'Guarantor') AND Lead__c=:leadid];
            
            for(Co_Applicant__c objCoApp: coapplicantRecd){
                mapAppvsCoApp.put(objCoApp.Account__c,objCoApp); 
                coappAccountid.add(objCoApp.Account__c);
                coappid.add(objCoApp.id);
            }
            
            doccoAppList = [select id, Applicant_Name__c, Lead__c, Applicant_Type__c, Doc_Sub_Type__c,
                            Applicant__r.Account__c from Document_Checklist__c where 
                            Lead__c = :leadid  AND (Applicant__r.Type__c = 'CoApplicant' OR Applicant__r.Type__c = 'Guarantor')
                            AND Doc_Sub_Type__c = 'Photo'];
            Map<Id,Id> mapAppvsChecklist =new Map<Id,Id>();
            Set<Id> docAccount=new Set<Id>();
            if(doccoAppList.size() > 0){
                
                for(Document_Checklist__c dc: doccoAppList){
                    mapAppvsChecklist.put(dc.id, dc.Applicant__r.Account__c);
                    docAccount.add(dc.Id);
                }
                
                cdcoAppLinks =[Select id,ContentDocument.LatestPublishedVersionID,LinkedEntityId from 
                               ContentDocumentLink where LinkedEntityId=:docAccount ORDER BY SystemModstamp DESC];
                
            }
            
            for(ContentDocumentLink coAppcdl: cdcoAppLinks){
                if(mapAppvsChecklist.containsKey(coAppcdl.LinkedEntityId)){
                    String cURLlink=URL.getSalesforceBaseUrl().toExternalForm() +'/sfc/servlet.shepherd/version/download/'+coAppcdl.ContentDocument.LatestPublishedVersionID;
                    mapAccountPhoto.put(mapAppvsChecklist.get(coAppcdl.LinkedEntityId),cURLlink);
                }
            }    
            officeAddress=[SELECT Account__c,Address_1__c,Pin_Code__r.Name,State,State__c,Street,City,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c,  City__c,Country,  Landmark__c,Country__c,Address_Type__c FROM ContactPointAddress where Address_Type__c='Office' and Account__c=:coappAccountid and Lead__c=:leadid ];
            for(ContactPointAddress objCur: officeAddress){       
                mapAppvsOfficeaddress.put(objCur.Account__c,objCur);    
            }
            
            demography=[select F_TITLE__c, M_TITLE__c, Spouse_s_First_Name__c,Spouse_s_Middle_name__c,Spouse_s_Last_Name__c,Father_s_First_Name__c,Father_s_Last_Name__c, Father_s_Middle_Name__c,Mother_s_First_Name__c,Mother_s_Last_Name__c,Mother_s_Middle_Name__c,Account__c from Demography__c where Account__c=: coappAccountid and Lead__c=:leadid];
            for(Demography__c objDemo: demography){
                mapAppvsDemography.put(objDemo.Account__c,objDemo);    
            }
            List<ContactPointAddress> coaddressCurrent=[SELECT Account__c,Country,Address_1__c,Pin_Code__r.Name,State__c,State,Street,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c,  City__c,  Landmark__c,Country__c,AddressType,   Years_In_The_Address__c FROM ContactPointAddress where Address_Type__c='Current Address' and Account__c in:mapAppvsCoApp.keyset()and Lead__c=:leadid];
            for(ContactPointAddress objCur: coaddressCurrent){
                mapAppvsAddressCurrent.put(objCur.Account__c,objCur);    
            }
            
            List<ContactPointAddress>coaddressPermt=[SELECT Account__c,Same_as_Current_Address__c,Pin_Code__r.Name,State__c,Address_1__c,State,Street,City,District__c,Address,Address_Proof__c,Pin_Code__c,Taluka__c,  City__c,  Landmark__c,Country,Country__c,AddressType,Is_Communication_address__c,   Years_In_The_Address__c FROM ContactPointAddress where Address_Type__c='Permanent Address' and Account__c in:mapAppvsCoApp.keyset() and Lead__c=:leadid];
            for(ContactPointAddress objCur: coaddressPermt){
                mapAppvsAddressPermt.put(objCur.Account__c,objCur);    
            }
        } 
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
        
    }  
    /**
* @author : Rahul Shukla
* @description: educationDetails this method used to retrieves education details associated with the given lead ID.
* @param : leadid The ID of the lead associated with the education details.  
* @date :  22/06/2023   
*/
    public void educationDetails(String leadid){ 
        try{
            educationRecrds = [select School_College_University__c,Account__c,CGPA__c,Year_Completed__c,Course_Start_Date__c,
                               Education_Qualification__c,Percentage_Marks_CGPA__c,Course_Name__c,University_Name__c,Course_Stream__c
                               from Education_Details__c where Lead__c=:leadid];
        }
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
        
        
    }
    /**
* @author :Rahul Shukla
* @description: employmentDetails this method used to retrieves employment details associated with the given lead ID.
* @param: leadid The ID of the lead for which employment details are to be retrieved.
* @date  :22/06/2023   
*/
    public void employmentDetails(String leadid){ 
        try{
            List<Employment_Details__c>  employmentRecrd = [SELECT Account__c, Account__r.Name,Account__r.Type__c,Total_Professional_Experience__c,No_of_Years_with_Current_Employer__c,Role_In_Organization__c,
                                                            Employment_Type__c,NatureofProfession__c,Membership_Number__c,Name_Of_The_Company__c,    
                                                            Type_Of_Company__c,GST_IN__c,Monthly_Income__c,NatureofBusiness__c,Date_of_Retirement__c,Organisation_Name__c,Sector__c,
                                                            Pension_Amount__c,
                                                            Official_Email_Id__c from Employment_Details__c where Lead__c=:leadid];
            for(Employment_Details__c recEmp: employmentRecrd){
                mapAppvsEmployment.put(recEmp.Account__c,recEmp);    
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
    }
    /**
* @author : Rahul Shukla
* @description : leadDetails this method used retrieves lead details based on the provided lead ID.   
* @param :  leadid The ID of the lead for which lead details are to be retrieved.
* @date :  22/06/2023   
*/
    public void leadDetails(String leadid){
        try{
            leadRecord = [SELECT University_Name__r.Name,Institute_Name__r.Name,Country_of_Study__c,Other_Costs__c,Admission_Status__c,
                          Analytics_Score_Category__c, Quantitative_Score__c,Verbal_Score__c,   Analytics_Test_Score__c,    
                          Language_Score_Category__c,Language_Test_Score__c,    Course_Name_Lookup__c,  
                          Institute_Name__c,Course_Level__c,  Course_Sub_Stream__c,  Course_Type__c, Course_Stream__c,   
                          Course_Start_Date__c,Course_End_Date__c,Course_Duration_Months__c,  University_Name__c, Campus__c,  
                          Course_Category__c,Living_Hostel_Food_Expenses__c, Tuition_Fees__c,
                          Traveling_Expenses__c,Total_Costs__c,Own_Source__c,Scholarship__c, Intake__c,   
                          Others_Fund__c,Total_Funds__c, Loan_Required_A_B__c from Lead where id=:leadid limit 1 ];
        }
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
        
    }
    /**
* @author : Rahul Shukla
* @description : Retrieves and stores Bank details for the loan application associated with the given lead ID.
* @param :  leadid The ID of the lead for which lead details are to be retrieved. 
* @date  : 22/06/2023   
*/
    
    public void bankAccountDetails(String leadid){ 
        try{
            list<Bank_Details__c> bankAccountRecrd = [SELECT  Account__c, Account__r.Name,Account_Holder_Name__c, Bank_Branch_IFSC__c,    
                                                      Bank_Branch_IFSC__r.Name,Bank_Name__c,  IFSC_Code__c,MICR_Code__c,  
                                                      Account_Number__c,  Account_Type__c,
                                                      Account_Operational_Since__c from Bank_Details__c where Lead__c=:leadid];
            
            for(Bank_Details__c objBankDetail: bankAccountRecrd){
                
                if (mapAppvsBankDetails.containsKey(objBankDetail.Account__c)){
                    mapAppvsBankDetails.get(objBankDetail.Account__c).add(objBankDetail);  
                }else{
                    mapAppvsBankDetails.put(objBankDetail.Account__c, new List<Bank_Details__c> {objBankDetail});  
                }
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
    }
    /**
* @author : Rahul Shukla
* @description : Retrieves and stores asset details for the loan application associated with the given lead ID.
* @param : leadid The ID of the lead for which lead details are to be retrieved.    
* @date : 22/06/2023   
*/
    public void assetsDetails(String leadid){ 
        try{
            list<Asset> assetRecrd = [SELECT Lead__c,AccountId, Account.Name,Asset_Type__c,Pin_Code__c,Pin_Code__r.Name,Asset_Value__c,Security_Offered__c,    
                                      Description from Asset where Lead__c=:leadid AND Security_Offered__c!='Yes'];
            for(Asset objAssetDetail: assetRecrd){
                
                if (mapAppvsAsset.containsKey(objAssetDetail.AccountId)){
                    List<Asset> lstAss= mapAppvsAsset.get(objAssetDetail.AccountId);
                    lstAss.add(objAssetDetail);
                    mapAppvsAsset.put(objAssetDetail.AccountId, lstAss); 
                }else{
                    mapAppvsAsset.put(objAssetDetail.AccountId, new List<Asset> {objAssetDetail});  
                }
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
    }
    
    /**
* @author : Rahul Shukla
* @description: Retrieves and stores liability details for the loan application associated with the given lead ID.
* @param : leadid The ID of the lead for which lead details are to be retrieved.    
* @date : 22/06/2023   
*/
    public void liabilityDetails(String leadid){ 
        
        try{
            list<Liability__c> liabilityRecrd = [SELECT Monthly_Installment__c,Account__c,Original_Amount__c, Account__r.Name, Loan_Type__c,Outstanding_Amount__c,Balance_Tenure_In_Months__c from Liability__c where Lead__c=:leadid];
            for(Liability__c objLiabilityDetail: liabilityRecrd){
                
                if (mapAppvsLiabilities.containsKey(objLiabilityDetail.Account__c)){
                    List<Liability__c> lstLiability= mapAppvsLiabilities.get(objLiabilityDetail.Account__c);
                    lstLiability.add(objLiabilityDetail);
                    mapAppvsLiabilities.put(objLiabilityDetail.Account__c, lstLiability);  
                }else{
                    mapAppvsLiabilities.put(objLiabilityDetail.Account__c, new List<Liability__c> {objLiabilityDetail});  
                }
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
    }
    
    /**
* @author : Rahul Shukla
* @description: Retrieves and stores collateral details for the loan application associated with the given lead ID.
* @param : leadid The ID of the lead for which lead details are to be retrieved.   
* @date :  22/06/2023   
*/
    public void collateralDetails(String leadid){ 
        try{
            list<Asset> collateralRecrd = [SELECT Lead__c,Security_Offered__c,
                                           AccountId, Account.Name,State__c,   
                                           Landmark__c, Country__c, Wing__c,Pin_Code__c,Pin_Code__r.Name,
                                           Area_Taluka_District_Area_name__c,   City__c,Floor__c,Survey_Plot_No__c, 
                                           Building_House_Name__c,Building_House_No__c, Collateral_Type__c, 
                                           Asset_Value__c,Area_Sq_Ft__c,Local_Authority__c from Asset where Lead__c=:leadid AND Security_Offered__c='Yes'];
            for(Asset objCollateralDetail: collateralRecrd){
                
                if (mapAppvsCollateral.containsKey(objCollateralDetail.AccountId)){
                    mapAppvsCollateral.get(objCollateralDetail.AccountId).add(objCollateralDetail);  
                }else{
                    mapAppvsCollateral.put(objCollateralDetail.AccountId, new List<Asset> {objCollateralDetail});  
                }
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
    }
    
    
    /**
* @author :  Rahul Shukla
* @description :  Retrieves and stores reference details for the loan application associated with the given lead ID..
* @param : leadid The ID of the lead for which lead details are to be retrieved. 
* @date :22/06/2023   
*/
    public void referenceDetails(String leadid){ 
        try{
            list<Reference__c> referencrrecrd = [SELECT REF_Title__c, Account__c,Reference_Address_1__c,Pin_Code__r.Name,Pin_Code__c,Reference_Address_2__c,    Reference_Address_3__c,District__c, State__c,Landmark__c,City__c,Country__c,Reference_First_Name__c,Reference_Middle_Name__c,Reference_Last_Name__c,Mobile_No__c,   Email_Id__c,Landline_No__c,Occupation__c from   Reference__c where Lead__c=:leadid];
            
            for(Reference__c objRef: referencrrecrd){
                mapAppvsReferences.put(objRef.Account__c,objRef);    
            }
        }
        catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'An exception occurred: ' + e.getMessage());
        }
    }
    
    
    /**
* Represents the structure of a loan application form with various applicant details,
* @description This class represents a wrapper for a loan application form, containing various details related to the application.
*/
    
    public class WrpLoanApplicationForm{
        /**@description The co-applicant details associated with the loan application. */
        public Co_Applicant__c objCoAppicant {get; set;}
        /** @description The demography details associated with the loan application. */
        public Demography__c objDemography {get; set;}
        /** @description The employment details associated with the loan application. */
        public Employment_Details__c objEmployment {get; set;}
        /** @description The current address details associated with the loan application. */
        public ContactPointAddress objAddressCurrent {get; set;}
        /** @description The permanent address details associated with the loan application. */
        public ContactPointAddress objAddressPermt {get; set;}
        /** @description The office address details associated with the loan application. */
        public ContactPointAddress objOfficeaddress {get; set;}
        /** @description The bank details associated with the loan application. */
        public List<Bank_Details__c> objBankDetails {get; set;}
        /** @description The asset details associated with the loan application. */
        public List<Asset> objAsset {get; set;}
        /** @description The collateral details associated with the loan application. */
        public List<Asset> objCollateral {get; set;}
        /** @description The liability details associated with the loan application. */
        public List<Liability__c> objLiabilities {get; set;}
        /** @description The reference details associated with the loan application. */
        public Reference__c objReferences {get; set;}
        /** @description The URL link to the applicant's photo. */
        public String cPhotolink {get; set;}
        
    }
    
    
    
}