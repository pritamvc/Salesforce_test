/*********************************************************************************************
* @author          Vaibhav Hinge
* @description     This Class used for get and save financial data.
* @date            18 May 2023  
* @testClass:      
**********************************************************************************************/
public class DealLeadFinancialController {
    
    //Return Co_Applicant__c related lead
    @AuraEnabled
    public static List<Co_Applicant__c> getCoApplicants(String leadGetId){
        system.debug('leadGetId= '+leadGetId);
        List<Co_Applicant__c> coApplicants = new  List<Co_Applicant__c>();
        coApplicants = [Select Id, Name,Account__c, Account__r.Name,Lead__r.Name, Lead__r.Id, Deal__c, Account__r.Id,Type__c
                        from Co_Applicant__c WHERE (Lead__r.Id =: leadGetId OR Deal__c =:leadGetId)];
        system.debug('coApplicants= '+coApplicants.size());
        return coApplicants;         
    }
    
    //Return Co_Applicant__c related lead with Income considered as financial
    @AuraEnabled(cacheable=true)
    public static List<Co_Applicant__c> getFinancialCoApplicants(String leadGetId){
        List<Co_Applicant__c> financialCoApplicants = new  List<Co_Applicant__c>();
        financialCoApplicants = [Select Id,Name,Account__c,Account__r.Name,Lead__r.Id,Account__r.Id,Type__c, Deal__c from Co_Applicant__c WHERE (Lead__r.Id = :leadGetId OR Deal__c =:leadGetId) AND Is_Income_Considered_Financial__c = 'Yes'];
        return financialCoApplicants;         
    }
    
    //Return applicant,Bank details , Asset and liability    
    @AuraEnabled(cacheable=true)
    public static wrapperClassForCommForm getFinanceData(String leadGetId){
        system.debug('leadGetId ' +leadGetId);
        Set<Id> applicantAccIds = new Set<Id>();
        
        List<Co_Applicant__c> applicants = [SELECT Id, Account__r.Name,Name,Type__c,Account__c,Account__r.Id 
                                            FROM Co_Applicant__c WHERE (Lead__c =: leadGetId OR Deal__c =:leadGetId)];
        List<Bank_Details__c> bankDetails  = new List<Bank_Details__c>();
        List<Asset> assetRecords = new List<Asset>();
        List<Liability__c> liabilityRecords = new List<Liability__c>();
        
        // Iterate through the co-applicants and add their account IDs to the set.
        for(Co_Applicant__c applicant : applicants){
            applicantAccIds.add(applicant.Account__r.Id);
        }  
        
        // Get bank details
        try{
            bankDetails  = [SELECT Id,Account__c,Account_Holder_Name__c,Account_Number__c,Account_Operational_Since__c,Account_Type__c,
                            Bank_Branch_IFSC__c,Name_of_Bank__c,IFSC_Code__c,MICR_Code__c 
                            FROM Bank_Details__c WHERE Account__c In: applicantAccIds AND (Lead__c =: leadGetId OR Deal__c =:leadGetId)];
            System.debug('Bank Record:'+bankDetails );
        }
        catch(Exception e){
            System.debug('Error getting bank details: ' + e);
        }
        
        // Get assets
        try{
            assetRecords = [SELECT Id,AccountId,Asset_Type__c,Asset_Value__c,Description 
                            FROM Asset WHERE AccountId = :applicantAccIds AND (Lead__c =: leadGetId OR Deal__c =:leadGetId) AND Asset_Type__c != null];
            System.debug('asset Record:'+assetRecords);
        }
        catch(Exception e){
            System.debug('Error getting assets: ' + e);
        }
        
        // Get liabilities
        try{
            liabilityRecords = [SELECT Id,Account__c,Loan_Type__c,Monthly_Installment__c,Original_Amount__c,
                                Outstanding_Amount__c,Balance_Tenure_In_Months__c 
                                FROM Liability__c WHERE Account__c =:applicantAccIds AND (Lead__c =: leadGetId OR Deal__c =:leadGetId)];
        }
        catch(Exception e){
            System.debug('Error getting liabilities: ' + e);
        }
        
        // Create a wrapper class for the results
        wrapperClassForCommForm financeData  = new wrapperClassForCommForm();
        if(bankDetails  != null)
            financeData .bankAccount = bankDetails ;
        if(assetRecords != null)
            financeData .assetDetails = assetRecords;
        if(liabilityRecords != null)
            financeData .liabilityDetails = liabilityRecords;
        
        System.debug('wc======>: ' + financeData );
        return financeData ;  
        
    }
    
    //To get Name of bank,IFSC,MICR from branch
    @AuraEnabled
    public static Bank_Branch_IFSC__c getBankBranchDetails(Id branchId){
        System.debug(branchId);
        Bank_Branch_IFSC__c branchRecord = new  Bank_Branch_IFSC__c();
        branchRecord = [Select Id,Bank__c,MICR__c,IFSC__c,Name From Bank_Branch_IFSC__c WHERE Id =: branchId];
        return branchRecord;
    }
    
    //Save financial section data
    @AuraEnabled
    public static wrapperClassForCommForm saveFinancialData(List<Bank_Details__c> financialData,
                                                            List<Asset> assetData,
                                                            List<Liability__c> liabilityData,
                                                            String leadGetId, 
                                                            String deleteBankIds,
                                                            String deleteAssetId, 
                                                            String deleteLiabilityIds){
                                                                
                                                                system.debug('leadGetId= '+leadGetId);
                                                                //Lists for Upsert fuctionality
                                                                List<Asset> assetRecordsToUpsert = new List<Asset>();
                                                                List<Liability__c> liabilityRecordsToUpsert = new List<Liability__c>();
                                                                
                                                                //Lists for Delete fuctionality
                                                                List<Bank_Details__c> deleteBanks = new List<Bank_Details__c>();
                                                                List<Asset> deleteAssets = new List<Asset>();
                                                                List<Liability__c> deleteLiabilities = new List<Liability__c>();
                                                                
                                                                //List of Bank record to be deleted
                                                                if(String.isNotBlank(deleteBankIds)){
                                                                    List<Id> BanksIds = deleteBankIds.split(',');
                                                                    //get Id of Bank details object
                                                                    deleteBanks = [SELECT Id FROM Bank_Details__c WHERE Id IN :BanksIds];
                                                                }
                                                                
                                                                //List of Asset record to be deleted
                                                                if(String.isNotBlank(deleteAssetId)){
                                                                    List<Id> AssetsIds = deleteAssetId.split(',');
                                                                    //get Id of Asset object
                                                                    deleteAssets = [SELECT Id FROM Asset WHERE Id IN :AssetsIds];
                                                                }
                                                                
                                                                //List of Liabilitys record to be deleted
                                                                if(String.isNotBlank(deleteLiabilityIds)){
                                                                    List<Id> LiabilitiesIds = deleteLiabilityIds.split(',');
                                                                    //get Id of Liability object
                                                                    deleteLiabilities = [SELECT Id FROM Liability__c WHERE Id IN :LiabilitiesIds];
                                                                }
                                                                
                                                                if(financialData != null){
                                                                    upsert financialData;                                                      
                                                                }
                                                                
                                                                if(deleteBanks != null && !deleteBanks.isEmpty()){    
                                                                    delete deleteBanks;
                                                                    System.debug('@@deleteBanks Inside If=====>'+deleteBanks);
                                                                }
                                                                
                                                                if(assetData != null){
                                                                    for(Asset asset :assetData){
                                                                        if(asset.Name == '' && asset.Asset_Type__c == '' && asset.Asset_Value__c == null && asset.Description == ''){
                                                                            System.debug('Not to add data');
                                                                        }
                                                                        else{
                                                                            assetRecordsToUpsert.add(asset);
                                                                        }  
                                                                    }
                                                                    upsert assetRecordsToUpsert;
                                                                }
                                                                if(deleteAssets != null && !deleteAssets.isEmpty()){    
                                                                    delete deleteAssets;
                                                                }
                                                                
                                                                if(liabilityData != null){
                                                                    for(Liability__c liability:liabilityData){
                                                                        if(liability.Loan_Type__c == '' && liability.Monthly_Installment__c == null && liability.Balance_Tenure_In_Months__c == null && liability.Outstanding_Amount__c == null && liability.Original_Amount__c == null){
                                                                            System.debug('Not to add data');
                                                                        }
                                                                        else{
                                                                            liabilityRecordsToUpsert.add(liability);
                                                                        }
                                                                    }
                                                                    upsert liabilityRecordsToUpsert;
                                                                }
                                                                if(deleteLiabilities != null && !deleteLiabilities.isEmpty()){    
                                                                    delete deleteLiabilities;
                                                                }
                                                                
                                                                wrapperClassForCommForm financial = new wrapperClassForCommForm();
                                                                financial = getFinanceData(leadGetId);
                                                                return financial;
                                                            }
    
    
    public class wrapperClassForCommForm{
        //Financial Section
        @AuraEnabled
        public List<Bank_Details__c> bankAccount{get;set;}
        @AuraEnabled
        public String bankAccountSave{get;set;}
        @AuraEnabled
        public List<Asset> assetDetails{get;set;}
        @AuraEnabled
        public String assetRecordSave{get;set;}
        @AuraEnabled
        public List<Liability__c> liabilityDetails{get;set;}
        @AuraEnabled
        public String liabilityRecordSave{get;set;}
        
    }  
    
    @AuraEnabled
    public static Lead updateFinancialCheck(String leadId,Boolean isCheck){
        Lead rec = [SELECT Id,Financial_Section__c FROM Lead WHERE Id =: leadId];
        rec.Financial_Section__c = isCheck;
        update rec;
        return rec;
    }
}