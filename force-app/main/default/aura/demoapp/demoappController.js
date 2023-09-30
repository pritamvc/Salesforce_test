({

    handleSelection : function(component, event, helper) {

        try {

            var name = event.getParam('name');

            var selectedRecord = event.getParam('selectedRecord');

            console.log(name);

            console.log(selectedRecord.Id);

        } catch (err) {

            console.log(err);

        }

    }

})