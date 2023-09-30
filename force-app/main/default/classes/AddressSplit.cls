public class AddressSplit {
    @InvocableMethod(label='SplitAddress')
    public static void splitAddress(List<InvocableRequest> requestList){
        InvocableRequest request = requestList[0];
        String input = request.input;
        Integer chunkSize = request.chunkSize;
        ContactPointAddress currAdd = request.currAdd;

        if(input.length() <= chunkSize){
            currAdd.Address_2__c = input;
        }
        else{
            List<String> chunks = new List<String>();
            List<String> words = input.split(' ');
            String currentChunk = '';
            
            for (String word : words) {
                if ((currentChunk + ' ' + word).length() <= chunkSize) {
                    if (currentChunk !=null) 
                        currentChunk += ' ';
                    currentChunk += word;
                } 
                else {
                    chunks.add(currentChunk);
                    currentChunk = word;
                }
            }
            
            if (currentChunk != null) 
                chunks.add(currentChunk);
            
            Integer size = chunks.size();
            List<String> chunkFieldApiNames = new List<String>();
            String baseApiName = 'Address';
            
            for (Integer i = 2; i < size+2; i++) 
                chunkFieldApiNames.add(baseApiName + '_' + i + '__c');
            
            for(Integer i=0;i<chunks.size();i++)
                currAdd.put(chunkFieldApiNames[i], chunks[i]);  
        }
        Database.update(currAdd);
    }
    
    public class InvocableRequest {
        @InvocableVariable(required=true)
        public String input;
        
        @InvocableVariable(required=true)
        public Integer chunkSize;
        
        @InvocableVariable(required=true)
        public ContactPointAddress currAdd;
    }
}