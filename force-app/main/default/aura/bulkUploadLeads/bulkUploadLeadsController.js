({
	doinit : function(component, event, helper) {
	//	console.log('Aura Component Loaded');
     //   var accId = component.get("v.recordId");
     //   console.log('RecordIddd===>'+ accId);
	},
    handleSuccess: function(component, event, helper) {
      //  console.log('handleSuccess: function(component');
        $A.get('e.force:refreshView').fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})