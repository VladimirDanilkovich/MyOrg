({
    processDependent: function(cmp, event, helper){
        var isDepended = cmp.get('v.isDepended');
        if(isDepended !== true){
            return;
        }
        var dependentOptions = cmp.get('v.dependentOptions') || {};
        var dependedValue = cmp.get('v.dependsOn');
        var options = dependentOptions[dependedValue] || [];
        var currentValue = cmp.get('v.value');

        var isAllowed = currentValue && options.some(function (option) { return option.value === currentValue; })

        cmp.set('v.value', isAllowed ? currentValue : null);
        cmp.set('v.options', options);
    }
})