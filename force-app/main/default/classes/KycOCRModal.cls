/*********************************************************************************************
*Name        :  KycOCRModal
*@author     :  Aasim Shaikh
*@date       :  20/04/2023
@description : This class is used set the values for Karza OCR API Request Body
*
*********************************************************************************************/
public class KycOCRModal {
    private String file;
    private String fileBase64;
    private String url;
    private String pdfPassword;
    private Boolean requiredConfidence;
    private Boolean requiredOcr;
    private List<String> returnQualityChecks;
    private String maskAadhaarImage;
    private String maskAadhaarText;
    private String responseFormat;
    private String responseType;
    private List<String> docTypes;

    public String getFile() {
        return file;
    }

    public void setFile(String file) {
        this.file = file;
    }

    public String getFileBase64() {
        return fileBase64;
    }

    public void setFileBase64(String fileBase64) {
        this.fileBase64 = fileBase64;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getPdfPassword() {
        return pdfPassword;
    }

    public void setPdfPassword(String pdfPassword) {
        this.pdfPassword = pdfPassword;
    }

    public Boolean getRequiredConfidence() {
        return requiredConfidence;
    }

    public void setRequiredConfidence(Boolean requiredConfidence) {
        this.requiredConfidence = requiredConfidence;
    }

    public Boolean getRequiredOcr() {
        return requiredOcr;
    }

    public void setRequiredOcr(Boolean requiredOcr) {
        this.requiredOcr = requiredOcr;
    }

    public List<String> getReturnQualityChecks() {
        return returnQualityChecks;
    }

    public void setReturnQualityChecks(List<String> returnQualityChecks) {
        this.returnQualityChecks = returnQualityChecks;
    }

    public String getMaskAadhaarImage() {
        return maskAadhaarImage;
    }

    public void setMaskAadhaarImage(String maskAadhaarImage) {
        this.maskAadhaarImage = maskAadhaarImage;
    }

    public String getMaskAadhaarText() {
        return maskAadhaarText;
    }

    public void setMaskAadhaarText(String maskAadhaarText) {
        this.maskAadhaarText = maskAadhaarText;
    }

    public String getResponseFormat() {
        return responseFormat;
    }

    public void setResponseFormat(String responseFormat) {
        this.responseFormat = responseFormat;
    }

    public String getResponseType() {
        return responseType;
    }

    public void setResponseType(String responseType) {
        this.responseType = responseType;
    }

    public List<String> getDocTypes() {
        return docTypes;
    }

    public void setDocTypes(List<String> docTypes) {
        this.docTypes = docTypes;
    }
}