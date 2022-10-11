({
    refresh: function (cmp, event, helper) {

        var recordId = cmp.get('v.recordId');
        var additionalConditions = cmp.get('v.additionalConditions');
        if(recordId){
            helper.doInit(
                cmp,
                cmp.get('v.processor'),
                {
                    'SOQL': 'SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = \'' + cmp.get('v.recordId') + '\'' + (additionalConditions ? ' AND ' + additionalConditions : '')
                }

            ).then($A.getCallback(function(response) {
                helper.triggerRefreshEvent(cmp, event, helper);
            }))
        } else {
            cmp.set('v.meta.dto.records', []);
            helper.triggerRefreshEvent(cmp, event, helper);
        }

    },

    triggerRefreshEvent: function(cmp, event, helper) {
        var event = cmp.getEvent('onRefresh');
        event.setParams({
            payload: {
                files: cmp.get('v.meta.dto.records')
            }
        });
        event.fire();
    }
})