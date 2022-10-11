({
    handleShow: function (cmp, event, helper) {
        var componentName = event.getParam('arguments').componentName;
        var payload = event.getParam('arguments').payload || {};
        var modalAttributes = event.getParam('arguments').modalAttributes || {};

        cmp.set('v.isBusy', true);

        return new Promise($A.getCallback(function(resolve, reject) {

            $A.createComponent(
                componentName,
                payload,
                function (createdComponent, status, errorMessage) {
                    if (status === "SUCCESS") {

                        var modalInstance = {
                            close: $A.getCallback(function(result){
                                resolve(result);
                            }),
                            cancel: $A.getCallback(function(result){
                                reject(result);
                            })
                        };

                        createdComponent.set('v.modalInstance', modalInstance);
                        var footer = createdComponent.get('v.footer');
                        if($A.util.isEmpty(footer) == false){
                            modalAttributes.footer = footer;
                        }

                        modalAttributes.body = createdComponent;
                        modalAttributes.closeCallback = function(){
                            if (payload.closeCallback){
                                payload.closeCallback();
                            }
                        }

                        cmp.find('overlayLib').showCustomModal(modalAttributes).then($A.getCallback(function (overlay) {
                            cmp.set('v.isBusy', false);
                            if (payload.showCallback){
                                payload.showCallback();
                            }
                        }));

                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from the server!")
                    }
                    else if (status === "ERROR") {
                        console.log("Error: " +errorMessage);
                        reject(errorMessage)
                    }
                }
            );

            // $A.createComponent("c:Acquittal", {
            //         applicationId:  cmp.get('v.recordId'),
            //         recordId: event.currentTarget && event.currentTarget.getAttribute && event.currentTarget.getAttribute('id') ?
            //             event.currentTarget.getAttribute('id') :
            //             undefined,
            //         modalInstance: cmp.find("overlayLib")
            //     },
            //     function(content, status) {
            //         if (status === "SUCCESS") {
            //             modalBody = content;
            //             cmp.find('overlayLib').showCustomModal({
            //                 header: "Application Confirmation",
            //                 body: modalBody,
            //                 showCloseButton: true,
            //                 cssClass: "mymodal",
            //                 closeCallback: function() {
            //                     debugger
            //                     // alert('You closed the alert!');
            //                 }
            //             })
            //         }
            //     });
        }));





        //
        //
        //
        // cmp.set("v.modalContent", cmp.get('v.defaultModalContent'));
        //
        // var modalCmp = cmp.find('modal');
        //
        // for(var attr in modalAttributes){
        //     modalCmp.set('v.' + attr, modalAttributes[attr]);
        // }
        //
        // modalCmp.show();
        //
        // // payload.onSubmit = cmp.getReference('c.handleSaveOrSubmit');
        //
        // return new Promise($A.getCallback(function(resolve, reject) {
        //
        //     payload.modalInstance = {
        //         component: cmp,
        //         close: $A.getCallback(function(result){
        //             cmp.find('modal').hide();
        //             resolve(result);
        //         }),
        //         cancel: $A.getCallback(function(result){
        //             cmp.find('modal').hide();
        //             reject(result);
        //         }),
        //         hide: $A.getCallback(function(){
        //             // cmp.set('v.isVisible', false);
        //         }),
        //         show: $A.getCallback(function(){
        //             // cmp.set('v.isVisible', true);
        //         })
        //     };
        //
        //     $A.createComponent(
        //         componentName,
        //         payload,
        //         function (createdComponent, status, errorMessage) {
        //             if (status === "SUCCESS") {
        //                 cmp.set("v.modalContent", createdComponent);
        //             }
        //             else if (status === "INCOMPLETE") {
        //                 console.log("No response from the server!")
        //             }
        //             else if (status === "ERROR") {
        //                 console.log("Error: " +errorMessage);
        //                 reject(errorMessage)
        //             }
        //         }
        //     );
        //
        // }));
    },

    // handleSaveOrSubmit: function (cmp, event, helper) {
    //     cmp.find('modal').hide();
    // }
})