trigger OrderStatusDelete on Orders__c (before delete) {
for(Orders__c ord: Trigger.Old)
if(ord.Status__c !='Draft'){ord.addError('Cannot Delete the Order. Please Select Different Status');}
}