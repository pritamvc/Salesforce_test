import { LightningElement, api , track, wire } from 'lwc';
import IMAGES from "@salesforce/resourceUrl/static_images";
import getLeadFormWeightage from '@salesforce/apex/DocumentVerification.getLeadFormWeightage';

import { subscribe, MessageContext } from 'lightning/messageService';
import progressBar from '@salesforce/messageChannel/progressBar__c';

const FIELDS = ['Lead.Lead_form_Weightage__c'];

export default class ProgressChild extends LightningElement {
    @api recordId;
   // @api percentageAll;
    @track roundedNum;
    @track leadFormWeightage;
    
    applicant = IMAGES + '/static_images/images/applicant.png';
    coapplicant = IMAGES + '/static_images/images/co-applicant.png';
    loan = IMAGES + '/static_images/images/loan.png';
    document = IMAGES + '/static_images/images/document.png';
    finance = IMAGES + '/static_images/images/finance.png';
    graduation = IMAGES + '/static_images/images/graduation-cap.png';
   
  
    @wire(getLeadFormWeightage, { leadId: '$recordId' })
    wiredLeadFormWeightage({ error, data }) {
        if (data) {
            this.publisherMessage = data>100?100:data;
            console.log('Lead Form Weightage: ' + data);
        } else if (error) {
            console.error(error);
        }
    }


    publisherMessage=0 ;
    subscription1 = null;

    @wire(MessageContext)
    messageContext;
 
    connectedCallback() {
        this.handleSubscribe();
        // getLeadTotalPercentage({ leadId:'$recordId' })
        // .then(result => {
        //     console.log('Total pppercentagee:', result);
        //     this.leadFormWeightage = result;
        // })
        // .catch(error => {
        //     console.error(error);
        // });
    }
 
    handleSubscribe() {
        debugger
        subscribe(this.messageContext, progressBar , (ProgrssValueOfLoanSection) => {
            console.log('$$$$$$$$$ProgrssValueOfLoanSection##########  ',ProgrssValueOfLoanSection.ProgrssValueOfLoanSection);
            this.publisherMessage = ProgrssValueOfLoanSection.ProgrssValueOfLoanSection;
        });
        

        
       
     
    }  

    messageHandler(message){
        console.log('$$$$$$$$$ProgrssValueOfCoAppSection##########  '+message.ProgrssValueOfCoAppSection);
        this.publisherMessage = message.ProgrssValueOfCoAppSection;
      // this.UpdateHandler();
    };

}