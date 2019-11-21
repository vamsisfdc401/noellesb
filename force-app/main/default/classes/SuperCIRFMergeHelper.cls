public class SuperCIRFMergeHelper {

	public static Integer invokeCount = 0;

	public SuperCIRFMergeHelper() 
	{
		invokeCount = 0;
	}

	@InvocableMethod

	public static List<String> mergeCIRFs(List<List<String>> parmList) {
		List<String> returnMessage = new List<String>();
		//List<String> parmList = parameters[0];
		List<String> parmData = parmList[0];

		system.debug('Parm List: ' + parmList.size());
		//system.debug('SuperCIRFHeaderId: ' + parmList[0]);

		Id SuperCIRFHeaderId = getSuperCIRFHeaderIdParameter(parmList[0]);
		system.debug('Super CIRF Id: ' + SuperCIRFHeaderId);

		List<Id> ChildrenCIRFHeaderIdList = getChildrenCIRFHeaderIdParameters(parmList[0]);

		if(Test.isRunningTest()) {
			TriggerHandler.bypass('CIRFMaterialTriggerHandler');
			TriggerHandler.bypass('CIRFHeaderTriggerHandler');
		}

		//	update Super CIRF Material List
		returnMessage.add(updateSuperCIRFMaterials(SuperCIRFHeaderId, ChildrenCIRFHeaderIdList));

		if(Test.isRunningTest()) {
			TriggerHandler.clearbypass('CIRFMaterialTriggerHandler');
			TriggerHandler.clearbypass('CIRFHeaderTriggerHandler');
		}

		//	update children CIRF Header Status to Merged
		CIRFHeaderTriggerHandler.updateMergedCIRFHeaderStatus(SuperCIRFHeaderId, ChildrenCIRFHeaderIdList);

		//	update children Corrugate Status to Merged
		//CIRFCorrugateTriggerHandler.updateMergedCIRFCorrugateStatus(ChildrenCIRFHeaderIdList);

		return returnMessage;

	}

	public static Id getSuperCIRFHeaderIdParameter(List<Id> parmList) {
		return (Id) parmList[0];
	}

	public static List<Id> getChildrenCIRFHeaderIdParameters(List<Id> parmList) {
		List<Id> ChildrenCIRFHeaderIdList = parmList;
		ChildrenCIRFHeaderIdList.remove(0);
		return ChildrenCIRFHeaderIdList;
	}

	public static  string updateSuperCIRFMaterials(Id SuperCIRFHeaderId, List<Id> ChildrenCIRFHeaderIdList) {
		system.debug('Children CIRFHeaderId: ' + ChildrenCIRFHeaderIdList);
		//	get Super CIRF Materials
		List<Id> SuperCIRFHeaderIdList = new List<Id>();
		Map<String, CIRF_Material__c> superCIRFMaterialMap = new Map<String, CIRF_Material__c>();
		
		SuperCIRFHeaderIdList.add(SuperCIRFHeaderId);
		List<CIRF_Material__c> oldSuperCIRFMaterialList = getCIRFMaterials(SuperCIRFHeaderIdList);
		superCIRFMaterialMap = formatCIRFMaterialMap(oldSuperCIRFMaterialList);

		//for (CIRF_Material__c scm : oldSuperCIRFMaterialList) {
		//	superCIRFMaterialMap.put(scm.Material_Number__c, scm);
		//}

		//	get Children CIRF Materials

		List<CIRF_Material__c> childrenCIRFMaterialList = getCIRFMaterials(childrenCIRFHeaderIdList);

		//	Debug code
		for (CIRF_Material__c cm : oldSuperCIRFMaterialList) {
			system.debug (' 1-Super CIRF Header:  ' + cm.CIRF_Header__c + 'Material: ' + cm.material_number__c +  ' CIRFMat Id: ' + cm.Name + ' External Id: ' + cm.External_Id__c);
		}

		//	Perform Merge

		string resultMsg = performMerge(SuperCIRFHeaderId, superCIRFMaterialMap, childrenCIRFMaterialList);
		system.debug('Merge result:  ' + resultMsg);

		return resultMsg;
	}
 		 

	public static List<CIRF_Material__c> getCIRFMaterials(List<Id> CIRFHeaderIdList) {

		List<CIRF_Material__c> resultList = [select  Id, Name,  Height__c, Width__c, Length__c, Confirmed__c, Material_Name__c, 
									Material_Number__c,
									CIRF_Material_Status__c, Suggested_Retail_Price__c, Direct_Retail_Price__c, Account_Retail_Price__c, 
									Promo_Cost__c, Funding_Notes__c, Units_to_Order__c, Replen_Duration__c, Replen_Units__c, 
									Number_of_Regie_Stickers__c, Catalog_vs_VAS__c, Unique_vs_National__c, 
									Needs_Regie_Sticker__c, number_on_Label__c, Multiplier__c, 
									Planning_Approval__c, Customer_Marketing_Approval__c, Creator_Approval__c, Retail_Price_Sticker__c, 
									Revision__c, CIRF_Header__c, 
									External_Id__c, 
									RIM_Approval__c, Planning_Forecast_Approval__c, Corrugate_Units__c, 
									RIM_Approval_Reason__c, Base_Material_Name__c, 
									Version_Material_Name__c, Exception_Type__c, Exception_Start_Date__c, Exception_End_Date__c, 
									Split_Forecast__c, Old_Material_No_Changed__c, Material_to_Forecast__c, Customer_Marketing_Approval_Reason__c, 
									Planning_Approval_Reason__c,  
									Old_Material_Number_Name__c,  Approve_RIM__c, 
									Reject_RIM__c,  Fully_Built__c, Discount_Type__c, Comments__c, French_Required__c 
									from CIRF_Material__c
									where CIRF_Header__c in : CIRFHeaderIdList
									and CIRF_Material_Status__c != 'Cancelled'];

		return resultList;
	}

	public static String performMerge(Id SuperCIRFHeaderId, Map<String, CIRF_Material__c> superCIRFMaterialMap, List<CIRF_Material__c> childrenCIRFMaterialList) {
		
		//invokeCount++;
		system.debug('perform Merge: ' + invokeCount);
		List<CIRF_Material__c> oldSuperCIRFMaterialList = new List<CIRF_Material__c>();
		List<CIRF_Material__c> insSuperCIRFMaterialList = new List<CIRF_Material__c>();
		List<Id> superCIRFHeaderIdList = new List<Id>();
		superCIRFHeaderIdList.add(SuperCIRFHeaderId);
		List<CIRF_Material__c> updSuperCIRFMaterialSet = getCIRFMaterials(superCIRFHeaderIdList);

		Map<String, CIRF_Material__c> updSuperCIRFMaterialMap = formatCIRFMaterialMap(updSuperCIRFMaterialSet);
		Map<String, CIRF_Material__c> insSuperCIRFMaterialMap = new Map<String, CIRF_Material__c>();

		String updSuperCIRFMaterialMsg = 'Material(s) Updated:  ';
		String insSuperCIRFMaterialMsg = '';

		for (CIRF_Material__c cm : childrenCIRFMaterialList) {
			//system.debug (' 2-CIRF Header:  ' + cm.CIRF_Header__c + 'Material: ' + cm.material_number__c +  ' CIRFMat Id: ' + cm.Name + ' External Id: ' + cm.External_Id__c);
			printList('superCIRFMatList', superCIRFMaterialMap.values());
			CIRF_Material__c scm = new CIRF_Material__c();

			if (!updSuperCIRFMaterialMap.isEmpty() && updSuperCIRFMaterialMap.containsKey(cm.Material_Number__c)) {
				CIRF_Material__c superCIRFMaterial = updSuperCIRFMaterialMap.get(cm.Material_Number__c);
				scm = UpdateCIRFMatFields(superCIRFMaterial, cm);
				system.debug('???update: ' + scm + ' before: ' + cm);
				//printList('upd CIRFMat: ', updSuperCIRFMaterialMap.values());
			}
			else {
				scm = formatInsertSuperCIRFMaterialFields(SuperCIRFHeaderId, cm);
				system.debug('???insert: ' + scm);
			}
			updSuperCIRFMaterialMap.put(scm.Material_Number__c, scm);
			//printList('new CIRFMat:', updSuperCIRFMaterialMap.values());				

			updSuperCIRFMaterialMsg = formatReturnMsg(updSuperCIRFMaterialMsg,scm);

		}	

		//	Debug code
		//for (CIRF_Material__c cm: updSuperCIRFMaterialMap.values()) {
		//	system.debug('External Id: ' + cm.External_Id__c + ' Units to Order: ' + cm.Units_to_Order__c + ' Replen Units: ' + cm.Replen_Units__c);
		//}

		 system.debug('upd List: ' + updSuperCIRFMaterialMap.values());
		 Schema.SObjectField externalId = CIRF_Material__c.Fields.External_Id__c;
		 
		 if (updSuperCIRFMaterialMap != null) {
		 	Database.UpsertResult[] srList = Database.upsert(updSuperCIRFMaterialMap.values(), externalId, false);
		 	for (Database.UpsertResult sr : srList) {
		 		if (sr.isSuccess())
		 			System.Debug('Good update');
		 		else
		 			for (Database.Error err : sr.getErrors()) {
		 				System.debug('Update Error: ' + err.getStatusCode() + err.getMessage() + ' Fields: ' + err.getFields());
		 			}
		 	}
		 }


		 return updSuperCIRFMaterialMsg + '\n' + insSuperCIRFMaterialMsg;
	}

	private static void printList(String listName, List<CIRF_Material__c> matList) {
		Integer i = 1;
		for (CIRF_Material__c cm : matList) {
			System.Debug(listName + '- ' + i +  ' Material #: ' + cm.Material_Number__c + ' External Id: ' + cm.External_Id__c + ' Header: ' + cm.CIRF_Header__c);
			i = i + 1;
		}
	}

	private static Map<String, CIRF_Material__c> formatCIRFMaterialMap(List<CIRF_Material__c> CIRFMaterialList) {
		Map<String, CIRF_Material__c> CIRFMatMap = new Map<String, CIRF_Material__c>();
		for (CIRF_Material__c m : CIRFMaterialList) {
			CIRFMatMap.put(m.Material_Number__c, m);
		}
		return CIRFMatMap;
	}

	private static CIRF_Material__c formatInsertSuperCIRFMaterialFields(Id SuperCIRFHeaderId, CIRF_Material__c cm) {
		cm.id = null;
		//cm.name = null;
		cm.CIRF_Material_Status__c = 'Draft';
		cm.CIRF_Header__c = SuperCIRFHeaderId;
		cm.External_Id__c = SuperCIRFHeaderId + '-' + cm.Material_Number__c;
		return cm;
	}


	private static String formatReturnMsg(String resultMsg, CIRF_Material__c cm) {
		resultMsg += cm.Material_Number__c;
		resultMsg += '|';
		return resultMsg;
	}

	public static CIRF_Material__c UpdateCIRFMatFields(CIRF_Material__c superCIRFMaterial, CIRF_Material__c childCIRFMaterial) {

		if (superCIRFMaterial.Replen_Units__c == null)
			superCIRFMaterial.Replen_Units__c = 0;

		if (superCIRFMaterial.Units_to_Order__c == null)
			superCIRFMaterial.Units_to_Order__c = 0;

		if (childCIRFMaterial.Replen_Units__c == null)
			childCIRFMaterial.Replen_Units__c = 0;

		if (childCIRFMaterial.Units_to_Order__c == null)
			childCIRFMaterial.Units_to_Order__c = 0;


		superCIRFMaterial.Replen_Units__c += childCIRFMaterial.Replen_Units__c;
		superCIRFMaterial.Units_to_Order__c += childCIRFMaterial.Units_to_Order__c;		
		superCIRFMaterial.Suggested_Retail_Price__c = 0;
		superCIRFMaterial.Direct_Retail_Price__c = 0; 
		superCIRFMaterial.Account_Retail_Price__c = 0;									
		superCIRFMaterial.Promo_Cost__c = 0;
		superCIRFMaterial.CIRF_Material_Status__c = 'Draft';


		return superCIRFMaterial;
	}

	public static void remergeCIRFs(List<Id> SuperCIRFHeaderIdList, List<Id> childrenCIRFHeaderIdList) {
		
		List<CIRF_Material__c> superCIRFMaterialList = getCIRFMaterials(SuperCIRFHeaderIdList);

		for (CIRF_Material__c cm : superCIRFMaterialList) {
			cm.CIRF_Material_Status__c = 'Cancelled';
		}

		if (!superCIRFMaterialList.isEmpty())
			update superCIRFMaterialList;

		//delete superCIRFMaterialList;

		updateSuperCIRFMaterials(SuperCIRFHeaderIdList[0], childrenCIRFHeaderIdList);

	}

	public static void cancelSuperCIRFMaterials(List<Id> SuperCIRFHeaderIdList, List<String> cancelMatList) {
		List<CIRF_Material__c> cancelSuperCIRFMatList = [select id, CIRF_Material_Status__c 
														from CIRF_Material__c
														where CIRF_Header__c in : SuperCIRFHeaderIdList
														and Material_Name__c in : cancelMatList];
		for (CIRF_Material__c cm : cancelSuperCIRFMatList) {
			cm.CIRF_Material_Status__c = cm.CIRF_Material_Status__c;
		}
		update cancelSuperCIRFMatList;


	}


}