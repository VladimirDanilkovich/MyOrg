({
    handleInit: function(cmp, event, helper){

        var condition = cmp.get('v.condition');

        helper.execute(
            cmp,
            'vertic_SOQLProc',
            {
                SOQL: 'SELECT Id, Description, Name, DeveloperName FROM RecordType WHERE (SobjectType = \'' + cmp.get('v.sObjectName') +  '\')' + (condition ? ' AND (' + condition + ')' : '')
            },
            function (response) {
                cmp.set('v.meta', response);
                var defaultRecordTypeApiName = cmp.get('v.default');
                if(defaultRecordTypeApiName){
                    var filteredItems = response.dto.records.filter(function (recType) {
                        return recType.DeveloperName === defaultRecordTypeApiName;
                    });
                    var defaultRecordType = filteredItems.length ? filteredItems[0] : undefined;
                    if(defaultRecordType){
                        cmp.set('v.selectedOption', defaultRecordType.Id);
                        var radioInputs = cmp.find('radio-container').find({instancesOf: 'lightning:input'});
                        radioInputs.forEach(function (radioCmp) {
                            if(radioCmp.get('v.value') == defaultRecordType.Id){
                                radioCmp.set('v.checked', true);
                            }
                        });
                    }
                }
            }
        );

    },


    handleRadioClick : function(cmp, event, helper){
        cmp.set('v.selectedOption', event.getSource().get('v.value'));
    },

    handleNextClick: function (cmp, event, helper) {

        var isValid = helper.validateForm(cmp, 'form');

        if(isValid !== true){
            return;
        }

        var recordTypeId = cmp.get('v.selectedOption');
        if($A.util.isEmpty(recordTypeId)){
            helper.getBaseCmp(cmp).find('errorMessages').showErrors(['Record Type is required'], true);
            return;
        }

        cmp.closeModal({
            recordTypeId: recordTypeId,
            recordType: cmp.get('v.meta.dto.records').filter(function (recordType) {
                return recordType.Id == recordTypeId;
            })[0]
        });
    },

    handleCancelClick: function(cmp, event, helper){
        cmp.cancelModal();
    }
})