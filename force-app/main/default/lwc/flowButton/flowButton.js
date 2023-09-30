import { LightningElement,wire,api } from 'lwc';
import { FlowNavigationNextEvent,getFlowContext } from 'lightning/flowSupport';
export default class FlowButton extends LightningElement {
    // @wire(getFlowContext)
    flowContext;
    showButton=true;
        get showButton() {
        // Replace 'https://your-flow-url-here' with the actual URL of the flow
        return this.flowContext.data && this.flowContext.data.flowInfo.url == '/flow/Customer_List';
    }

    startFlow() {
        // Create an event to navigate to the next screen in the flow
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
    }