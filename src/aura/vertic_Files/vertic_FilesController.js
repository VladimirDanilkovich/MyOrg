({

    handleInit: function(cmp, event, helper){
        helper.refresh(cmp, event, helper);
    },

    handleUploadFinished: function (cmp, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = JSON.parse(JSON.stringify(event.getParam("files")));

        var event = cmp.getEvent('onFileUpload');
        event.setParams({
            payload: {
                files: uploadedFiles
            }
        });
        event.fire();

        helper.refresh(cmp, event, helper);

        //alert("Files uploaded : " + uploadedFiles.length);
    }

})