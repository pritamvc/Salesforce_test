({
    navigateToLC : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:communityFormLeadSohail",
            leadRecordId : "v.recordId",
        });
        evt.fire();
        /*var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ShowForm'
            },
            state: {
                c__refRecordId: component.get("v.recordId")
            }
        };
        component.set("v.pageReference", pageReference);
        const navService = component.find('navService');
        const pageRef = component.get('v.pageReference');
        const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
        navService.generateUrl(pageRef).then(handleUrl, handleError);*/
    }
})