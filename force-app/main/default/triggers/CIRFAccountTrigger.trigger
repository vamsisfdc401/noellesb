trigger CIRFAccountTrigger on Account (before insert) {
	if(Label.CIRF_Triggers_ON_OFF == 'ON'){
        new CIRFAccountTriggerHandler().run();
    }
}