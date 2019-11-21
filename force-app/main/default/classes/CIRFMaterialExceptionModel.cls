/**
*    @description   model class for Task object
*    @author Ann Luong
*	 Modification Log
*    10/15/2018 - AL - HEITCIRF-178
*
*/
global with sharing class CIRFMaterialExceptionModel {

	public static list<CIRF_Material_Exceptions__c> CIRFMaterialExceptionsList = new List<CIRF_Material_Exceptions__c>();	
	public static Map<Id, CIRF_Material_Exceptions__c>  CIRFMaterialExceptionsMap = new Map<Id, CIRF_Material_Exceptions__c>();

	public static void createCIRFMaterialException(List<CIRF_Material__c> cmatList, Map<Id, CIRF_Header__c> CIRFHeaderMap) {

		system.debug('CIRFHeaderMap: ' + CIRFHeaderMap);
		List<CIRF_Material_Exceptions__c> cmeList = new List<CIRF_Material_Exceptions__c>();
		for (CIRF_Material__c cmat : cmatList) {
			CIRF_Material_Exceptions__c cme = new CIRF_Material_Exceptions__c();
			//cme.Name = cmat.Name + ' - ' + cmat.Material_Description__c;
			cme.Retailer__c = CIRFHeaderMap.get(cmat.id).Retailer__c;
			cme.Material__c = cmat.Material_Name__c;
			//cme.Start_Date__c = cmat.Exception_Start_Date__c;
			//SJ - 12/26/2018 - HEITCIRF-485
			cme.Start_Date__c = Date.Today();
			//	AL - 01/04/2019 - HEITCIRF-546
			//cme.End_Date__c = cmat.Exception_End_Date__c;
			cme.End_Date__c = CIRFHeaderMap.get(cmat.id).CIRF_End_Date__c;
            
         	if(cmat.Exception_Type__c == '' || cmat.Exception_Type__c == null)
            {
                cme.Exception_Type__c = 'Distribution Only';
            }
            else
            {cme.Exception_Type__c = cmat.Exception_Type__c;}
			
            cme.CIRF_Header__c = cmat.CIRF_Header__c;
			cme.Original_Status__c = getMaterialStatus(cmat, CIRFHeaderMap); 

			//cme.Original_Status__c = cmat.Material_Status__c;  	// Will be replaced with getMaterialStatus()
			cmeList.add(cme);
		}

		insert cmeList;

	}

	public static String getMaterialStatus(CIRF_Material__c cmat, Map<Id, CIRF_Header__c> CIRFHeaderMap) {

		CIRFMaterialExceptionsMap = getActiveMaterialExceptionMap(cmat.Material_Name__c, cmat.CIRF_Header__r.CIRF_Start_Date__c);
		String matStatus;

		if (!CIRFMaterialExceptionsMap.isEmpty() &&	CIRFMaterialExceptionsMap.containsKey(cmat.Material_Name__c) )
			matStatus = CIRFMaterialExceptionsMap.get(cmat.Material_Name__c).Original_Status__c;
		else
			matStatus = cmat.Material_Status__c;

		return matStatus;

	}

	public static map<Id, CIRF_Material_Exceptions__c> getActiveMaterialExceptionMap(Id materialId, date CIRFStartDate) {
		map<Id, CIRF_Material_Exceptions__c> resultMap = new map<Id, CIRF_Material_Exceptions__c>();
		Date currentDate = date.TODAY();

		if (CIRFMaterialExceptionsMap.isEmpty()) {
			try {
         		CIRF_Material_Exceptions__c activeCIRFMatExceptions = [select id, Material__c, Material__r.Material_Status__c, Original_Status__c
																	   from CIRF_Material_Exceptions__c
																	   where Material__c = :materialId
																	   and End_Date__c > :currentDate
																	   order by CreatedDate 
																	   limit 1 ];

        		system.debug('CIRF_Material_Exceptions__c: ' + activeCIRFMatExceptions);
				if (activeCIRFMatExceptions != null)  
					CIRFMaterialExceptionsMap.put(activeCIRFMatExceptions.Material__c, activeCIRFMatExceptions);														   
    		}
			catch (Exception e) {
    		} 
    	}

		return CIRFMaterialExceptionsMap;
	}

	public static Boolean validCIRFMaterialException (Id Material_Id) {

		return false;
	}
	 
}