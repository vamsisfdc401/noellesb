public class RSUCalculationHandler
{
    private static Set<Id> rootMaterialIds = new Set<Id>();
    private static Set<Id> processedFERTIds = new Set<Id>();
    private static Set<Id> processedMatIds = new Set<Id>();
    private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009', 'ZVSM', 'ZDLT'};
    private static Map<Id,Material__c> updateableMaterialList = new Map<Id,Material__c>(); //Changed for Duplicate ID error on 10thDec
    private static Map<Id, Alternative_Unit_of_Measure__c> updateableAUoMList = new Map<Id, Alternative_Unit_of_Measure__c>();    // Changed for REL-166
    private static Map<Id, Material__c> materialMap = new Map<Id, Material__c>();
    
    @Future
    public static void updateMaterialTreeAsync(Set<Id> parentMaterialIds, Boolean findRoot)
    {
        updateMaterialTree(parentMaterialIds, findRoot);
    }
    
    public static void updateMaterialTree(Set<Id> parentMaterialIds, Boolean findRoot)    // parentMaterialIds consists of parent FERT Ids under which child is added/updated/deleted.
    {
        rootMaterialIds.clear();
        processedFERTIds.clear();
        materialMap.clear();
        updateableMaterialList.clear();
        
        if(findRoot != null && findRoot)
            fetchRootIds(parentMaterialIds, 1);
        else
            rootMaterialIds = parentMaterialIds;
        
        if(rootMaterialIds.size() > 0)
        {
            fetchCompleteBOMHierarchy(rootMaterialIds);
            
            if(updateableMaterialList.size() > 0)
            {
                TriggerUtility.doNotexecute = true;
                 update updateableMaterialList.values(); //Changed for Duplicate ID error on 10thDec
                
                if (updateableAUoMList.size() > 0) {
                    update updateableAUoMList.values();    // Changed for REL-166
                }
                TriggerUtility.doNotexecute = false;
            }
        }
    }
    
    private static void fetchRootIds(Set<Id> processingMatIds, Integer depthLevel)
    {
        Set<Id> nextProcessingMatIds = new Set<Id>();
        Set<Id> materialsHavingParent = new Set<Id>();
        
        for(BOM_Item__c bom : [SELECT Id, Material__c, Material_Component__c
                               FROM BOM_Item__c
                               WHERE Material_Component__c IN: processingMatIds])
        {
            // If parent has processed before, dont process it again.
            if(!processedFERTIds.contains(bom.Material__c))
            {
                processedFERTIds.add(bom.Material__c);
                nextProcessingMatIds.add(bom.Material__c);
            }
            materialsHavingParent.add(bom.Material_Component__c);
        }
        
        // Iterating to check if current set of material has parent or not.
        for(Id matId : processingMatIds)
        {
            if(!materialsHavingParent.contains(matId))
                rootMaterialIds.add(matId);
        }
        
        if(nextProcessingMatIds.size() > 0)
            fetchRootIds(nextProcessingMatIds, ++ depthLevel);
    }
    
    /*****************************************************************
    Method Name: fetchCompleteBOMHierarchy
    Purpose : Calling apex method to fetch BOM Hierarchy
    ***************************************************************/
    private static void fetchCompleteBOMHierarchy(Set<Id> processingMaterialIds)
    {
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        Map<Id, List<BOM_Item__c>> matBomMap = new Map<Id, List<BOM_Item__c>>();
        
        for(BOM_Item__c bom : [SELECT Id, Material__c, Material_Component__c, Material_Component__r.Material_Type__c, BOM_Quantity__c,
                                Material_Component__r.Item_Type__c
                                FROM BOM_Item__c
                                WHERE Material__c IN :processingMaterialIds AND Material__r.Material_Type__c NOT IN: childMaterialTypes AND 
                                    Material_Component__c NOT IN :processedMatIds AND Material_Component__c != null AND Material_Component__r.Material_Type__c NOT IN: childMaterialTypes AND 
                                    Material_Component__r.Deletion_Flag__c=false AND (BOM_Function__c != '003' AND Deletion_Flag__c=false)])
        {
            if(!matBomMap.containsKey(bom.Material__c))
                matBomMap.put(bom.Material__c, new List<BOM_Item__c>());
            matBomMap.get(bom.Material__c).add(bom);
        }
        
        // Fetch the current processing materials.
        Map<Id, Material__c> processingMats = new Map<Id, Material__c>([SELECT Id, Name, Item_Type__c, Item_Code__c, Total_Item_Qty__c, Count_Sales_for_D_Chain_Status__c,
                                            (SELECT Id FROM Alternative_Units_of_Measure__r WHERE Alternative_Unit_of_Measure__c='RSU - Retail unit' OR Alternative_Unit_of_Measure__c='RSU - Retail Sellable Unit')
                                           FROM Material__c
                                           WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: childMaterialTypes AND 
                                               Deletion_Flag__c=false AND Function__c != '003']);
        Set<Id> pendingDispMats = new Set<Id>();
        for(Material__c mat : processingMats.values())
        {
            processedMatIds.add(mat.Id);
            
            if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
            {   
                Decimal totalItemQty = 0;
                //Looping over related BOM Item records
                for(BOM_Item__c bom : matBomMap.get(mat.Id))
                {
                    // If FERT material not previously processed.
                    if(!processedMatIds.contains(bom.Material_Component__c))
                    {
                        nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                    }
                    // If current material is Display Vehicle and the child material has Display again, then wait till child evaluation completes.
                    if(!pendingDispMats.contains(mat.Id) && mat.Item_Type__c == 'D (Display Vehicle)')
                    {
                        if(bom.Material_Component__r.Item_Type__c == 'D (Display Vehicle)')
                        {
                            pendingDispMats.add(mat.Id);
                            continue;
                        }
                        else if(bom.BOM_Quantity__c != null)
                        {
                            totalItemQty += bom.BOM_Quantity__c;
                        }
                    }
                }
                
                // If parent has no child display, add the count in material field to update.
                if(!pendingDispMats.contains(mat.Id) && mat.Item_Type__c == 'D (Display Vehicle)')
                {
                    //Changed for Duplicate ID error on 10thDec--start
                    Material__c mat2;
                    if(updateableMaterialList.containsKey(mat.Id)) {
                        mat2 = updateableMaterialList.get(mat.Id);
                        mat2.Total_Item_Qty__c = totalItemQty; //USST-2708
                    }
                    else {
                        mat2 = new Material__c(Id=mat.Id, Total_Item_Qty__c = totalItemQty); //USST-2708
                        updateableMaterialList.put(mat2.Id,mat2);
                    }
                    
                    //Changed for Duplicate ID error on 10thDec--End
                    System.debug('---->>'+updateableMaterialList+' :: '+updateableMaterialList);
                    mat.Total_Item_Qty__c = totalItemQty;
                    
                    if(mat.Count_Sales_for_D_Chain_Status__c > 0 && mat.Alternative_Units_of_Measure__r.size() > 0)
                    {
                        for(Alternative_Unit_of_Measure__c auom : mat.Alternative_Units_of_Measure__r)
                        {
                            system.debug('USST-2751');
                            auom.Denominator_Conversion__c = String.valueOf(Integer.valueOf(totalItemQty));
                            auom.Execute_Validation__c = false;
                            updateableAUoMList.put(auom.Id, auom);    // Changed for REL-166
                        }
                    }
                }
            }
            else  {
            Decimal totalItemQty1 = 0;
            //Changed for Duplicate ID error on 10thDec--start
                    Material__c mat2;
                    if(updateableMaterialList.containsKey(mat.Id)) {
                        mat2 = updateableMaterialList.get(mat.Id);
                        mat2.Total_Item_Qty__c = totalItemQty1; //USST-2708
                    }
                    else {
                        mat2 = new Material__c(Id=mat.Id, Total_Item_Qty__c = totalItemQty1); //USST-2708
                        updateableMaterialList.put(mat2.Id,mat2);
                    }
                    //Changed for Duplicate ID error on 10thDec--End
                     mat.Total_Item_Qty__c = totalItemQty1 ;
            if(mat.Count_Sales_for_D_Chain_Status__c > 0 && mat.Alternative_Units_of_Measure__r.size() > 0)
            {
                for(Alternative_Unit_of_Measure__c auom : mat.Alternative_Units_of_Measure__r)
                {
                    system.debug('USST-2751');
                    auom.Denominator_Conversion__c = String.valueOf(Integer.valueOf(totalItemQty1));
                    auom.Execute_Validation__c = false;
                    updateableAUoMList.put(auom.Id, auom);    // Changed for REL-166
                }
            }
                    
            }
            materialMap.put(mat.Id, mat);
        }
        
        if(nextLevelProcessingMaterialIds.size() > 0)
        {
            fetchCompleteBOMHierarchy(nextLevelProcessingMaterialIds);
            
            // after completing the fetching process if there is any pending display vehicle to be evaluated, process that.
            if(pendingDispMats.size() > 0)
            {
                for(Id pMatId : pendingDispMats)
                {
                    Material__c mat = processingMats.get(pMatId);
                    if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
                    {   
                        Decimal totalItemQty = 0;
                        //Looping over related BOM Item records
                        for(BOM_Item__c bom : matBomMap.get(mat.Id))
                        {
                            // Get child display value from materialMap
                            if(bom.Material_Component__r.Item_Type__c == 'D (Display Vehicle)' && materialMap.containsKey(bom.Material_Component__c) && 
                               materialMap.get(bom.Material_Component__c).Total_Item_Qty__c != null)
                            {
                                totalItemQty += materialMap.get(bom.Material_Component__c).Total_Item_Qty__c;
                            }
                            else if(bom.BOM_Quantity__c != null)
                            {
                                totalItemQty += bom.BOM_Quantity__c;
                            }
                        }
                        
                        // update count in parent record.
                        //Changed for Duplicate ID error on 10thDec--start
                        Material__c mat2;
                        if(updateableMaterialList.containsKey(mat.Id)) {
                            mat2 = updateableMaterialList.get(mat.Id);
                            mat2.Total_Item_Qty__c = totalItemQty;  //USST-2708
                        }
                        else {
                            mat2 = new Material__c(Id=mat.Id, Total_Item_Qty__c = totalItemQty); //USST-2708
                            updateableMaterialList.put(mat2.Id,mat2);
                        }
                        
                       //Changed for Duplicate ID error on 10thDec--End
                        System.debug('---->>'+updateableMaterialList+' :: '+updateableMaterialList);
                        mat.Total_Item_Qty__c = totalItemQty;
                        
                        
                        if(mat.Count_Sales_for_D_Chain_Status__c > 0 && mat.Alternative_Units_of_Measure__r.size() > 0)
                        {
                            for(Alternative_Unit_of_Measure__c auom : mat.Alternative_Units_of_Measure__r)
                            {
                                system.debug('USST-2751');
                                auom.Denominator_Conversion__c = String.valueOf(Integer.valueOf(totalItemQty));
                                auom.Execute_Validation__c = false;
                                updateableAUoMList.put(auom.Id, auom);    // Changed for REL-166
                            }
                        }
                    }
                    materialMap.put(mat.Id, mat);
                }
            }
        }
    }
}