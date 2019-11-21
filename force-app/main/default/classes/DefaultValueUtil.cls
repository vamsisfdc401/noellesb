public class DefaultValueUtil {

 public static boolean IsFieldAvliable(SObject sobj,String consColoumn) {
 	String objName = String.valueOf(sobj.getsObjectType());
 	return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(consColoumn)!=null;
 }

  public static void populateValues(SObject sobj,String consColoumn,String value) {
  	Schema.DisplayType disType = getDisplayType(sobj,consColoumn);

  		if(Schema.DisplayType.Date == disType) {
  			sobj.put(consColoumn,Date.valueOf(value));
  		} else if(Schema.DisplayType.Double == disType || Schema.DisplayType.Double == disType) {
			sobj.put(consColoumn,Decimal.valueOf(value));
  		}else if(Schema.DisplayType.DateTime == disType) {
  			sobj.put(consColoumn,DateTime.valueOf(value));
  		}else {
  			sobj.put(consColoumn,value);
  		}	
  }

  public static Schema.DisplayType getDisplayType(SObject sobj,String consColoumn) {
 	String objName = String.valueOf(sobj.getsObjectType());
 	return Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(consColoumn).getDescribe().getType();
 }
}