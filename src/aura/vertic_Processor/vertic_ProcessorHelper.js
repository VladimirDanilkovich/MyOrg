({
    handleBatchProgressComplete: function(cmp, event, helper){
        var totalSynced = cmp.get('v.meta.totalSyncedBookings');

        if(totalSynced > 0){
            cmp.find('notifLib').showToast({
                variant: 'success',
                message: 'Service Bookings have been synced from NDIS.',
                // messageData: [{
                //     label: response.dto.opportunity.Name,
                //     url: '/' + response.dto.opportunity.Id
                // }]
            });
        } else {
            cmp.find('notifLib').showToast({
                variant: 'info',
                message: 'No Service Bookings to sync from NDIS',
                // messageData: [{
                //     label: response.dto.opportunity.Name,
                //     url: '/' + response.dto.opportunity.Id
                // }]
            });
        }

        $A.get('e.force:refreshView').fire();
        cmp.find('modal').close();
    }

});