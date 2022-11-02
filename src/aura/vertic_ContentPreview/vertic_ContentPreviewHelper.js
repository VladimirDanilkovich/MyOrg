({
    getFile: function (cmp, event, helper) {

        var content = cmp.getContent();
        var fileName = event.getParam('arguments').fileName;
        var binary = window.atob(content.replace(/ /g, ''));
        var len = binary.length;
        var buffer = new ArrayBuffer(len);
        var view = new Uint8Array(buffer);
        for (var i = 0; i < len; i++) {
            view[i] = binary.charCodeAt(i);
        }
        var b = new Blob([view], {type: "application/pdf"});
        return new File([b], fileName, {type: "application/pdf"});

    },

    // previewFile: function (fileId) {
    //     var fireEvent = $A.get('e.lightning:openFiles');
    //     fireEvent.fire({
    //         recordIds: [fileId]
    //     });
    // }
})