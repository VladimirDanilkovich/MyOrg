({
    handleInit: function(cmp, event, helper){
        cmp.set('v.message', cmp.get('v.initialMessage'));
    },

    handleConfirmClick: function(cmp, event, helper){
        helper.execute(
            cmp,
            'vertic_VAPRetrySubmitProc',
            {
                id: cmp.get('v.recordId')
            },
            function () {},
            function () {}
        ).then(function (response) {

            cmp.set('v.meta.dto.vap', response.dto.vap);

            if('Completed' == response.dto.vap.Status__c){
                cmp.set('v.message', cmp.get('v.successProcessedMessage'));

                cmp.find('modal').close();

                helper.utils(cmp).showToast({
                    message: 'Processed Successfully',
                    type: 'success'
                });

            } else{
                cmp.set('v.message', cmp.get('v.failProcessedMessage'));
            }

        }).catch(function (errors) {
            cmp.set('v.message', cmp.get('v.errorMessage'));
            cmp.set('v.meta.errorMessage', errors[0].message);
        });
    }
});