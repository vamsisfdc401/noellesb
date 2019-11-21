trigger RST_ForecastUpload_Trigger on RST_Forecast_Upload__c (after insert, after update, after delete, after undelete, before insert, before update, before delete) {
    system.debug('running rst upload trigger');
    new RST_ForecastUpload_TriggerHandler().run();

}