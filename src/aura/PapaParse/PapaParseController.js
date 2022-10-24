({
    handleScriptLoaded: function(cmp, event, helper){

    },

    handleParseCSV: function(cmp, event, helper){
        var csvString = event.getParam('arguments').csvString;
        var config = event.getParam('arguments').config;
        return Papa.parse(csvString, config);
    }
})