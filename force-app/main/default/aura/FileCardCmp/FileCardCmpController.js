({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchFiles");
        
        action.setParams({
            "linkedRecId" : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var result = response.getReturnValue()
                component.set("v.filesIds",result);
            }
        });
        $A.enqueueAction(action);
    }
})