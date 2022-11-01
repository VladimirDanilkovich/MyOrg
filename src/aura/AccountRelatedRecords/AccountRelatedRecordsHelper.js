({
    init: function(cmp, event, helper, request) {
        helper.execute(
            cmp,
            'MyContactListMetaProc',
            request,
            function (response){
                cmp.set('v.meta.dto', response.dto)
            });
    },

    refreshPDFContentEditor: function (cmp, event, helper) {
        cmp.find('PDFContentEditor').set('v.params', helper.getPDFContentParams(cmp, event, helper));
        cmp.find('PDFContentEditor').refresh();
    },
    getPDFContentParams: function (cmp, event, helper) {
        console.log('accountId: '+ cmp.get('v.meta.filter.accountIdFilter'));
        return {
            proc: 'CreatePDFAccount',
            accountId: cmp.get('v.meta.filter.accountIdFilter'),
            renderAs: 'pdf',
            fileName: 'Account.pdf'
        };
    }
});
