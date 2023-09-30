({
	init : function(component, event, helper) {
        var action = component.get("c.showToast");
        action.setParams({
            "mode": component.get("v.mode"),
            "variant": component.get("v.variant"),
            "message": component.get("v.message")
        });

        action.setCallback(this, function(response) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Raise Query",
                "mode": component.get("v.mode"),
                "variant": component.get("v.variant"),
                "message": component.get("v.message")
            });
            toastEvent.fire();
        });

        $A.enqueueAction(action);
        if(component.get("v.message" === 'Query(s) Raised')){
           	var navigate = component.get("v.navigateFlow");
      		navigate("FINISH");
        }
    }
})