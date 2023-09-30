/**
 * Author: Dhanaji Patil
 * @description This class is used to handle Access tokens in integrations using Platform Cache.
 * 
 * @Request Body The configuration is obtained from the APIConfiguration__mdt (metadata).
 * @Headers Headers required for the integration, with Content-Type being obtained from APIConfiguration__mdt.
 * @return The access token retrieved from the Platform Cache.
 * @date 02/03/2023
 */
public class LOSToken{
    
    /**
     * Author: Dhanaji Patil
     * @description This method is used to obtain an Access Token and check if it's valid.
     * 
     * @return String The obtained Access Token.
     * @date 28/02/2023
     */
    public static String getAccessToken(){     
        
        //Getting org partition of platform Cache 
        Cache.OrgPartition orgPart = Cache.Org.getPartition(LOSConstants.LOCAL_TOKEN);
         
        String accessToken = (String)orgPart.get(LOSConstants.LOS_TOKEN); 
        DateTime expiry = (DateTime)orgPart.get(LOSConstants.LOS_EXPIRY);
                 
        //Check if access token is Null/Expired.Get the access token only when its expired or calling for the first time 
        if(String.isBlank(accessToken)|| expiry == NULL || expiry < system.now()){    
            generateToken(orgPart);
        }
        
        //If token is updated then getting latest token 
        accessToken = (String)orgPart.get(LOSConstants.LOS_TOKEN);
        expiry = (DateTime)orgPart.get(LOSConstants.LOS_EXPIRY);              
        return accessToken;     
    }
   
    /**
     * Author: Dhanaji Patil
     * @description This method is used to generate a Token and store it in the specified Cache.OrgPartition.
     * 
     * @param orgPart The Cache.OrgPartition where the generated token will be stored.
     * @date 28/02/2023
     */
    public static void generateToken(Cache.OrgPartition orgPart){    
        try{        
            HttpResponse responseToken = null;
            HttpRequest request = new HttpRequest();
            String methodName = System.Label.LOS_Token;

            //Get token details from APIConfiguration__mdt metadata
            APIConfiguration__mdt apiConfig = [SELECT Label, QualifiedApiName, ApiEndPoint__c, RequestMethod__c, 
                        RequestTimeout__c,  HeaderParameters__c, Request_Body__c  from APIConfiguration__mdt where QualifiedApiName =: methodName];
            
            if(null != apiConfig) {
                request.setEndpoint(LOSConstants.ENDPOINT + apiConfig.ApiEndPoint__c);
                request.setHeader(LOSConstants.CONTENT_TYPE, apiConfig.HeaderParameters__c);
                request.setBody(JSON.serialize((Map<String, Object>) JSON.deserializeUntyped(apiConfig.Request_Body__c)));
                request.setMethod(apiConfig.RequestMethod__c);
                request.setTimeout(integer.valueOf(apiConfig.RequestTimeout__c));
                                
                Http httpToken = new Http();
                responseToken = httpToken.send(request);
            }
             
            //Store access token & its expiry time 
            if (responseToken.getStatusCode() == 200) {    
                // create new wraper class
                Map<String, Object> mapResultToken = (Map<String, Object>) JSON.deserializeUntyped(responseToken.getBody());   
                
                //Storing Access Token and Expiry to Org cache 
                orgPart.put(LOSConstants.LOS_TOKEN,mapResultToken.get(LOSConstants.LOS_ACCESS_TOKEN));
                orgPart.put(LOSConstants.LOS_EXPIRY,system.now().addSeconds(Integer.valueOf((mapResultToken.get(LOSConstants.LOS_EXPIRES_IN)))-300));      // 300 sec is minus from the valid token time for sefer side
            }
        }
        catch(Exception e){
            System.debug(LOSConstants.LOS_TOKEN_EXCEPTION+e.getCause());
        }
    }
}