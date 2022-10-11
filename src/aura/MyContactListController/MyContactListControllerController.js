({
    myAction: function (cmp, event, helper){



      /*  var contactEmail = cmp.get('v.contactEmail') || '';
        var accountId = cmp.get('v.dto.accountId') || '';


        var accountName = cmp.get('v.accountName') || '';
*/


        helper.execute(
            cmp,
            'MyContactListMetaProc',
            {},
            function (response){
                cmp.set('v.dto.accountId', response);
            });


        console.log('LOG: '+ contactEmail);

        var action = cmp.get('c.getContacts');
        action.setParams({
            recordId: cmp.get('v.dto.accountId'),
            contactEmail: cmp.get('v.contactEmail')
        });
        action.setCallback(this, function(data) {
            cmp.set('v.contacts', data.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    

    onSearchTermChange: function (cmp, event, helper){

     //   console.log('LOG0: DUBUG');

        var timeoutId = cmp.get('v.searchTimeoutId');
        clearTimeout(timeoutId );
       // console.log('LOG1: DUBUG');

        timeoutId = setTimeout( $A.getCallback( function () {
            //console.log('LOG2: DUBUG');
            var fun = cmp.get('c.myAction');
            $A.enqueueAction(fun);
            }
        ), 500);

       // console.log('LOG3: DUBUG')
        cmp.set('v.searchTimeoutId', timeoutId);

    },

    handleAddClick: function (cmp, event, helper) {
        if (cmp.get('v.selectedFieldSet')) {
            let animals = cmp.get('v.meta.dto.animals') || [];
            let fields = JSON.parse(JSON.stringify(cmp.get('v.meta.dto.objectFields'))) || [];

            animals.splice(0, 0, {fields: fields});
            cmp.set('v.meta.dto.animals', animals);
        }
    }


});