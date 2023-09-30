public class InterestStatementAPIWrapper {
	public cls_dataResponse dataResponse;
	public String message;	
	public String status;	
	public Integer statusCode;	
	public class cls_dataResponse {
		public String finReference;	
		public String docContent;	
		public cls_returnStatus returnStatus;
	}
	public class cls_returnStatus {
		public String returnCode;	
		public String returnText;	
	}
}