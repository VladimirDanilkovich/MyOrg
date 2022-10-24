({
    initCaseCreation: function (cmp, event, helper) {
        cmp.find('contactFilterProcess').process(
            'caseCreateMetaProc',
            {

            }
        )
    },
    addCase: function (cmp, event, helper) {
        let caseList = cmp.get('v.meta.testResponse.dto.caseList') || [];
        console.log('LOG1 ' + caseList);
        caseList.unshift({
            SuppliedEmail: 'test@gmail.com'
        });
        cmp.set('v.meta.testResponse.dto.caseList', []);
        cmp.set('v.meta.testResponse.dto.caseList', caseList);
    },
    deleteCase: function (cmp, event, helper) {
        let whichOne = event.getSource().get('v.name');
        let caseList = cmp.get('v.meta.testResponse.dto.caseList') || [];
        caseList.splice(whichOne, 1);
        cmp.set('v.meta.testResponse.dto.caseList', []);
        cmp.set('v.meta.testResponse.dto.caseList', caseList);
    },
    upsertCase:function (cmp, event, helper){
        let caseList = cmp.get('v.meta.testResponse.dto.caseList') || [];
        let selectVar = cmp.find('selectButton').get('v.value');
        console.log('LOOOG ' + selectVar);
        if(selectVar === 'selected') {
            for (let a = 0; a < caseList.length; a++) {
                let selectCheck = caseList[a].selectCheck || '';
                console.log('test '+ selectCheck);
                if (selectCheck === false || selectCheck === ''){
                    caseList.splice(a, 1);
                }
            }
        }
        console.log(JSON.parse(JSON.stringify(caseList)));
        cmp.find('contactFilterProcess').process(
            'CaseCreateSubmitProc',

            {
                caseList : caseList
            })

    },
    selectCase: function (cmp, event, helper){
        let whichOne = event.getSource().get('v.name');
        let checkboxVar = event.getSource().get('v.checked');
        console.log(checkboxVar);
        let caseList = cmp.get('v.meta.testResponse.dto.caseList') || [];
        if(checkboxVar === true) {
          caseList[whichOne].selectCheck = checkboxVar;
        }
        else(checkboxVar === false)
        {
            caseList[whichOne].selectCheck = checkboxVar;
        }
        console.log(JSON.parse(JSON.stringify(caseList)));

        cmp.set('v.meta.testResponse.dto.caseList', []);
        cmp.set('v.meta.testResponse.dto.caseList', caseList);
    }
});