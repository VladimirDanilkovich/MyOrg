({
    handleInit: function(cmp, event, helper){

        var groupKey = cmp.get('v.groupKey');
        var recordId = cmp.get('v.recordId');

        if(recordId){
            groupKey = groupKey.replace('{recordId}', recordId);
        }

        cmp.set('v.condition', 'Group_Key__c != null AND Group_Key__c LIKE \'' + groupKey + '\'');
        cmp.set('v.soqlLimit', cmp.get('v.limit'));

    },

    handleRefresh: function(cmp, event, helper){
        helper.refresh(cmp);
    },

    handleMoreClick: function(cmp, event, helper) {
        cmp.set('v.soqlLimit', cmp.get('v.soqlLimit') + cmp.get('v.limit'));
        helper.refresh(cmp);
    },

    handleViewAllClick: function(cmp, event, helper) {
        cmp.set('v.soqlLimit', 10000);
        helper.refresh(cmp);
    },

    handleLessClick: function(cmp, event, helper) {
        cmp.set('v.soqlLimit', cmp.get('v.limit'));
        helper.refresh(cmp);
    }

})