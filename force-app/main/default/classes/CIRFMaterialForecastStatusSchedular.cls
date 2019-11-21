global class CIRFMaterialForecastStatusSchedular implements Schedulable{
	 global void execute(SchedulableContext sc) {
         System.debug('scheduled job');
         Database.executeBatch(new  CIRFMaterialForecastStatusBatch(), 100);
     }
}