import { LightningElement } from 'lwc';
import { api,track,wire } from 'lwc';
import getPausedId from "@salesforce/apex/FlowInstanceDelete.getPausedId";

export default class CustomerScreen extends LightningElement{
    //To receive values from the flow
    @api applicantId;
    @api accountId;
    @api dealId;
    @api leadId;

    @track activeTab = 1;
    @track showData = true;
    @track flowNames = [];

    //To define sub-flow names 
    @track customerBasic = 'Customer_Basic_Details';
    @track customerBasicLabel = 'Customer Basic Details';
    @track customerAsset = 'Asset_Details_new';
    @track customerBank = 'Address_Details';
    @track customerCollateral = 'Collateral_details';
    @track customerCollateral = 'Bank_Details_New';
    
    pausedInterviewId;
    flowName;
    //Wire method to get paused flow interviews 
    // @wire(getPausedId)
    // getPausedInterviewId({ error, data }) {
    //     if (error) {
    //     // start a new interview since no interview id was returned.
    //     this.flowName = this.customerBasic;
    //     } else if (data) {
    //     // resume the flow with the returned interview id.
    //     this.pausedInterviewId = data;
    //     console.log('iterview id: '+this.pausedInterviewId);
    //     }
    // }
    
    //CallBack method
    connectedCallback(){
        console.log('deal id '+this.dealId);
        console.log('lead id '+this.leadId);
        getPausedId()
        .then(result=>{
            this.pausedInterviewId = result;
            console.log('interview id: '+this.pausedInterviewId);
        }).catch(error=>{

        });
    }

    //To send data from lwc to sub-screens
    get flowInputVariables(){
        return [
            { name: "applicantId", type: 'String', value: this.applicantId },
            { name: "accountId", type: 'String', value: this.accountId },
            { name: "dealId", type: 'String', value: this.dealId },
            { name: "leadId", type: 'String', value: this.leadId }
	    ];
    }

    handleTabActive(event) {
        this.activeTab = event.target.value;
    }
    
    set applicantId(newValue) {
        debugger;
        console.log('Setter called with newValue:', newValue);
        if (newValue !== this._applicantId) {
            this._applicantId = newValue;
            console.log('value changed');
            this.getPausedId();
        }
    }

    //This getter allows you to retrieve the current value of applicantId
    get applicantId() {
        return this._applicantId;
    }
}