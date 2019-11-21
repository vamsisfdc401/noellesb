/*****************************************************************************************
Class Name: ReleaseMaterialBulkApprovalHandler
Purpose: This is the Class responsible to submit for approval of all the materials in chain under the Release.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             27/07/2016           Suman Kundu              Initial Development
******************************************************************************************/
global class ReleaseMaterialBulkApprovalHandler
{
    private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009'};
    private static Set<Id> requestMaterialIds = new Set<Id>();
    private static Set<Id> componentIds = new Set<Id>();
    private static Set<Id> displayVehicleIds = new Set<Id>();
    private static Set<Id> multiPackIds = new Set<Id>();
    private static Integer approveMaterialCount;
    private static Set<Id> validM_CLSet=new Set<Id>();
    private static Set<Id> validM_CLSet1=new Set<Id>(); //USST-2465
    
    // Following structure is used to return Aprroval Result to method caller.
    private class ApprovalResult
    {
        private Boolean isSuccess;
        private String errorMessage;
        
        private ApprovalResult()
        {
            isSuccess = true;
            errorMessage = '';
        }
    }
    /************************************
    Method Name: checkMultipack
    Purpose: Following method check whether material is multipack and contains any bom items or no accordingly return integer value.
    *************************************/
    
    webservice static Integer checkMultipack(Id releaseId){
         Set<Id> materialId = new set<Id>();
         Set<Id> multipackidscheck=new set<Id>();
         Map<Id,List<Bom_item__c>>bItemMap=new Map<Id,List<Bom_item__c>>();
         Map<Id,List<Bom_item__c>>bItemMap1=new Map<Id,List<Bom_item__c>>(); //USST-2465
         List<Id> tempBomList = new List<Id>(); //USST-2465
         Integer checkMultipackcount=0;
         
         
        list<Release_Material__c> releaseMat = [select id,Material__c from Release_Material__c where Release__c =:releaseId]; 
        
       for(Release_Material__c each: releaseMat){
          materialId.add(each.Material__c ); 
        }
            
       for(Material__c mat:[Select id from Material__c where item_type__c='M (Multipack)' and material_status__c='draft' and (item_code__c='CL - COLLECTION PACK' or item_code__c='MT - MULTI-TITLE') and id in:materialId]){ //USST-2465
           multipackidscheck.add(mat.id);
       }

       //USST-2465 start
       for(Bom_item__c bItem:[Select id,material__c,Material_Component__c from Bom_item__c where Material_Component__c in:multipackidscheck and material__r.Item_type__c='D (Display Vehicle)']){
           System.debug('bItem.id ::'+bItem.id);
           if (bItem != null){
                for(Bom_Item__c bItem1 : [Select id,Material_Component__c from Bom_Item__c where material__c =: bItem.Material_Component__c and Material_Component__r.material_type__c ='FERT']){
                    tempBomList.add(bItem1.id);
               }
           }
           if (tempBomList.isEmpty()) {
                validM_CLSet1.add(bItem.Material_Component__c);
            }
       }
       if (multipackidscheck.size()>0 && validM_CLSet1.size()>0){
           checkMultipackcount=0;
       }
       //USST-2465 end
       for(Bom_item__c bItem:[Select id,material__c from Bom_item__c where material__c in:multipackidscheck and Material_Component__r.material_type__c='FERT']){
           if(bItemMap.containsKey(bItem.material__c)){
                  bItemMap.get(bItem.material__c).add(bItem);
           }
           else{
               bItemMap.put(bItem.material__c,new List<Bom_item__c>{bItem});
               validM_CLSet.add(bItem.material__c);
           }
       }

       if(multipackidscheck.size()>0 && (multipackidscheck.size()-validM_CLSet1.size())>0){ //USST-2465
           If(bItemMap==null && multipackids.size()>0){
               checkMultipackcount=1;
           }else if(bItemMap!=null && multipackidscheck.size()-bItemMap.size()>0){
               checkMultipackcount=1;
           }
       }
       
       return checkMultipackcount;
    }
    
    /************************************
    Method Name: checkDisplayVehicle
    Purpose: Following method check whether material is display vehicle and it has child with a material number or not.
    *************************************/
    
    webservice static Integer checkDisplayVehicle(Id releaseId){
         Set<Id> materialId = new set<Id>();
         Set<Id> displayVehicleidscheck=new set<Id>();
         List<Bom_Item__c>displayVehicleBOMs = new List<Bom_Item__c>();
         List<Bom_Item__c>displayVehicleBOMsNew = new List<Bom_Item__c>(); // USST-2239
         Integer checkDisplayVehiclecount=0;
         
         
        list<Release_Material__c> releaseMat = [select id,Material__c from Release_Material__c where Release__c =:releaseId]; 
        
       for(Release_Material__c each: releaseMat){
          materialId.add(each.Material__c ); 
        }
            
       for(Material__c mat:[Select id from Material__c where item_type__c='D (Display Vehicle)' and material_status__c='draft' and id in:materialId]){
           displayVehicleidscheck.add(mat.id);
       }
       if (displayVehicleidscheck.size() > 0) {
           // USST-2239 start
           displayVehicleBOMsNew = [Select id,material__c from Bom_item__c where material__c in:displayVehicleidscheck];
           if(displayVehicleBOMsNew.size()==0){
               checkDisplayVehiclecount = -1;
           }
           // USST-2239 end
           else {
               displayVehicleBOMs = [Select id,material__c from Bom_item__c where material__c in:displayVehicleidscheck and Material_Component__r.material_status__c='Processed in SAP' and Material_Component__r.material_number__c<>''];
               if(displayVehicleBOMs.size()==0){ 
                   checkDisplayVehiclecount++;
               }
           }
       }
       return checkDisplayVehiclecount;
    }   
    
        
    // Following method checks whether all the required SAP fields are populated or not.
    webservice static String checkSAPFieldsComplete(Id releaseId){
   
        ApprovalResult result = new ApprovalResult();
        Id universalFinishedGoodRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('Universal Finished Good').getRecordTypeId();
        Id generalRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        Set<Id> materialId = new set<Id>();
        Set<Id> processingMaterialIds = new Set<Id>();
        // Querying all the Material and child objects for required SAP fields.
        system.debug('=============releaseId===='+releaseId);
       
       list<Release_Material__c> releaseMat = [select id,Material__c from Release_Material__c where Release__c =:releaseId]; 
        
       for(Release_Material__c each: releaseMat){
          materialId.add(each.Material__c ); 
        }
      system.debug('=============materialId===='+materialId);  
      
       List<Material__c> currentMaterial = [Select id,Street_Date__c, Material_Type__c,Material_Status__c ,Item_Code__c, Item_Type__c,Format__c,Pre_Order_Close_Date__c,
                                                    Technical_Format__c,Product_Class__c,Title_Source__c, TM_Version_Lookup__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,
                                                    Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,
                                                    Xplant_Material_Status__c,Xplant_Valid_From__c,Gross_Weight__c,Net_Weight__c,Weight_Unit__c,MPM_Issue__c, 
                                                    Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,
                                                    Purchase_Value_Key__c, Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,
                                                    Selection_Reference_Number__c, Order_Unit__c, Financial_Owner__c,Component_Type__c,Release__c,
                                                    BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,Layer__c,Valid_From__c,Plant__c,SGENNO_ReadOnly__c,Theatrical_Release_Date__c,Title__c,Sales_Planning_Group__c from Material__c where Id =:materialId AND Deletion_Flag__c=:false and (material_status__c='Draft' or material_status__c='Sent Back')]; // Added TM Version field for usst-2387 //USST-3133
        
       
       
        List<Valuation__c> relatedValuations = [Select Material__c,id,Valuation_Area__c,Valuation_Class__c,Price_Unit__c, Standard_Price__c,Origin_Group__c, 
                                                 Pricing_Control__c From Valuation__c where Material__c =:materialId];
                                                       
        List<Classification__c> relatedClassifications= [Select Material__c,id,Packaging_Type_US__c, Regie_Sticker_for_Canada__c,RecordType.Name,Label_Code__c,Aspect_Ratio__c,
                                                        Genre_US__c 
                                                                From Classification__c where Material__c =:materialId];
                                                                
        List<Plant__c> relatedPlants= [Select Material__c,id,Plant__c, Availability_Check__c, Profit_Center__c, Purchasing_Group__c, MRP_Controller__c,MRP_Group__c,
                                              Plant_Specific_Matl_Status__c, MRP_Type__c,ABC_Indicator__c, Lot_Size__c, Reorder_Point__c,Carton_Count__c,
                                              Min_Lot_Size__c, Max_Lot_Size__c, Fixed_Lot_Size__c, Max_Stock_Level__c, Rounding_Value__c,Safety_Stock__c,
                                              Special_Procurement__c, Plnd_Dely_time__c, Stor_Loc_EP__c, Schedule_Margin_Key__c, Period_Ind__c,Prod_Storage_Location__c,
                                              Splitting_Ind__c, Bwd_Cons_Period__c, Fwd_Cons_Period__c, GR_Processing_Time__c, Mixed_MRP__c,Consumption_Mode__c,
                                              Indv_Colle__c, Requirements_Grouping__c, Valid_From__c, Procurement_Type__c,Component_Scrap_Percentage__c,Loading_Group__c,
                                              Strategy_Group__c,Coverage_Prof__c From Plant__c where Material__c =:materialId AND Deletion_Flag__c= FALSE];
                                              
        List<Sales__c> relatedSales= [Select Material__c,id, Tax_Indicator__c, Operations_Group__c, Tax_Jurisdiction_Code__c, Item_Category_Group__c,Distribution_Channel__c,
                                     Deliver_Plant__c,Original_Release_Date__c,Volume_Rebate_Group__c,Valid_From__c,
                                     D_Chain_Spec__c,Sales_Unit__c,Material_Group_1__c,Material_Group_2__c,Announcement_Date_US__c,
                                     Material_Group_3__c,Material_Group_4__c,Material_Group_5__c,Material_Pricing_Group__c,Solicitation_Date__c,
                                     Material_Statistic_Group__c,PST_Base_GST_CDN__c,GST_Canada__c,Territory__c,PST_Canada__c,City_Sales_Tax__c, County_Sales_Tax__c, Sales_Org__c From Sales__c where Material__c =:materialId];
       
        list<BOM_Item__c> relatedAllBOM = [Select id,Material__c,Material_Component__c,Component_Quantity__c,Item_Category__c,Valid_From__c,Production_Flag__c from BOM_Item__c Where Material__c =:materialId];  
        Boolean dealMissing = false; //usst-2477
        Boolean titleSourceMissing = false; //usst-2387
        Boolean tmVersionMissing = false; //usst-2387
     for(Material__c eachMat : currentMaterial){   
       if(eachMat.Material_Type__c!=null){
           //////usst-2477 --- start
          if(eachMat.Item_Type__c == 'S (Single)' && eachMat.Title__c != null && (eachMat.Deal_ID__c == null || eachMat.Deal_ID__c == '')){
              dealMissing = true;
              continue;
          }
          //////usst-2477 --- end
          
          //////usst-2387 --- start
          if(eachMat.Item_Type__c == 'S (Single)' && eachMat.Title__c != null && (eachMat.Title_Source__c == null || eachMat.Title_Source__c == '')){
              titleSourceMissing = true;
              continue;
          }

          if(eachMat.Item_Type__c == 'S (Single)' && eachMat.Title__c != null && eachMat.TM_Version_Lookup__c == null){
              tmVersionMissing = true;
              continue;
          }
          //////usst-2387 --- end
          
        if(((eachMat.Material_Type__c=='FERT' && eachMat.Format__c != '08 - EST (ELECTRONIC SELL THRU)') && 
                    (((eachMat.Street_Date__c !=Null && eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null  && eachMat.Pre_Order_Close_Date__c != Null &&
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null && (eachMat.Layer__c !=Null || (eachMat.Layer__c ==Null && (eachMat.Format__c=='10 - HD HYBRID (DUAL FORMAT) DNU' ||
                   eachMat.Format__c == '13 - HD VOD' || eachMat.Format__c == '14 - HD EST' || eachMat.Format__c == '15 - DVDR' || 
                   eachMat.Format__c == '17 - BD-R' || eachMat.Format__c == '18 - BD-R COMBO PACK' || eachMat.Format__c == '98 - GWP'))) &&  
                    eachMat.Valid_From__c != Null && eachMat.Title__c!=null && eachMat.TM_Status__c!=null &&
                    eachMat.Industry_Sector__c !=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null ) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c!='BF - BABY FERT')
                    
          ||((eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null  &&
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null && (eachMat.Layer__c !=Null || (eachMat.Layer__c ==Null && (eachMat.Format__c=='10 - HD HYBRID (DUAL FORMAT) DNU' ||
                   eachMat.Format__c == '13 - HD VOD' || eachMat.Format__c == '14 - HD EST' || eachMat.Format__c == '15 - DVDR' || 
                   eachMat.Format__c == '17 - BD-R' || eachMat.Format__c == '18 - BD-R COMBO PACK' || eachMat.Format__c == '98 - GWP'))) &&  
                    eachMat.Valid_From__c != Null && eachMat.Title__c!=null && eachMat.TM_Status__c!=null &&
                    eachMat.Industry_Sector__c !=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null ) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c=='BF - BABY FERT')          
                    
                    )
            || ((eachMat.Material_Type__c=='FERT' && eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)') &&((eachMat.Street_Date__c !=Null && eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null  && eachMat.Pre_Order_Close_Date__c != Null &&
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null &&  
                    eachMat.Valid_From__c != Null && eachMat.Title__c!=null && eachMat.TM_Status__c!=null &&
                    eachMat.Industry_Sector__c !=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null ) && eachMat.Item_Type__c=='S (Single)')       
                        
          || (((eachMat.Item_Type__c=='D (Display Vehicle)')||(eachMat.Item_Type__c=='M (Multipack)')) && (eachMat.Street_Date__c !=Null && eachMat.Base_Unit_of_Measure__c!=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c!=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null &&  eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null  && ((eachMat.Product_class__c!=null && eachMat.Item_Type__c=='D (Display Vehicle)') ||eachMat.Item_Type__c=='M (Multipack)') &&//RE-28 Added Product Class
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null &&  
                    eachMat.Valid_From__c !=Null && eachMat.Pre_Order_Close_Date__c != Null &&
                    eachMat.Industry_Sector__c!=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null)) 
                    
                    ))
                        
           || (eachMat.Material_Type__c!='FERT' && (eachMat.Division__c!=null && eachMat.Xplant_Material_Status__c!=null &&
                  eachMat.Gross_Weight__c!=null && eachMat.Net_Weight__c!=null && eachMat.Weight_Unit__c!=null && eachMat.Transportation_Group__c !=null &&
                  eachMat.Industry_Sector__c!=null && eachMat.Item_Code__c !=null && eachMat.Item_Type__c!=Null && eachMat.General_Item_Category_Group__c!=null && eachMat.Material_Group__c !=null ))
           )
            {
                 Boolean valuationsOk = true;
                 Boolean salesOk = true;
                 Boolean classificationsOk = true;
                 Boolean plantsOk = true;
                 Boolean BOMOk = true;
                 if(relatedValuations.size()>0){
                     for(Valuation__c eachValuation: relatedValuations){
                        if(eachValuation.Material__c == eachMat.Id){
                         if ((eachMat.Material_Type__c=='FERT'&& (eachValuation.Valuation_Area__c==NULL || eachValuation.Valuation_Class__c==NULL || eachValuation.Price_Unit__c==NULL 
                             || eachValuation.Standard_Price__c==NULL || eachValuation.Origin_Group__c==NULL || eachValuation.Pricing_Control__c==Null))
                             ||(eachMat.Material_Type__c!='FERT'  && (eachValuation.Valuation_Area__c==NULL || eachValuation.Valuation_Class__c==NULL || eachValuation.Price_Unit__c==NULL 
                                 || eachValuation.Standard_Price__c==NULL || (eachValuation.Origin_Group__c==NULL && eachMat.Material_Type__c!='Z009') || eachValuation.Pricing_Control__c==Null)) ){
                             valuationsOk = false;
                             break;
                         }
                       }  
                     }
                 }
                 
             if(relatedClassifications.size()>0){
             for(Classification__c eachClassification : relatedClassifications){
                   if(eachClassification.Material__c == eachMat.Id){

                  }   
             }
             }
             
             if(relatedPlants.size()>0){
             for(Plant__c eachPlant: relatedPlants){
             if(eachPlant.Material__c == eachMat.Id){
                 if ((eachMat.Material_Type__c=='FERT' && (eachPlant.Valid_From__c == Null || eachPlant.Plant__c== Null || eachPlant.Availability_Check__c == Null || eachPlant.MRP_Type__c == Null ||
                        eachPlant.ABC_Indicator__c == Null || eachPlant.Lot_Size__c == Null ||  eachPlant.Max_Lot_Size__c == Null ||
                        eachPlant.Max_Stock_Level__c == Null || eachPlant.Special_Procurement__c == Null ||
                        eachPlant.Schedule_Margin_Key__c == Null || eachPlant.Schedule_Margin_Key__c == Null || eachPlant.Period_Ind__c == Null ||
                        eachPlant.Fwd_Cons_Period__c == Null || eachPlant.GR_Processing_Time__c == Null || eachPlant.Mixed_MRP__c == Null ||
                        eachPlant.Requirements_Grouping__c == Null || eachPlant.Profit_Center__c == Null || eachPlant.Purchasing_Group__c == Null || eachPlant.MRP_Controller__c == Null || eachPlant.Min_Lot_Size__c  == Null || eachPlant.Rounding_Value__c == Null || eachPlant.Plnd_Dely_time__c == Null ||
                        eachPlant.Stor_Loc_EP__c == Null || eachPlant.Splitting_Ind__c == Null || eachPlant.Bwd_Cons_Period__c == Null ||
                        eachPlant.Indv_Colle__c == Null || eachPlant.Consumption_Mode__c==Null || 
                        eachPlant.Procurement_Type__c==Null))
                    
                     ||(eachMat.Material_Type__c!='FERT' &&(eachPlant.Safety_Stock__c == Null || eachPlant.Valid_From__c == Null || eachPlant.MRP_Controller__c == Null ||
                        eachPlant.Purchasing_Group__c == Null || eachPlant.Plant_Specific_Matl_Status__c == Null || eachPlant.MRP_Type__c == Null ||
                        eachPlant.Max_Lot_Size__c == Null ||
                        eachPlant.Max_Stock_Level__c == Null || eachPlant.Stor_Loc_EP__c == Null || eachPlant.Schedule_Margin_Key__c == Null ||
                        eachPlant.Period_Ind__c == Null || eachPlant.Bwd_Cons_Period__c == Null || eachPlant.Fwd_Cons_Period__c == Null ||
                        eachPlant.GR_Processing_Time__c == Null || eachPlant.Mixed_MRP__c == Null || eachPlant.Requirements_Grouping__c == Null ||
                        eachPlant.Plant__c == Null || eachPlant.Min_Lot_Size__c == Null ||eachPlant.Plnd_Dely_time__c == Null ||
                        eachPlant.Component_Scrap_Percentage__c == Null || eachPlant.Lot_Size__c == Null || eachPlant.Rounding_Value__c == Null ||
                        eachPlant.Availability_Check__c == Null || (eachPlant.Splitting_Ind__c == Null && eachMat.Material_Type__c!='Z009') || eachPlant.Profit_Center__c == Null ||
                        eachPlant.Procurement_Type__c==Null))
                         ){
                         plantsOk = false;
                         break;
                     }
                 }    
             }
             }
             if(relatedSales.size()>0){
             for(Sales__c eachSales : relatedSales){
               if(eachSales.Material__c == eachMat.Id){
                if ((eachMat.Material_Type__c=='FERT' && (eachSales.Distribution_Channel__c == Null ||
                        eachSales.Deliver_Plant__c == Null ||
                        (eachSales.Territory__c=='US' && (eachSales.Tax_Jurisdiction_Code__c == Null ||
                         eachSales.County_Sales_Tax__c == Null ||
                         eachSales.City_Sales_Tax__c == Null))||
                        eachSales.Tax_Indicator__c == Null ||
                        eachSales.Item_Category_Group__c == Null ||
                        eachSales.Sales_Org__c == Null ||
                        eachSales.D_Chain_Spec__c == Null ||
                        eachSales.Valid_From__c == Null ||
                        eachSales.Operations_Group__c == Null ||
                        eachSales.Material_Group_3__c == Null ||
                        eachSales.Material_Group_5__c == Null || 
                        (eachSales.Territory__c=='CDN' && (eachSales.GST_Canada__c == Null ||
                        eachSales.PST_Canada__c == Null ||
                        eachSales.PST_Base_GST_CDN__c == Null)) || 
                        eachSales.Material_Statistic_Group__c==Null))
                    
                     ||(eachMat.Material_Type__c!='FERT' && (eachSales.Distribution_Channel__c == Null ||
                            eachSales.D_Chain_Spec__c == Null ||
                            eachSales.Operations_Group__c == Null ||
                           (eachSales.Territory__c=='US' && (eachSales.Tax_Jurisdiction_Code__c == Null ||
                            eachSales.County_Sales_Tax__c == Null||
                            eachSales.City_Sales_Tax__c == Null))||
                            eachSales.Sales_Org__c == Null ||
                            eachSales.Tax_Indicator__c == Null ||
                            eachSales.Item_Category_Group__c == Null ||
                            (eachSales.Territory__c=='CDN' && (eachSales.GST_Canada__c == Null||
                            eachSales.PST_Canada__c == Null||
                            eachSales.PST_Base_GST_CDN__c == Null)) || 
                            eachSales.Material_Statistic_Group__c==Null))){
                         salesOk = false;
                         break;
                     }
                 }    
             }
           }
          system.debug('=============eachMat.Id=='+eachMat.Id);
          system.debug('=============valuationsOk =='+valuationsOk ); 
          system.debug('=============salesOk =='+salesOk );
          system.debug('=============plantsOk =='+plantsOk );
          system.debug('=============classificationsOk =='+classificationsOk );
          system.debug('=============BOMOk =='+BOMOk );  
           
          if(valuationsOk && salesOk && plantsOk && classificationsOk){
            //USST-3133 --- start
            if (eachMat.Label_Code__c!='59 - Paramount') {
                requestMaterialIds.add(eachMat.Id);       
                if(childMaterialTypes.contains(eachMat.Material_Type__c))
                    componentIds.add(eachMat.Id);
                else
                {
                    processingMaterialIds.add(eachMat.Id);
                    if(eachMat.Item_Type__c == 'M (Multipack)')
                        multiPackIds.add(eachMat.Id);
                    else if(eachMat.Item_Type__c == 'D (Display Vehicle)')
                        displayVehicleIds.add(eachMat.Id);
                }
            }
            else if(eachMat.Label_Code__c=='59 - Paramount'){
                if (eachMat.MPM_Issue__c!='' && eachMat.MPM_Issue__c!=null) {
                    if (eachMat.Item_Type__c == 'D (Display Vehicle)' || childMaterialTypes.contains(eachMat.Material_Type__c)) {
                        requestMaterialIds.add(eachMat.Id);        
                        if(childMaterialTypes.contains(eachMat.Material_Type__c))
                            componentIds.add(eachMat.Id);
                        else
                        {
                            processingMaterialIds.add(eachMat.Id);
                            if(eachMat.Item_Type__c == 'M (Multipack)')
                                multiPackIds.add(eachMat.Id);
                            else if(eachMat.Item_Type__c == 'D (Display Vehicle)')
                                displayVehicleIds.add(eachMat.Id);
                        }
                    }
                    else if (eachMat.Sales_Planning_Group__c != '' && eachMat.Sales_Planning_Group__c != null) {
                        requestMaterialIds.add(eachMat.Id);        
                        if(childMaterialTypes.contains(eachMat.Material_Type__c))
                            componentIds.add(eachMat.Id);
                        else
                        {
                            processingMaterialIds.add(eachMat.Id);
                            if(eachMat.Item_Type__c == 'M (Multipack)')
                                multiPackIds.add(eachMat.Id);
                            else if(eachMat.Item_Type__c == 'D (Display Vehicle)')
                                displayVehicleIds.add(eachMat.Id);
                        }
                    }
                }
            }
            //USST-3133 --- end
             }         
            }
          }
         }

        // Added for RE-62
         Set<Id> allChildMatIds = new Set<Id>();
         Set<Id> rootMatIds = materialId.clone();
         // Finds material Ids that are not root in the Release.
         for(Bom_Item__c bom : relatedAllBOM)
         {
             if(bom.Material_Component__c != null)
                 allChildMatIds.add(bom.Material_Component__c);
         }
         // Removing all childs to get root materials only.
         rootMatIds.removeAll(allChildMatIds);
         MultipackDefaultingOnSubmitHandler.updateMultipackInTree(rootMatIds);
       
        // Submit for Approval.
       system.debug('=========displayVehicleIds==='+displayVehicleIds); 
        submitMaterialHierarchyForApproval();

       if(((currentMaterial.size()-requestMaterialIds.size())>0) || dealMissing || titleSourceMissing || tmVersionMissing){ //usst-2477 and usst-2387
           return 'false';
       }
       else{
          return 'true';
       }  
    }
     
        
    // This method handles the business logic to submit materials for approval according to its material type and other constraint.
    @testVisible private static void submitMaterialHierarchyForApproval()
    {
        List<Material__c> updateableMaterials = new List<Material__c>();
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        approveMaterialCount = 0;
        
        Map<Id,List<Id>>compMap=new Map<Id,List<Id>>();
        Id materialRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        
        system.debug('=========displayVehicleIds 1==='+displayVehicleIds);
        Map<Id, Material__c> materialDisplayMap = new Map<Id, Material__c>([SELECT Id,Item_Code__c,Selection_Reference_Number__c, 
                                                                            (SELECT Id FROM BOM_Items__r  
                                                                             WHERE Material_Component__r.Material_Type__c='FERT' AND Material_Component__r.Material_Number__c!='' AND
                                                                                   Material_Component__r.Material_Number__c != null) 
                                                                             FROM Material__c
                                                                             WHERE Id IN :displayVehicleIds and label_code__c!='87 - JOINT CORR/MULTI-STUDIO']);
        Map<Id, Material__c> materialJCMap = new Map<Id, Material__c>([SELECT Id,Item_Code__c,Selection_Reference_Number__c, 
                                                                            (SELECT Id FROM BOM_Items__r  
                                                                             WHERE Material_Component__r.Material_Type__c='FERT')                                                                                    
                                                                             FROM Material__c
                                                                             WHERE Id IN :displayVehicleIds and label_code__c='87 - JOINT CORR/MULTI-STUDIO']);                                                                             
        Map<Id, Material__c> materialMultiPackMap = new Map<Id, Material__c>([SELECT Id,item_type__c,item_code__c, (SELECT Material_Component__r.Material_type__c,Material_Component__r.Material_status__c,
                                                                                Material_Component__r.item_code__c FROM BOM_Items__r where Material_Component__r.material_type__c='FERT') 
                                                                              FROM Material__c
                                                                              WHERE Id IN :multiPackIds]);
        Map<Id, Material__c> componentMap = new Map<Id, Material__c>([SELECT Id, Deal_ID__c, SGENNO_ReadOnly__c, UPC__c, CMR__c, Selection_Reference_Number__c,
                                                                    Label_Code__c, Item_Type__c, Item_Code__c,recordTypeId,Material_Type__c  
                                                                    FROM Material__c 
                                                                    WHERE Id IN :componentIds]);
                                                                   
                                                                     
        for(Bom_Item__c bomItem:[select Material__c,Material_Component__c from Bom_item__c where Material_Component__c in:componentIds]){
            if(compMap.containsKey(bomItem.Material_Component__c)){
                compMap.get(bomItem.Material_Component__c).add(bomItem.Material__c);
            }else{
                compMap.put(bomItem.Material_Component__c,new List<Id>{bomItem.Material__c});
            }
        }
        
        for(Id matId : requestMaterialIds)
        {
            // Check if material is a component or format typed.
            if(componentIds.contains(matId))
            {  system.debug('========= In Approval 1===');
                Material__c comp;
                if(componentMap.containsKey(matId))
                    comp = componentMap.get(matId);
                else
                    continue;
                
                Material__c mat = comp;
                                
                if((((mat.Selection_Reference_Number__c == null || mat.Selection_Reference_Number__c == '') || (mat.Label_Code__c == null || mat.Label_Code__c == '')) && (componentMap.containsKey(matId)) && compMap.containsKey(matId))
                        || (!compMap.containsKey(matid) && componentMap.containsKey(matid)&& componentMap.get(matid).recordtypeId==materialRecordTypeId)){
                    mat.Material_Status__c = 'Submitted';
                }
                else if((((mat.Selection_Reference_Number__c != null && mat.Selection_Reference_Number__c != '') && (mat.Label_Code__c != null && mat.Label_Code__c != '')) && (componentMap.containsKey(matId))&& compMap.containsKey(matId)) 
                            || (!compMap.containsKey(matid) && componentMap.containsKey(matid)&& componentMap.get(matid).recordtypeId!=materialRecordTypeId) )
                {
                    mat.Material_Status__c = 'Approved';
                    mat.Material_Integration_State__c='N';
                }
                else if((mat.Selection_Reference_Number__c != null || mat.Selection_Reference_Number__c != '') && (mat.Label_Code__c != null || mat.Label_Code__c != '') && (mat.Item_Code__c!='FT - PHANTOM TRAY') && !(componentIds.contains(matId)) ){
                    mat.Material_Status__c = 'Approved';
                    mat.Material_Integration_State__c='N';
                }
                else if((mat.Selection_Reference_Number__c != null || mat.Selection_Reference_Number__c != '') && (mat.Label_Code__c != null || mat.Label_Code__c != '') && (mat.Item_Code__c=='FT - PHANTOM TRAY') && !(componentIds.contains(matId))){
                    mat.Material_Status__c = 'Submitted';
                }
                updateableMaterials.add(mat);
                
                approveMaterialCount ++;
                //Added refactoring 19042017 - Remove each value from componentMap and compMap as these are checked above
                if(componentMap.containsKey(matId)){
                    componentMap.remove(matId);
                }
                if(compMap.containsKey(matId)){
                    compMap.remove(matId);
                }
            }
            else if(displayVehicleIds.contains(matId))
            {  system.debug('========= In Approval 2===');
                
                //For Joint Corrugate
                if(materialJCMap.containsKey(matId) && materialJCMap.get(matId).BOM_Items__r != null && 
                   materialJCMap.get(matId).BOM_Items__r.size() > 1)
                {
                    Material__c mat = new Material__c();
                    mat.Id = matId;
                    if(materialJCMap.get(matId).Item_Code__c!='FT - PHANTOM TRAY'){
                        mat.Material_Status__c = 'Approved';
                        mat.Material_Integration_State__c = 'N';
                    }
                    else if((materialJCMap.get(matId).Selection_Reference_Number__c != null && materialJCMap.get(matId).Selection_Reference_Number__c != '') && materialJCMap.get(matId).Item_Code__c=='FT - PHANTOM TRAY'){
                        mat.Material_Status__c = 'Approved';
                        mat.Material_Integration_State__c = 'N';
                    }
                    else if((materialJCMap.get(matId).Selection_Reference_Number__c == null || materialJCMap.get(matId).Selection_Reference_Number__c == '') && materialJCMap.get(matId).Item_Code__c=='FT - PHANTOM TRAY'){
                         mat.Material_Status__c = 'Submitted';
                    }
                    updateableMaterials.add(mat);
                    
                    approveMaterialCount ++;
                    //Added refactoring 19042017 - Remove each value from materialJCMap as these are checked above
                    materialJCMap.remove(matId);
                }
                
                   
                if(materialDisplayMap.containsKey(matId) && materialDisplayMap.get(matId).BOM_Items__r != null && 
                   materialDisplayMap.get(matId).BOM_Items__r.size() > 0)
                {
                    Material__c mat = new Material__c();
                    mat.Id = matId;
                    
                    if(materialDisplayMap.get(matId).Item_Code__c!='FT - PHANTOM TRAY'){
                        mat.Material_Status__c = 'Approved';
                        mat.Material_Integration_State__c = 'N';
                    }
                    else if((materialDisplayMap.get(matId).Selection_Reference_Number__c != null && materialDisplayMap.get(matId).Selection_Reference_Number__c != '') && materialDisplayMap.get(matId).Item_Code__c=='FT - PHANTOM TRAY'){
                        mat.Material_Status__c = 'Approved';
                        mat.Material_Integration_State__c = 'N';
                    }
                    else if((materialDisplayMap.get(matId).Selection_Reference_Number__c == null || materialDisplayMap.get(matId).Selection_Reference_Number__c == '') && materialDisplayMap.get(matId).Item_Code__c=='FT - PHANTOM TRAY'){
                         mat.Material_Status__c = 'Submitted';
                    }
                    updateableMaterials.add(mat);
                    
                    approveMaterialCount ++;
                    //Added refactoring 19042017 - Remove each value from materialDisplayMap as these are checked above
                    materialDisplayMap.remove(matId);
                }
            }
            else
            {  
                if(multiPackIds.contains(matId)){
                
                    if(multiPackIds.contains(matId) && (!materialMultiPackMap.containsKey(matId) || (materialMultiPackMap.containsKey(matId) && 
                       (materialMultiPackMap.get(matId).BOM_Items__r == null || materialMultiPackMap.get(matId).BOM_Items__r.size() == 0) && materialMultiPackMap.get(matId).item_type__c=='M (Multipack)'
                        && materialMultiPackMap.get(matId).item_code__c=='CL - COLLECTION PACK')))
                    {
                        //Added refactoring 19042017 - Remove each value from materialMultiPackMap as these are checked above
                        if(materialMultiPackMap.containsKey(matId)){
                            materialMultiPackMap.remove(matId);
                        }   
                        continue;
                    }
                    // Create an approval request for the material.
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(matId);
                    FutureMaterial.unlockMaterial(New Set<Id> {matId});  
                    // Submit on behalf of a specific submitter
                    req1.setSubmitterId(UserInfo.getUserId()); 
                    
                    // Skipping the criteria evaluation is set to false.
                    req1.setSkipEntryCriteria(false);
                    
                    approvalRequestList.add(req1);
                    
                    approveMaterialCount ++;
               } 
               
               else {
                   system.debug('========= In Approval 4==='); 
                    // Create an approval request for the material.
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    
                    req1.setComments('Submitting request for approval.');
                    req1.setObjectId(matId);
                    FutureMaterial.unlockMaterial(New Set<Id> {matId});  
                    // Submit on behalf of a specific submitter
                    req1.setSubmitterId(UserInfo.getUserId()); 
                    
                    // Skipping the criteria evaluation is set to false.
                    req1.setSkipEntryCriteria(false);
                    
                    approvalRequestList.add(req1);
                    
                    approveMaterialCount ++;
               }
            }
        }
        
        // Submitting request for approval for non ROH and Z009 materials.
        if(approvalRequestList.size() > 0)
        {
            try
            {
                Approval.process(approvalRequestList, false);
            }
            catch(Exception ex){}
        }
        
        // Updating child materials to directly Approved as it happens on Submit for Approval.
        if(updateableMaterials.size() > 0)
        {
            update updateableMaterials;
        }
    }
    
    //STY-884 Default titleSource for Multipack
    public static void defaultTitleSourceforMultipack(){
        List<Material__c>updateMultipackList=new List<Material__c>();
        Map<id,List<String>>childTitleSourcesMap=new Map<id,List<String>>();
        Map<id,List<Bom_item__c>>bomItemMap=new Map<id,List<Bom_item__c>>();
        Integer bomcount=0;
                                                                                     
        for(Bom_item__c bomitems:[Select id , Material_Component__r.title_source__c,Material__r.Title_Source__c,Material__c from Bom_item__c where material__c in:multiPackIds  and Material_Component__r.material_type__c='FERT']) {
            if(bomitems.Material_Component__r.title_source__c!=null){
                if(childTitleSourcesMap.containsKey(bomitems.Material__c)){
                    childTitleSourcesMap.get(bomitems.Material__c).add(bomitems.Material_Component__r.title_source__c);
                }
                else{
                    childTitleSourcesMap.put(bomitems.Material__c,new List<String>{bomitems.Material_Component__r.title_source__c});
                }
                
                if(bomItemMap.containsKey(bomitems.Material__c)){
                    bomItemMap.get(bomitems.Material__c).add(bomitems);
                }
                else{
                    bomItemMap.put(bomitems.Material__c,new List<Bom_item__c>{bomitems});
                }
                
            }
            bomcount++;
        }
        
        for(Material__c mat: [Select id,title_source__c,
                              (SELECT Id, Material_Pricing_Group__c, Territory__c FROM Sales__r)
                              from Material__c where id in:multiPackIds]){
            Set<String>titleSource=new Set<String>();
            
            if(childTitleSourcesMap!=null && childTitleSourcesMap.containsKey(mat.id) && bomItemMap!=null && bomItemMap.containsKey(mat.id)){
                
                titleSource.addAll(childTitleSourcesMap.get(mat.id));
                if(childTitleSourcesMap.get(mat.id).size()< bomItemMap.get(mat.id).size()){
                    mat.title_source__c='';
                    updateMultipackList.add(mat);
                }
                else if(titleSource.size()>1 && childTitleSourcesMap.get(mat.id).size()==bomItemMap.get(mat.id).size()){
                    mat.title_source__c='04 - VARIOUS';
                    updateMultipackList.add(mat);
                }
                else if(titleSource.size()==1 && childTitleSourcesMap.get(mat.id).size()==bomItemMap.get(mat.id).size()){
                    mat.title_source__c=new list<string>(childTitleSourcesMap.get(mat.id))[0];
                    updateMultipackList.add(mat);
                }
            }
            else {
                mat.title_source__c='';
                updateMultipackList.add(mat);
            }
        }  
        try{
            
            if(!updateMultipackList.isEmpty()){
                update updateMultipackList;
            }
        }
        catch(Exception ex){
        }                                                                  
        
    }
}