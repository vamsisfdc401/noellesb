global class scheduleCIRFHeadersBatch implements Schedulable {

   global void execute(SchedulableContext SC) {
     Statusupdatecirfheaderbatch J = new Statusupdatecirfheaderbatch(); 
     database.executeBatch(J,200);
  }
}