({
    handleInit: function(cmp, event, helper){
        helper.processDependent(cmp, event, helper);
    },

    handleDependentChange: function(cmp, event, helper){
        helper.processDependent(cmp, event, helper);
    }
})