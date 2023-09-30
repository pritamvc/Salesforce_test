import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
export default class ButtonApplicantMainPage extends NavigationMixin(LightningElement) {
     @api flowName;
     @api recordId;
    // handleClick() {
    //     console.log('ButtonApplicantMainPage');

    //     //const navigateNextEvent = new FlowNavigationNextEvent(this.flowName);
    //     const navigateNextEvent = new FlowNavigationNextEvent();
    //     this.dispatchEvent(navigateNextEvent);
    // }
   
    // handleClick() {
    //     console.log('ButtonApplicantMainPage22222222');

    //     // Define the parameters for navigation
    //     const pageReference = {
    //         type: 'standard__navItemPage',
    //         attributes: {
    //             apiName: 'Customer Details' 
    //         }
    //     };
    //     this[NavigationMixin.Navigate](pageReference);
    // }

    handleClick() {
        console.log('ButtonApplicantMainPage23333333');
        const pageReference = {
          type: 'standard__recordPage',
          attributes: {
            recordId: this.recordId, 
            actionName: 'view'
          },
          state: {
            navigationLocation: 'LOOKUP',
            selectedTab: 'Customer Details'
          }
        };
      
        this[NavigationMixin.Navigate](pageReference);
      }
      navigateToFirstScreen() {
        const pageReference = {
            type: 'standard__flow',
            attributes: {
                flowName: 'Customer_List', 
            },
           
        };
        this[NavigationMixin.Navigate](pageReference);
    }
    
      handleClick1(){
        const url = `/lightning/r/Opportunity/${this.recordId}/view?0.source=alohaHeader&tabset-2=${this.recordId}/Customer Details`;

        window.location.href = url;
      }
     
      
}