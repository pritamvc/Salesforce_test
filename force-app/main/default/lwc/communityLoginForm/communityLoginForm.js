import { LightningElement, wire, api, track } from 'lwc';
import OtpRequestMob from '@salesforce/apex/MobileNoCommunityVerify.OtpRequest';
import OtpVerifyMob from '@salesforce/apex/MobileNoCommunityVerify.OtpVerify';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CommunityLoginForm extends LightningElement {
    @track otpBtn=true;
    @track showModalMobile = false;
    @track errormsg="";
    @api otp;
    @track otpValueMob;
    mbNumber;
    requestIdMob;

    changeMobHandler(event){
       this.mbNumber=event.target.value
       console.log(event.target.value)
       //console.log('Entered Mobile Number ###'+ this.mbNumber)
       
        if (this.mbNumber.match(/[0-9]{10}$/)) {
            this.otpBtn=false
        }else{
            this.otpBtn=true
        }
       
    }

    handleClick(){
        console.log('otp btn Clicked')
        this.otpBtn=true;
    setTimeout(() => {
        this.otpBtn =false;
    }, 5000)
    if(this.mbNumber!=""&&this.mbNumber!=undefined){
        OtpRequestMob({ mobile: this.mbNumber, consent:'y'})
        .then((result) => {
            console.log("full",result);
            let responseObj = JSON.parse(result);
            console.log(responseObj);
            this.requestIdMob = responseObj['request_id'];
            console.log("reqid",this.requestIdMob);
            console.log('status code'+responseObj['status-code']);
            if (responseObj['status-code']==101) {
             this.showModalMobile = true;
            this.showtoastMethod('Success','OTP sent successfully!','success');
             
         }else{
           this.showtoastMethod('Error','Failed to send OTP. Please try again!','error');
           
         }
        })
        .catch((error) => {
            console.error("error",error);
        });
    }
 }
 closeModalMobile() {
    this.showModalMobile = false;
    this.otpValueMob=""
  }
  handleOtpforMob(event){
    this.otpValueMob = event.target.value
    console.log(event.target.value);
}
 // @wire(OtpVerifyMob, {otp: '$otp', request_id: '$request_id'})
  @wire(OtpVerifyMob, {otp: '$otpValueMob', request_id: '$request_id'})
  OtpVerifyMob({error, data}) {
  if (error) {
  // error handling 
  console.log("@wire error"+error);
  }
  if (data) {
  // success handling
  console.log('@wire otpVarified####'+data);
  this.showModalMobile = false;
 this.showtoastMethod('Success','Mobile Number Verified!','success');
       
    
  }
  }
  handleVerifyMob(){
    console.log('handleVerifyMob')
    console.log("this.otpValueMob",this.otpValueMob);
    console.log("this.requestIdMob",this.requestIdMob);
   OtpVerifyMob({ otp: this.otpValueMob, request_id:this.requestIdMob})
        .then((result) => {
            console.log("full",result);
            let responseObj = JSON.parse(result);
            console.log("responseObj"+responseObj);
           // console.log('status-code'+responseObj['status-code']);
            if (responseObj['status-code']==101) {
             this.showModalMobile = false;
            
            
            this.showtoastMethod('Success','Mobile Number Verified!','success')
             
         }else{
            this.showtoastMethod('Error','Failed to Verify! Please try again!','error');
         }
        })
        .catch((error) => {
            console.error("error",error);
        });
    console.log("mobile Verification Done");
 }

 showtoastMethod(title,message,variant){
    const event = new ShowToastEvent({
        title:title,
        message:message,
        variant:variant,
        });
        this.dispatchEvent(event);
 }
 
}