({
    afterRender: function (component, helper) {
        this.superAfterRender();

        // Get a reference to the tabset component
        var tabSetCmp = component.find("tabSet");

        // Add a listener for tab change events
        tabSetCmp.getElement().addEventListener("click", function (event) {
            // Check if the clicked element is a tab
            if (event.target && event.target.getAttribute("data-aura-rendered-by") === "tab") {
                // Get the selected tab's value
                var selectedTabId = event.target.getAttribute("data-tab-id");

                // Set the activeTab attribute to the selected tab's value
                component.set("v.activeTab", selectedTabId);
            }
        });
    },
    init: function(component, event, helper) {
        // Get a reference to the Flow component
        //debugger;
        var flow = component.find("flowData");
        var inputVariables = [
            { name: "applicantId", type: "String", value: component.get("v.applicantId") },
            { name: "accountId", type: "String", value: component.get("v.accountId")},
            { name: "dealId", type: "String'", value: component.get("v.dealId") },
            { name: "leadId", type: "String", value:component.get("v.leadId") }
        ];
        
        // Set the input variables for the Flow
        //flow.set("v.flowInputVariables", inputVariables);
        // Start or navigate the Flow
        flow.startFlow("Customer_Basic_Details",inputVariables);
        
    }
})