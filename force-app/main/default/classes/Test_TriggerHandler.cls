@isTest
public class Test_TriggerHandler {
    @isTest
    public static void testTriggerHandler(){
        Test.startTest();
    	TriggerHandler t = new TriggerHandler();
        t.context = TriggerHandler.TriggerContext.AFTER_UNDELETE;
        t.isTriggerExecuting = true;
        t.run();
        t.setMaxLoopCount(1);
        t.addToLoopCount();
        t.clearMaxLoopCount();
        //t.bypass('test');
        TriggerHandler.LoopCount tc = new TriggerHandler.LoopCount();
        tc.getCount();
        tc.getMax();
        TriggerHandler.LoopCount tc2 = new TriggerHandler.LoopCount(1);
        tc2.setMax(1);
        tc2.increment();
        tc2.increment();
        tc2.exceeded();
        Test.stopTest();
    }
}