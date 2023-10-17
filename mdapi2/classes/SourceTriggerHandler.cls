/*********************************************************************************************
* @author          Thinqloud Solutions (Chandrakant More)
* @description     This class is used in SourceTrigger
* @date            20/02/2023    
* @testClass: 
**********************************************************************************************/
public class SourceTriggerHandler {
        /********************************************************************************************************
* @author          Chandrakant More
* @description     singleSourceOnAccount this method used to prevent the user for creation of more than one source per object
* @return          No-return    
* @date            20/02/2023   
********************************************************************************************************/
    public static void singleSourceOnAccount(List<Source__c> sourcelist){
        set<Id> SetOfPartnerAccountId = new set<Id>();
        for(Source__c objectSource : sourcelist){
            SetOfPartnerAccountId.add(objectSource.Partner_Name__c);
        }
        List<Source__c> existingChildSource = new List<Source__c>();
        if(!SetOfPartnerAccountId.IsEmpty() && SetOfPartnerAccountId.size()> 0){
            existingChildSource =[Select Id,Name,Partner_Name__c From Source__c where Partner_Name__c =: SetOfPartnerAccountId];
        }
        Map<Id,List<Source__c>> mapPartnerIdSource = new Map<Id,List<Source__c>>();
        if(!existingChildSource.IsEmpty() && existingChildSource.size() > 0){
            for(Source__c objectSource : existingChildSource) {
                if(mapPartnerIdSource.containsKey(objectSource.Partner_Name__c)) {
                    List<Source__c> lstsource = mapPartnerIdSource.get(objectSource.Partner_Name__c);
                    lstsource.add(objectSource);
                    mapPartnerIdSource.put(objectSource.Partner_Name__c, lstsource);
                } else {
                    mapPartnerIdSource.put(objectSource.Partner_Name__c, new List<Source__c> {objectSource });
                }
            }        
        }
        for(Source__c SourceVar:sourcelist)
        {  if(mapPartnerIdSource.containsKey(SourceVar.Partner_Name__c)) {
            if(mapPartnerIdSource.get(SourceVar.Partner_Name__c).size()>=1){
                SourceVar.addError('Only one Source record allowed for one Partner Account.');
            }
        } 
        }
    }
    
/********************************************************************************************************
* @author          Dhanaji Patil
* @description     updateSourceAccountDetailsAsPerConfigration this method used to update the Partner code when update the accountsource
* @return          No-return    
* @date            04/05/2023   
********************************************************************************************************/
    
    public static void updateSourceAccountDetailsAsPerConfigration(List<Source__c> sourcelist){
        set<Id> SetOfPartnerAccountId = new set<Id>();
        for(Source__c objectSource : sourcelist){
            SetOfPartnerAccountId.add(objectSource.Partner_Name__c);
        }
        if(null != SetOfPartnerAccountId && SetOfPartnerAccountId.size()>0){
            List<Source__c> existingSourceList = [Select Id,Name,Partner_Name__c,Partner_Name__r.Partner_Code__c, Source_Type__c, Sub_Source_Type__c, Source_Category__c, Partner_Name__r.RecordType.Name, Partner_Name__r.Current_Record_Type__c From Source__c where Partner_Name__c =:SetOfPartnerAccountId];
            List<Source__c> existingSourceListForUpdate = new List<Source__c>();
            List<Account> existingSourceAccountListForUpdate = new List<Account>();

            /****************** collecting the custom details ************************/
            Map<String, Partner_Naming_Configrations__c> collectMmapOfPartnerNameAndConfigObj = Partner_Naming_Configrations__c.getAll();
            Map<String, Partner_Naming_Configrations__c> mapOfPartnerNameAndConfigObj = new  Map<String, Partner_Naming_Configrations__c>();
            if(null != collectMmapOfPartnerNameAndConfigObj){
                for(Partner_Naming_Configrations__c partnerNameObject : collectMmapOfPartnerNameAndConfigObj.values()){
                    mapOfPartnerNameAndConfigObj.put(partnerNameObject.Partner_Category__c,partnerNameObject);
                }  
            }
            
            Map<String, Partner_Naming_Configrations__c> mapOfPartnerNameAndConfigObjForUpdate = new Map<String, Partner_Naming_Configrations__c>();
           
            if(null != existingSourceList && existingSourceList.size()>0){
                for(Source__c sourceObj : existingSourceList){
                    checkingTheTypeNadUpdateTheDetails(sourceObj, existingSourceAccountListForUpdate, mapOfPartnerNameAndConfigObjForUpdate,mapOfPartnerNameAndConfigObj);
                }
            }
            
            if(null != existingSourceAccountListForUpdate && existingSourceAccountListForUpdate.size()>0){
                update existingSourceAccountListForUpdate;
            }
            if(null != mapOfPartnerNameAndConfigObjForUpdate){
                Database.update(mapOfPartnerNameAndConfigObjForUpdate.values());
            }
        }
    }
    
    /****************************** here we can check the partner type and if mached then update the partner code as per logic ***************************/
    public static void checkingTheTypeNadUpdateTheDetails(Source__c sourceObj, List<Account> existingSourceAccountListForUpdate, Map<String, Partner_Naming_Configrations__c> mapOfPartnerNameAndConfigObjForUpdate, Map<String, Partner_Naming_Configrations__c> mapOfPartnerNameAndConfigObj){
        if(System.Label.Account_Type.equalsIgnoreCase(sourceObj.Partner_Name__r.RecordType.Name)){
            if(mapOfPartnerNameAndConfigObj.containsKey(sourceObj.Sub_Source_Type__c)){
                Partner_Naming_Configrations__c  partnerNamingObj= mapOfPartnerNameAndConfigObj.get(sourceObj.Sub_Source_Type__c);
                if(null != partnerNamingObj){
                    Partner_Naming_Configrations__c  partnerNamingObjToUpdate = new Partner_Naming_Configrations__c();
                    partnerNamingObjToUpdate = new Partner_Naming_Configrations__c(Id=partnerNamingObj.Id);
                    Account accountObj = new Account(Id=sourceObj.Partner_Name__c);
                    accountObj.Partner_Code__c = partnerNamingObj.Static__c+partnerNamingObj.Auto_increment_basis_category__c;
                    partnerNamingObjToUpdate.Auto_increment_basis_category__c = generateIncrementedFinalValue(partnerNamingObj.Auto_increment_basis_category__c.length(),partnerNamingObj.Auto_increment_basis_category__c);
                    mapOfPartnerNameAndConfigObjForUpdate.put(partnerNamingObjToUpdate.Partner_category__c,partnerNamingObjToUpdate);
                    existingSourceAccountListForUpdate.add(accountObj);
                }else{
                  checkingTheTypeNadUpdateTheDetails( sourceObj, existingSourceAccountListForUpdate);
                } 
            }
            else{
               checkingTheTypeNadUpdateTheDetails( sourceObj, existingSourceAccountListForUpdate);
            }
        }else{
           checkingTheTypeNadUpdateTheDetails( sourceObj, existingSourceAccountListForUpdate);
        }
    }
    
    /********************* this method used for if any source is removed the remove the partner code ******************************/
    public static void checkingTheTypeNadUpdateTheDetails(Source__c sourceObj,List<Account> existingSourceAccountListForUpdate){
        Account accountObj = new Account(Id=sourceObj.Partner_Name__c);
        accountObj.Partner_Code__c = '';
        existingSourceAccountListForUpdate.add(accountObj);
    }
    
    /********************* this method used forgenerate the incremented string field value ******************************/
    public static String generateIncrementedFinalValue(integer lenght,String oldCategporyValue){
        integer size= lenght;
        Integer intNumber = Integer.valueOf(oldCategporyValue);
        intNumber++;
        String finalValue = String.valueOf(intNumber);
        integer addZerobeforeString = Integer.valueOf(size) - Integer.valueOf(finalValue.length());
        for (Integer i = 1; i <= addZerobeforeString; i++) {
            finalValue = '0'+finalValue;
        }
        return finalValue;
    }
}