public class MultipackDefaultingOnSubmitHandler
{
    private static Set<Id> processedMatIds = new Set<Id>();
    private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009', 'ZVSM', 'ZDLT'};
    private static List<Material__c> updateableMaterialList = new List<Material__c>();
    private static List<Classification__c> updateableClsList = new List<Classification__c>(); 
    private static Map<Id, Material__c> materialMap = new Map<Id, Material__c>();
    private static Map<Id, Classification__c> matClassificationMap = new Map<Id, Classification__c>();
    
    public static void updateMultipackInTree(Set<Id> rootMaterialIds)
    {
        processCompleteBOMHierarchy(rootMaterialIds);
        
        // Update material and associated details.
        TriggerUtility.doNotExecute = TRUE;
        if(updateableMaterialList.size() > 0)
            update updateableMaterialList;
        if(updateableClsList.size() > 0)
            update updateableClsList;
        TriggerUtility.doNotExecute = FALSE;
        
        // Clearing all the local variables.
        processedMatIds.clear();
        materialMap.clear();
        updateableClsList.clear();
        updateableMaterialList.clear();
        matClassificationMap.clear();
    }
    
    /*****************************************************************
    Method Name: processCompleteBOMHierarchy
    Purpose : Calling method to fetch BOM Hierarchy and process.
    ******************************************************************/
    private static void processCompleteBOMHierarchy(Set<Id> processingMaterialIds)
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
        Map<Id, Material__c> processingMats = new Map<Id, Material__c>([SELECT Id, Name, Item_Type__c, Cloned__c , Item_Code__c, Total_Item_Qty__c, Title_Source__c, Material_Status__c, Label_code__c, 
                                            (SELECT Id, Genre_US__c, Genre_Canada__c FROM Classifications__r WHERE RecordType.Name='General')
                                           FROM Material__c
                                           WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: childMaterialTypes AND 
                                               Deletion_Flag__c=false AND Function__c != '003']); //USST-2787
        Set<Id> pendingMultiFERTs = new Set<Id>();
        for(Material__c mat : processingMats.values())
        {
            processedMatIds.add(mat.Id);
            
            if(mat.Classifications__r != null && mat.Classifications__r.size() > 0)
            {
                matClassificationMap.put(mat.Id, mat.Classifications__r[0]);
            }
            
            if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
            {   
                //Looping over related BOM Item records
                for(BOM_Item__c bom : matBomMap.get(mat.Id))
                {
                    // If FERT material not previously processed.
                    if(!processedMatIds.contains(bom.Material_Component__c))
                    {
                        nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                    }
                    // If current material is Display Vehicle and the child material has Display again, then wait till child evaluation completes.
                    if(!pendingMultiFERTs.contains(mat.Id) && mat.Item_Type__c == 'M (Multipack)')
                    {
                        pendingMultiFERTs.add(mat.Id);
                    }
                }
            }
            
            materialMap.put(mat.Id, mat);
        }
        
        if(nextLevelProcessingMaterialIds.size() > 0)
        {
            processCompleteBOMHierarchy(nextLevelProcessingMaterialIds);
        }
        
        // after completing the child process, evaluate Genre for the parent multi-pack FERT.
        if(pendingMultiFERTs.size() > 0)
        {
            for(Id pMatId : pendingMultiFERTs)
            {
                Material__c mat = processingMats.get(pMatId);
                Map<String, Map<String, Integer>> territoryChildGenreCountMap = new Map<String, Map<String, Integer>>();
                territoryChildGenreCountMap.put('US', new Map<String, Integer>());
                territoryChildGenreCountMap.put('CDN', new Map<String, Integer>());
                
                Map<String, Integer> childTitleSourceCount = new Map<String, Integer>();
                
                Integer childsHavingGenrePopulated = 0;
                Integer childsHavingUSGenre = 0;
                Integer childsHavingCDNGenre = 0;
                Integer childsHavingTtlSrcPopulated = 0;
                String firstChildGenreUS;
                String firstChildGenreCDN;
                
                if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
                {   
                    Integer count = 0;
                    //Looping over related BOM Item records
                    for(BOM_Item__c bom : matBomMap.get(mat.Id))
                    {
                        Boolean hasGenre = false;
                        // Get child display value from materialMap
                        if(matClassificationMap.containsKey(bom.Material_Component__c))
                        {
                            Classification__c cls = matClassificationMap.get(bom.Material_Component__c);
                            // Fetching the first genre value.
                            if(count ++ == 0)
                            {
                                firstChildGenreUS = cls.Genre_US__c;
                                firstChildGenreCDN = cls.Genre_Canada__c;
                            }
                            
                            if(cls.Genre_US__c != null)
                            {
                                childsHavingUSGenre ++;
                                hasGenre = true;
                                if(territoryChildGenreCountMap.get('US').containsKey(cls.Genre_US__c))
                                    territoryChildGenreCountMap.get('US').put(cls.Genre_US__c, (territoryChildGenreCountMap.get('US').get(cls.Genre_US__c) + 1));
                                else
                                    territoryChildGenreCountMap.get('US').put(cls.Genre_US__c, 1);
                            }
                            if(cls.Genre_Canada__c != null)
                            {
                                childsHavingCDNGenre ++;
                                hasGenre = true;
                                if(territoryChildGenreCountMap.get('CDN').containsKey(cls.Genre_Canada__c))
                                    territoryChildGenreCountMap.get('CDN').put(cls.Genre_Canada__c, (territoryChildGenreCountMap.get('CDN').get(cls.Genre_Canada__c) + 1));
                                else
                                    territoryChildGenreCountMap.get('CDN').put(cls.Genre_Canada__c, 1);
                            }
                        }
                        
                        if(hasGenre)
                            childsHavingGenrePopulated ++;
                        
                         //USST-2786 --- start
                        String ttlSrc;
                        if(materialMap.get(bom.Material__c).Cloned__c != true){ 
                        // Calculating Title Source
                         ttlSrc = materialMap.get(bom.Material_Component__c).Title_Source__c;
                        }
                        
                        if(materialMap.get(bom.Material_Component__c).Title_Source__c != null) 
                        {
                            childsHavingTtlSrcPopulated ++;
                            if(childTitleSourceCount.containsKey(materialMap.get(bom.Material_Component__c).Title_Source__c))
                                childTitleSourceCount.put(materialMap.get(bom.Material_Component__c).Title_Source__c, (childTitleSourceCount.get(materialMap.get(bom.Material_Component__c).Title_Source__c) + 1));
                            else if(materialMap.get(bom.Material__c).Cloned__c != true)
                                childTitleSourceCount.put(materialMap.get(bom.Material_Component__c).Title_Source__c, 1);
                        }
                        //USST-2786 --- end
                    }
                }
                
                // Title Source Evaluation Process
                // If any of the child FERTs doesn't have Title Source
                if(mat.Material_Status__c != 'Processed in SAP' && mat.Material_Status__c != 'Approved')
                {
                    if(matBomMap.get(mat.Id).size() > childsHavingTtlSrcPopulated)
                    {
                        mat.title_source__c = '';
                        mat.Execute_Validation_Rule__c = false;
                        updateableMaterialList.add(mat);
                    }
                    else if(childTitleSourceCount.size() > 1 && matBomMap.get(mat.Id).size() == childsHavingTtlSrcPopulated)
                    {
                        mat.title_source__c = '04 - VARIOUS';
                        mat.Execute_Validation_Rule__c = false;
                        updateableMaterialList.add(mat);
                    }
                    else if(childTitleSourceCount.size() == 1 && matBomMap.get(mat.Id).size() == childsHavingTtlSrcPopulated)
                    {
                        for(String ttlSrc : childTitleSourceCount.keySet())
                        {
                            mat.title_source__c = ttlSrc;
                            //USST-2787 --- start
                            if (mat.Label_Code__c == '46 - DREAMWORKS ANIMATION' && ttlSrc == '02 - TELEVISION') {
                                mat.title_source__c = '';
                            }
                            //USST-2787 --- end
                            mat.Execute_Validation_Rule__c = false;
                        }
                        updateableMaterialList.add(mat);
                    }
                }
                
                // Genre Evaluation Process
                // If material has any classification.
                if(matClassificationMap.containsKey(mat.Id))
                {
                    Classification__c cls = matClassificationMap.get(mat.Id);
                    
                    String genreUS = null;
                    String genreCDN = null;
                    // Evaluating US Genre.
                    if(childsHavingUSGenre > 0/* && matBomMap.get(mat.Id).size() == childsHavingUSGenre*/)
                    {
                        // if all the child FERTs are having same Genre.
                        if(territoryChildGenreCountMap.get('US').size() == 1)
                        {
                            for(String gnr : territoryChildGenreCountMap.get('US').keySet())
                                genreUS = gnr;
                        }
                        else
                        {
                            Integer curStrength = 0;
                            Integer maxStrength = 0;
                            Integer iterationCount = 0;
                            Boolean hasSeparateStrength = false;
                            // Finding genre based on majority.
                            for(String gnr : territoryChildGenreCountMap.get('US').keySet())
                            {
                                curStrength = territoryChildGenreCountMap.get('US').get(gnr);
                                
                                // Evaluating if all of the Genre having different strength. Else set the first value. 
                                if(iterationCount ++ > 0 && curStrength != maxStrength)
                                {
                                    hasSeparateStrength = true;
                                }
                                
                                // Finding max strength.
                                if(genreUS == '' || curStrength > maxStrength)
                                {
                                    genreUS = gnr;
                                    maxStrength = curStrength;
                                }
                            }
                            
                            // If all the Genre having value, have same count; assign first one.
                            if(!hasSeparateStrength)
                            {
                                genreUS = firstChildGenreUS;
                            }
                        }
                    }
                    // Evaluating CDN Genre.
                    if(childsHavingCDNGenre > 0/* && matBomMap.get(mat.Id).size() == childsHavingCDNGenre*/)
                    {
                        // if all the child FERTs are having same Genre.
                        if(territoryChildGenreCountMap.get('CDN').size() == 1)
                        {
                            for(String gnr : territoryChildGenreCountMap.get('CDN').keySet())
                                genreCDN = gnr;
                        }
                        else
                        {
                            Integer curStrength = 0;
                            Integer maxStrength = 0;
                            Integer iterationCount = 0;
                            Boolean hasSeparateStrength = false;
                            // Finding genre based on majority.
                            for(String gnr : territoryChildGenreCountMap.get('CDN').keySet())
                            {
                                curStrength = territoryChildGenreCountMap.get('CDN').get(gnr);
                                
                                // Evaluating if all of the Genre having different strength. Else set the first value. 
                                if(iterationCount ++ > 0 && curStrength != maxStrength)
                                {
                                    hasSeparateStrength = true;
                                }
                                
                                // Finding max strength.
                                if(genreCDN == '' || curStrength > maxStrength)
                                {
                                    genreCDN = gnr;
                                    maxStrength = curStrength;
                                }
                            }
                            
                            // If all the Genre having value, have same count; assign first one.
                            if(!hasSeparateStrength)
                            {
                                genreCDN = firstChildGenreCDN;
                            }
                        }
                    }
                    
                    cls.Genre_US__c = genreUS;
                    cls.Genre_Canada__c = genreCDN;
                    cls.Execute_Validation__c = false;
                    updateableClsList.add(cls);
                }
                
                materialMap.put(mat.Id, mat);
            }
        }
    }
}