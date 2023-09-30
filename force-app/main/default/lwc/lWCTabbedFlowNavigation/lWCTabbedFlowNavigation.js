import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';




export default class HelloWorld extends LightningElement {
 @track activeChild = 1;
 
 @api applicationId = ""; 
 @api recordId = "";      
 
  greeting = 'Navigation Testing';
  changeHandler(event) {
    this.greeting = event.target.value;
    //this.applicationId= lightning__FlowScreen.firstSelectedRow.applicationId;
  
  }
  /******Next button****/

handleNext(event) {
    this.activeChild = event.detail.nextValue;
    console.log('### handleNext===>' + this.activeChild);
}
handleTabActivated(event) {
    const activeTabValue = event.target.value;
    this.activeChild = activeTabValue;
    console.log('### ActiveChild===>' + this.activeChild);
    console.log('### Active tab label==>' + event.target.label)    
    
    

}
}