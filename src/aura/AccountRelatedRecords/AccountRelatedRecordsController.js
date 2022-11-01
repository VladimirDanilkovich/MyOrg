({
    initContactTable: function (cmp, event, helper) {
        console.log('1123');


        cmp.find('contactFilterProcess').process(
            'MyContactListMetaProc',
            {
                filter: cmp.get('v.meta.filter')
            }
        )
    },

    handleFilterChange: function (cmp, event, helper) {
        console.log('0');

        if(event.getParams().index === 'accountIdFilter' ||  event.getParams().index === 'emailFilter'){
            console.log('1');
            let timeoutId = cmp.get('v.searchTimeoutId');
            clearTimeout(timeoutId);
            timeoutId = setTimeout($A.getCallback(() => {
                    console.log('2');
                    let request = {
                        filter: cmp.get('v.meta.filter')
                    }
                    helper.init(cmp, event, helper, request);
                }
            ), 1000);
            cmp.set('v.searchTimeoutId', timeoutId);;
        }
    },
    handleAccountIdChange: function (cmp, event, helper){
        console.log('55')
        helper.refreshPDFContentEditor(cmp, event, helper);
    }

});