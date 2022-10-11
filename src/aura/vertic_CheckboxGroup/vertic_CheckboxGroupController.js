({

    handleInit: function(cmp, event, helper){
        var val = cmp.get('v.value');
        val = val || '';
        cmp.set('v.cmpValue', val === '' ? [] : val.split(';'));
    },

    handleCheckboxGroupChange: function(cmp, event, helper) {
        var cmpValue = event.getParam('value');
        cmpValue = cmpValue || [];
        cmp.set('v.value', cmpValue.join(';'));
    }
})