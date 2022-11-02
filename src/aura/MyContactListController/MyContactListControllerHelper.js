({
    init: function(cmp, event, helper, request) {
        helper.execute(
            cmp,
            'MyContactListMetaProc',
            request,
            function (response){
                cmp.set('v.meta.dto', response.dto)
            });
    }
});