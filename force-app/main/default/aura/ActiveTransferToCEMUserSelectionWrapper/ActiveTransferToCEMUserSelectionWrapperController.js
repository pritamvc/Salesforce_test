({
    doinit : function(component, event, helper) {
        var accId = component.get("v.recordId");
        console.log('RecordIddd===>'+ accId);
    },
    handleOnSuccess : function(component, event, helper) {
        var accId = component.get("v.recordId");
        console.log('RecordIddd22222===>'+ accId);
        var params = event.getParams();
        var recordName = params.response.fields.Name.value;
        component.find("navService").navigate({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": params.accId,
                "objectApiName": "Lead",
                "actionName": "view"
            }
        });
    }
})