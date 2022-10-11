({
    handleInit: function(cmp, event, helper){
        cmp.set('v.isBusy', true);
    },

    handleLoad: function(cmp, event, helper){
        cmp.set('v.isBusy', false);
    },

    handleSubmit: function(cmp, event, helper){

        var isPreventDefaultSubmit = cmp.get('v.preventDefaultSubmit');

        if(isPreventDefaultSubmit == true){

            event.preventDefault();

            var submitRequest = event.getParams().response;

            var eventVar = cmp.getEvent('onSubmit');
            eventVar.setParams({
                payload: submitRequest
            });
            eventVar.fire();
        } else {
            cmp.set('v.isBusy', true);
        }
    },

    handleSuccess: function(cmp, event, helper){

        var isModal = cmp.get('v.modalInstance') !== null;

        var saveResponse = event.getParams().response;

        if(isModal){
            cmp.closeModal(saveResponse);
        } else {
            var eventVar = cmp.getEvent('onSuccess');
            eventVar.setParams({
                payload: saveResponse
            });
            eventVar.fire();
        }

    },

    handleError: function(cmp, event, helper){
        cmp.set('v.isBusy', false);
    },

    handleSaveClick: function(cmp, event, helper){
        cmp.set('v.isBusy', true);
        cmp.find('recordEditForm').submit();
    },

    handleCancelClick: function(cmp, event, helper){
        var isModal = cmp.get('v.modalInstance') != null;

        if(isModal){
            cmp.cancelModal();
        } else {
            var eventVar = cmp.getEvent('onCancel');
            eventVar.fire();
        }
    }
})