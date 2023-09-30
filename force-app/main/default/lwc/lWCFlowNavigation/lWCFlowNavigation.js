import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class FlowNavigateButtons extends LightningElement {
    @api
    availableActions = [];

    @api
    label; //Label of the button

    @api
    buttonId; //Unique button Id

    @api
    selectedButtonId; //Property that'll store the buttonId

    handleNavigation() {

        this.selectedButtonId = this.buttonId; //Setting the buttonId when button is clicked.

        /** Navigating to next screen */
        if (this.availableActions.find(action => action === 'NEXT')) {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
}