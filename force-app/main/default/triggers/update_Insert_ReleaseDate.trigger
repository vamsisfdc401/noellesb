/*****************************************************************************************
TriggerName: update_Insert_ReleaseDate
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/08/2016           Ipsita                    Initial Development
1.1             20/09/2016           Jay                       Added logic to write Acquisition field
1.2             28/09/2016           Jay                       Changes for VOD Date Records
2.0             29/09/2016           Ipsita                    Additional revisions to simplify queries
2.1             03/10/2016           Jay                       Changes to Exclude VOD and EST when TV or Catalog
2.2             12/10/2016           Durgesh                   Changes to update deal id as null when deal is blank. 
2.3             25/01/2017           Jay                       Removed update logic to Master Schedule and Pretty Indicators on Release Dates
                                                               and cleaned up old code that was commented out 
2.4             02/06/2017           Mohit                     Add digitalforce code for DFOR-78
******************************************************************************************/
trigger update_Insert_ReleaseDate on Release__c(after insert,after update,before insert,before update,after delete){
    List<Release_Date__c> lstRelDate = new List<Release_Date__c>();
    Map<Id,Release_Date__c> lstUpdateRelDate = new Map<Id,Release_Date__c>();
    List<Release_Date__c> lstInsertRelDate = new List<Release_Date__c>();
    List<Release_Date__c> lstDeleteRelDate = new List<Release_Date__c>();
    List<Material__c> lstMaterial=new List<Material__c>();
    Map<id,List<Material__c>>releaseMap=new Map<id,List<Material__c>>();
    
    List<Release__c> lstRelease = new List<Release__c>();
    List<Release_Date__c> releaseDateList = new List<Release_Date__c>();
    set<Id> releaseId = new set<Id>();
    set<Id> relsId = new set<Id>();
    Id matRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId(); //USST-2248
    
    if(!TriggerUtility.hasTriggerExecuted('Release__c')) {
    TriggerUtility.initiatedFromRelease = TRUE;
    //USST-3257 --- start
    if (Trigger.isBefore && Trigger.isUpdate && TriggerUtility.currentUser.Profile.Name == 'Platform API' ) {
        for (Release__c rel : Trigger.new) {
            Release__c oldRel = (Release__c)Trigger.oldMap.get(rel.Id);
            if (rel.Brand_Group__c == 'Partners' || rel.Brand_Group__c == 'Content Group') {
                if ((rel.SVOD_Start_Date__c != oldRel.SVOD_Start_Date__c || rel.PTV_SOD_End_Date__c != oldRel.PTV_SOD_End_Date__c || rel.PTV_SOD_Provider__c != oldRel.PTV_SOD_Provider__c || rel.Other_Provider__c != oldRel.Other_Provider__c) && (rel.Hotel_End_Date__c != oldRel.Hotel_End_Date__c || rel.VOD_End_Date__c != oldRel.VOD_End_Date__c)) {
                    rel.SVOD_Start_Date__c = oldRel.SVOD_Start_Date__c;
                    rel.PTV_SOD_End_Date__c = oldRel.PTV_SOD_End_Date__c;
                    rel.PTV_SOD_Provider__c = oldRel.PTV_SOD_Provider__c;
                    rel.Other_Provider__c = oldRel.Other_Provider__c;
                }
                else if (rel.SVOD_Start_Date__c != oldRel.SVOD_Start_Date__c || rel.PTV_SOD_End_Date__c != oldRel.PTV_SOD_End_Date__c || rel.PTV_SOD_Provider__c != oldRel.PTV_SOD_Provider__c || rel.Other_Provider__c != oldRel.Other_Provider__c) {
                    rel.SVOD_Start_Date__c = oldRel.SVOD_Start_Date__c;
                    rel.PTV_SOD_End_Date__c = oldRel.PTV_SOD_End_Date__c;
                    rel.PTV_SOD_Provider__c = oldRel.PTV_SOD_Provider__c;
                    rel.Other_Provider__c = oldRel.Other_Provider__c;
                    //Trigger.newMap.get(rel.Id).addError('SVOD fields cannot be updated via DAR ingest.');                   
                }
            }
        }
    }
    //USST-3257 --- end
    if(Trigger.isAfter){
        if(Trigger.isUpdate && !TriggerUtility.checkFromCloning){
           for(Release__c rel : Trigger.new){
            relsId.add(rel.id);
           }
           
           releaseDateList = [Select id,Release__c,Release_Date_Type__c,Release_Date__c,Label_Code__c from Release_Date__c where Release__c In:relsId];
           
            for(Release__c rel : Trigger.new){
                system.debug('inside 1st for');
                Date newESTVal = rel.EST_Date__c;
                Date oldESTVal = trigger.oldMap.get(rel.id).EST_Date__c;
                Date newStreetVal = rel.Street_Date__c;
                Date oldStreetVal = trigger.oldMap.get(rel.id).Street_Date__c;
                Date newTheatricalVal = rel.First_Theatrical_Date__c;
                Date oldTheatricalVal = trigger.oldMap.get(rel.id).First_Theatrical_Date__c;
                Date newVODVal = rel.VOD_Street_Date__c;
                Date oldVODVal = trigger.oldMap.get(rel.id).VOD_Street_Date__c;
                String oldDistributor = trigger.oldMap.get(rel.id).Distributor__c;
                String oldDistributorShortName = trigger.oldMap.get(rel.id).Distributor_Short_Name__c;
                Decimal oldDomBoxOffice = trigger.oldMap.get(rel.id).DOM_Box_Office_Total__c;
                Decimal oldDomOpen = trigger.oldMap.get(rel.id).DOM_Open_W_E_Total__c;
                String oldRelPattern = trigger.oldMap.get(rel.id).Release_Patterns__c;
                String oldVisualFormat = trigger.oldMap.get(rel.id).Visual_Format__c;
                String newBrandGroup = rel.Brand_Group__c;
                String oldBrandGroup = trigger.oldMap.get(rel.id).Brand_Group__c;
                
                Date newAltStrtDate = rel.Alternate_Physical_Street_Date__c;
                Date oldAltStrtDate = trigger.oldMap.get(rel.id).Alternate_Physical_Street_Date__c;
                
                Date newAltESTDate = rel.Alternate_EST_Date__c;
                Date oldAltESTDate = trigger.oldMap.get(rel.id).Alternate_EST_Date__c;
                
                Date newAltVODDate = rel.Alternate_VOD_Date__c;
                Date oldAltVODDate = trigger.oldMap.get(rel.id).Alternate_VOD_Date__c;
                
                Boolean newAcquisition = rel.Acquisition__c;
                Boolean oldAcquisition = trigger.oldMap.get(rel.id).Acquisition__c;
                
                if(oldAltStrtDate != newAltStrtDate && newAltStrtDate != null){
                   
                    if(releaseDateList.size() > 0){
                        for(Release_Date__c estRelDate : releaseDateList){
                          if(estRelDate.Release_Date_Type__c == 'Alternate Street Date' && rel.Id == estRelDate.Release__c){
                            Release_Date__c relDate = new Release_Date__c();
                            relDate.id = estRelDate.id;
                            relDate.Release_Date__c = rel.Alternate_Physical_Street_Date__c;
                            relDate.Label_Code__c = rel.Label_Code__c;
                            lstUpdateRelDate.put(relDate.id,relDate);
                         }      
                        }
                    }
                }
                if(oldAltESTDate != newAltESTDate && newAltESTDate != null){
                    
                    if(releaseDateList.size() > 0){
                        for(Release_Date__c estRelDate : releaseDateList){
                            if(estRelDate.Release_Date_Type__c == 'Alternate EST Date' && rel.Id == estRelDate.Release__c){
                                Release_Date__c relDate = new Release_Date__c();
                                relDate.id = estRelDate.id;
                                relDate.Release_Date__c = rel.Alternate_EST_Date__c;
                                relDate.Label_Code__c = rel.Label_Code__c;
                                lstUpdateRelDate.put(relDate.id,relDate);
                            }   
                        }
                    }
                }
                    
                if(oldAltVODDate != newAltVODDate && newAltVODDate != null){
                    if(releaseDateList.size() > 0){
                        for(Release_Date__c estRelDate : releaseDateList){
                            if(estRelDate.Release_Date_Type__c == 'Alternate VOD Street Date' && rel.Id == estRelDate.Release__c){
                                Release_Date__c relDate = new Release_Date__c();
                                relDate.id = estRelDate.id;
                                relDate.Release_Date__c = rel.Alternate_VOD_Date__c;
                                relDate.Label_Code__c = rel.Label_Code__c;
                                lstUpdateRelDate.put(relDate.id,relDate);
                            }   
                        }
                    }
                }               
                
                /*if(oldESTVal != newESTVal || oldStreetVal != newStreetVal || oldTheatricalVal != newTheatricalVal || oldVODVal != newVODVal){*/
                    if((oldESTVal != newESTVal && oldESTVal != null) || oldTheatricalVal != newTheatricalVal){
                        system.debug('inside 1st if');
                        
                        if(releaseDateList.size() > 0){
                            for(Release_Date__c rd : releaseDateList){
                                if(rd.Release_Date_Type__c == 'EST Date' && rel.Id == rd.Release__c ){
                                    Release_Date__c relDate = new Release_Date__c();
                                    relDate.id = rd.id;
                                    relDate.Release_Date__c = rel.EST_Date__c;
                                    relDate.Label_Code__c = rel.Label_Code__c;
                                    lstUpdateRelDate.put(relDate.id,relDate);
                                }   
                            }
                        }
                    }
                    if(oldStreetVal != newStreetVal){
                        system.debug('inside 2nd if');
                        
                        if(releaseDateList.size() > 0){
                            for(Release_Date__c srd : releaseDateList){
                                if(srd.Release_Date_Type__c == 'Street Date' && rel.Id == srd.Release__c){
                                    Release_Date__c relDate = new Release_Date__c();
                                    relDate.id = srd.id;
                                    relDate.Release_Date__c = rel.Street_Date__c;
                                    relDate.Label_Code__c = rel.Label_Code__c;
                                    lstUpdateRelDate.put(relDate.id,relDate);
                                }      
                            }
                        }
                    }
                    if(oldTheatricalVal != newTheatricalVal){
                        system.debug('inside 3rd if');
                        
                        if(releaseDateList.size() > 0){
                            for(Release_Date__c srd : releaseDateList){
                                if(srd.Release_Date_Type__c == 'Theatrical Release Date' && rel.Id == srd.Release__c){
                                    Release_Date__c relDate = new Release_Date__c();
                                    relDate.id = srd.id;
                                    relDate.Release_Date__c = rel.First_Theatrical_Date__c;
                                    relDate.Label_Code__c = rel.Label_Code__c;
                                    lstUpdateRelDate.put(relDate.id,relDate);
                                }
                            }
                        }
                    }
                    if(oldVODVal != newVODVal || oldTheatricalVal != newTheatricalVal){
                        system.debug('inside 4th if');
                        
                        if(releaseDateList.size() > 0){
                            for(Release_Date__c srd : releaseDateList){
                                if(srd.Release_Date_Type__c == 'VOD Street Date' && rel.Id == srd.Release__c){
                                    Release_Date__c relDate = new Release_Date__c();
                                    relDate.id = srd.id;
                                    relDate.Release_Date__c = rel.VOD_Street_Date__c;
                                    relDate.Label_Code__c = rel.Label_Code__c;
                                    lstUpdateRelDate.put(relDate.id,relDate);
                                }      
                            }
                        }
                    }
               /* }*/
                if(rel.Distributor__c != oldDistributor || rel.Distributor_Short_Name__c != oldDistributorShortName || rel.DOM_Box_Office_Total__c != oldDomBoxOffice 
                   || rel.DOM_Open_W_E_Total__c != oldDomOpen || rel.Release_Patterns__c != oldRelPattern || rel.Visual_Format__c != oldVisualFormat || rel.Brand_Group__c != oldBrandGroup || rel.Acquisition__c != oldAcquisition){

                       if(releaseDateList.size() > 0){
                           for(Release_Date__c rd : releaseDateList){
                               if(rel.Id == rd.Release__c){
                                   Release_Date__c relDate = new Release_Date__c();
                                   relDate.id = rd.id;
                                   relDate.Distributor__c = rel.Distributor__c;
                                   relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                                   relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                                   relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                                   relDate.Release_Pattern__c = rel.Release_Patterns__c;
                                   relDate.Visual_Format__c = rel.Visual_Format__c; 
                                   relDate.Brand_Group__c = rel.Brand_Group__c;
                                   relDate.Label_Code__c = rel.Label_Code__c;
                                   relDate.Acquisition__c = rel.Acquisition__c;                            
                                   lstUpdateRelDate.put(relDate.id,relDate);
                               }  
                           }   
                       }
                }

                //USST-2788
                if(rel.Label_Code__c != trigger.oldMap.get(rel.id).Label_Code__c){
                    for(Release_Date__c rd : releaseDateList){
                     if(rel.Id == rd.Release__c){
                       Release_Date__c relDate = new Release_Date__c();
                       if(lstUpdateRelDate.containskey(rd.Id)){
                       
                          relDate = lstUpdateRelDate.get(rd.Id);
                        }else{
                        
                         relDate.Id = rd.Id;
                        }
                        relDate.Label_Code__c = rel.Label_Code__c;
                        lstUpdateRelDate.put(rd.id,relDate);
                       }
                    }   
                }
                //USST-2788
            }
            
            if(lstUpdateRelDate.size() > 0){
                update lstUpdateRelDate.values();
            }
           
          //  if(TriggerUtility.releaseTriggerExecuted()){
                for(Release__c rel : Trigger.new){
                    system.debug('inside 2nd for');
                    Date newESTVal = rel.EST_Date__c;
                    Date oldESTVal = trigger.oldMap.get(rel.id).EST_Date__c;
                    Date newStreetVal = rel.Street_Date__c;
                    Date oldStreetVal = trigger.oldMap.get(rel.id).Street_Date__c;
                    Date newTheatricalVal = rel.First_Theatrical_Date__c;
                    Date oldTheatricalVal = trigger.oldMap.get(rel.id).First_Theatrical_Date__c;
                    Date newVODVal = rel.VOD_Street_Date__c;
                    Date oldVODVal = trigger.oldMap.get(rel.id).VOD_Street_Date__c;
                    
                    String newBrandGroup = rel.Brand_Group__c;
                    String oldBrandGroup = trigger.oldMap.get(rel.id).Brand_Group__c; 
                    
                    Date newAltStrtDate = rel.Alternate_Physical_Street_Date__c;
                    Date oldAltStrtDate = trigger.oldMap.get(rel.id).Alternate_Physical_Street_Date__c;
                    
                    Date newAltESTDate = rel.Alternate_EST_Date__c;
                    Date oldAltESTDate = trigger.oldMap.get(rel.id).Alternate_EST_Date__c;
                    
                    Date newAltVODDate = rel.Alternate_VOD_Date__c;
                    Date oldAltVODDate = trigger.oldMap.get(rel.id).Alternate_VOD_Date__c;
                    
                    if(oldAltStrtDate == null && newAltStrtDate != null){
                        Release_Date__c relDate = new Release_Date__c();
                        relDate.Release__c = rel.id;
                        relDate.Release_Date_Type__c = 'Alternate Street Date';
                        relDate.Release_Date__c = rel.Alternate_Physical_Street_Date__c;
                        relDate.Distributor__c = rel.Distributor__c;
                        relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                        relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                        relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                        relDate.Release_Pattern__c = rel.Release_Patterns__c;
                        relDate.Visual_Format__c = rel.Visual_Format__c;
                        relDate.Brand_Group__c = rel.Brand_Group__c;
                        relDate.Label_Code__c = rel.Label_Code__c;
                        relDate.Acquisition__c = rel.Acquisition__c;                        
                        lstInsertRelDate.add(relDate);
                    }
                    
                    if(oldAltESTDate == null && newAltESTDate != null){
                        Release_Date__c relDate = new Release_Date__c();
                        relDate.Release__c = rel.id;
                        relDate.Release_Date_Type__c = 'Alternate EST Date';
                        relDate.Release_Date__c = rel.Alternate_EST_Date__c;
                        relDate.Distributor__c = rel.Distributor__c;
                        relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                        relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                        relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                        relDate.Release_Pattern__c = rel.Release_Patterns__c;
                        relDate.Visual_Format__c = rel.Visual_Format__c;
                        relDate.Brand_Group__c = rel.Brand_Group__c;
                        relDate.Label_Code__c = rel.Label_Code__c;
                        relDate.Acquisition__c = rel.Acquisition__c;                        
                        lstInsertRelDate.add(relDate);
                    }
                    
                    if(oldAltVODDate == null && newAltVODDate != null){
                        Release_Date__c relDate = new Release_Date__c();
                        relDate.Release__c = rel.id;
                        relDate.Release_Date_Type__c = 'Alternate VOD Street Date';
                        relDate.Release_Date__c = rel.Alternate_VOD_Date__c;
                        relDate.Distributor__c = rel.Distributor__c;
                        relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                        relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                        relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                        relDate.Release_Pattern__c = rel.Release_Patterns__c;
                        relDate.Visual_Format__c = rel.Visual_Format__c;
                        relDate.Brand_Group__c = rel.Brand_Group__c;
                        relDate.Label_Code__c = rel.Label_Code__c;
                        relDate.Acquisition__c = rel.Acquisition__c; 
                        lstInsertRelDate.add(relDate);
                    }
                    
                    if(TriggerUtility.releaseTriggerExecuted()){                      
                        if((oldESTVal == null && newESTVal != null && newBrandGroup != 'TV' && newBrandGroup != 'Catalog') || ((oldBrandGroup == 'TV' || oldBrandGroup == 'Catalog') && newBrandGroup != 'TV' && newBrandGroup != 'Catalog')){
                            system.debug('inside 5th if');
                            Release_Date__c relDate = new Release_Date__c();
                            relDate.Release__c = rel.id;
                            relDate.Release_Date_Type__c = 'EST Date';
                            relDate.Release_Date__c = rel.EST_Date__c;
                            relDate.Distributor__c = rel.Distributor__c;
                            relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                            relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                            relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                            relDate.Release_Pattern__c = rel.Release_Patterns__c;
                            relDate.Visual_Format__c = rel.Visual_Format__c;
                            relDate.Brand_Group__c = rel.Brand_Group__c;
                            relDate.Label_Code__c = rel.Label_Code__c;
                            relDate.Acquisition__c = rel.Acquisition__c;                            
                            lstInsertRelDate.add(relDate);
                        }
                        
                        
                        if((rel.Street_Date__c != Trigger.Oldmap.get(rel.Id).Street_Date__c) && rel.Street_Date__c != null && Trigger.Oldmap.get(rel.Id).Street_Date__c ==NUll){
                            system.debug('inside 6th if');
                            Release_Date__c relDate = new Release_Date__c();
                            relDate.Release__c = rel.id;
                            relDate.Release_Date_Type__c = 'Street Date';
                            relDate.Release_Date__c = rel.Street_Date__c;
                            relDate.Distributor__c = rel.Distributor__c;
                            relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                            relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                            relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                            relDate.Release_Pattern__c = rel.Release_Patterns__c;
                            relDate.Visual_Format__c = rel.Visual_Format__c;
                            relDate.Brand_Group__c = rel.Brand_Group__c;
                            relDate.Label_Code__c = rel.Label_Code__c;
                            relDate.Acquisition__c = rel.Acquisition__c;                            
                            lstInsertRelDate.add(relDate);
                        }
                        
                        if(oldTheatricalVal == null && newTheatricalVal != null){
                            system.debug('inside 7th if');
                            Release_Date__c relDate = new Release_Date__c();
                            relDate.Release__c = rel.id;
                            relDate.Release_Date_Type__c = 'Theatrical Release Date';
                            relDate.Release_Date__c = rel.First_Theatrical_Date__c;
                            relDate.Distributor__c = rel.Distributor__c;
                            relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                            relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                            relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                            relDate.Release_Pattern__c = rel.Release_Patterns__c;
                            relDate.Visual_Format__c = rel.Visual_Format__c;
                            relDate.Brand_Group__c = rel.Brand_Group__c;
                            relDate.Label_Code__c = rel.Label_Code__c;
                            relDate.Acquisition__c = rel.Acquisition__c;                            
                            lstInsertRelDate.add(relDate);
                        }
                        
                        // Added condition to prevent creation fo VOD Release Date record if date is equal to Street Date JE 9/29 or VOD Date null and if Brand Group TV or Catalog
                        if( newVODVal != null && (((oldVODVal == null || oldVODVal == oldStreetVal) && newBrandGroup != 'TV' && newBrandGroup != 'Catalog') || ((oldBrandGroup == 'TV' || oldBrandGroup == 'Catalog')&& newBrandGroup != 'TV' && newBrandGroup != 'Catalog' )) && newVODVal != newStreetVal ){                            
                            system.debug('inside 8th if');
                            Release_Date__c relDate = new Release_Date__c();
                            relDate.Release__c = rel.id;
                            relDate.Release_Date_Type__c = 'VOD Street Date';
                            relDate.Release_Date__c = rel.VOD_Street_Date__c;
                            relDate.Distributor__c = rel.Distributor__c;
                            relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                            relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                            relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                            relDate.Release_Pattern__c = rel.Release_Patterns__c;
                            relDate.Visual_Format__c = rel.Visual_Format__c;
                            relDate.Brand_Group__c = rel.Brand_Group__c;
                            relDate.Label_Code__c = rel.Label_Code__c;
                            relDate.Acquisition__c = rel.Acquisition__c;         
                            lstInsertRelDate.add(relDate);
                        }
                    }   
                    // }
                }
            if(lstInsertRelDate.size() > 0){
                insert lstInsertRelDate;
            }
           // }     
            for(Release__c rel : Trigger.new){
                system.debug('inside 3rd for');
                Date newESTVal = rel.EST_Date__c;
                Date oldESTVal = trigger.oldMap.get(rel.id).EST_Date__c;
                Date newStreetVal = rel.Street_Date__c;
                Date oldStreetVal = trigger.oldMap.get(rel.id).Street_Date__c;
                Date newTheatricalVal = rel.First_Theatrical_Date__c;
                Date oldTheatricalVal = trigger.oldMap.get(rel.id).First_Theatrical_Date__c;
                Date newVODVal = rel.VOD_Street_Date__c;
                Date oldVODVal = trigger.oldMap.get(rel.id).VOD_Street_Date__c;
                
                String newBrandGroup = rel.Brand_Group__c;
                String oldBrandGroup = trigger.oldMap.get(rel.id).Brand_Group__c; 
                    
                Date newAltStrtDate = rel.Alternate_Physical_Street_Date__c;
                Date oldAltStrtDate = trigger.oldMap.get(rel.id).Alternate_Physical_Street_Date__c;
                
                Date newAltESTDate = rel.Alternate_EST_Date__c;
                Date oldAltESTDate = trigger.oldMap.get(rel.id).Alternate_EST_Date__c;
                
                Date newAltVODDate = rel.Alternate_VOD_Date__c;
                Date oldAltVODDate = trigger.oldMap.get(rel.id).Alternate_VOD_Date__c;
                
                if(oldAltStrtDate != null && newAltStrtDate == null){
                    
                    if(releaseDateList.size() > 0){
                        for(Release_Date__c estRelDate : releaseDateList){
                            if(estRelDate.Release_Date_Type__c == 'Alternate Street Date' && rel.Id == estRelDate.Release__c){
                                Release_Date__c relDate = new Release_Date__c();
                                relDate.id = estRelDate.id;
                                lstDeleteRelDate.add(relDate);
                            }
                        }
                    }
                }
                if(oldAltESTDate != null && newAltESTDate == null){
                    
                    if(releaseDateList.size() > 0){
                        for(Release_Date__c estRelDate : releaseDateList){
                            if(estRelDate.Release_Date_Type__c == 'Alternate EST Date' && rel.Id == estRelDate.Release__c){
                                Release_Date__c relDate = new Release_Date__c();
                                relDate.id = estRelDate.id;
                                lstDeleteRelDate.add(relDate);
                            }   
                        }
                    }
                }
                
                if(oldAltVODDate != null && newAltVODDate == null){
                    
                    if(releaseDateList.size() > 0){
                        for(Release_Date__c estRelDate : releaseDateList){
                            if(estRelDate.Release_Date_Type__c == 'Alternate VOD Street Date' && rel.Id == estRelDate.Release__c){
                                Release_Date__c relDate = new Release_Date__c();
                                relDate.id = estRelDate.id;
                                lstDeleteRelDate.add(relDate);
                            }   
                        }
                    }
                }    
                
                if(oldBrandGroup != newBrandGroup || oldESTVal != null && newESTVal == null || oldStreetVal != null && newStreetVal== null || oldTheatricalVal != null && newTheatricalVal == null || oldVODVal != null && newVODVal ==null|| oldVODVal != null && newVODVal == newStreetVal){
                    if(oldESTVal != null && newESTVal == null || newESTVal != null && rel.Brand_Group__c == 'TV' && rel.Brand_Group__c == 'Catalog'){
                        
                        system.debug('inside 9th if');
                        system.debug('releaseDateList==== '+releaseDateList);
                        if(releaseDateList.size() > 0){
                            for(Release_Date__c estRelDate : releaseDateList){
                                if(estRelDate.Release_Date_Type__c == 'EST Date' && rel.Id == estRelDate.Release__c){
                                    Release_Date__c relDate = new Release_Date__c();
                                    relDate.id = estRelDate.id;
                                    lstDeleteRelDate.add(relDate);
                                }   
                            }
                        }
                    }
                    if(oldStreetVal != null && newStreetVal== null){
                        system.debug('inside 10th if');
                        if(releaseDateList.size() > 0){
                            for(Release_Date__c streetRelDate : releaseDateList){
                                if(streetRelDate.Release_Date_Type__c == 'Street Date' && rel.Id == streetRelDate.Release__c){
                                    Release_Date__c relDate = new Release_Date__c();
                                    relDate.id = streetRelDate.id;
                                    lstDeleteRelDate.add(relDate);
                                }   
                            }
                        }
                    }
                    if(oldTheatricalVal != null && newTheatricalVal == null){
                        system.debug('inside 11th if');
                        
                        if(releaseDateList.size() > 0){                     
                            for(Release_Date__c thRelDate : releaseDateList){
                                if(thRelDate.Release_Date_Type__c == 'Theatrical Release Date' && rel.Id == thRelDate.Release__c){
                                    Release_Date__c relDate = new Release_Date__c();
                                    relDate.id = thRelDate.id;
                                    lstDeleteRelDate.add(relDate);
                                }
                            }
                        }
                    }
                    if(oldVODVal != null && newVODVal == null || newVODVal == newStreetVal || (newVODVal != null && rel.Brand_Group__c == 'TV' && rel.Brand_Group__c == 'Catalog')){
                        system.debug('inside 12th if');
                        
                        if(releaseDateList.size() > 0){
                            for(Release_Date__c vodRelDate : releaseDateList){
                                if(vodRelDate.Release_Date_Type__c == 'VOD Street Date' && rel.Id == vodRelDate.Release__c){
                                    Release_Date__c relDate = new Release_Date__c();
                                    relDate.id = vodRelDate.id;
                                    lstDeleteRelDate.add(relDate);
                                }
                            }
                        }
                    }
                }
                
                if(rel.Street_Date__c != null && Trigger.newMap.get(rel.Id).Street_Date__c!= Trigger.oldMap.get(rel.Id).Street_Date__c){               
                    
                    releaseId.add(rel.Id);
                }  
                
            }
            if(lstDeleteRelDate.size() > 0){
                delete lstDeleteRelDate;
            }
            
            // Added for RE-60
            if(!TriggerUtility.initiatedFromDeal)    // Added for REL-174
                ReleaseTriggerHandler.syncReleaseDates();
        }
        //added as part of REL-43
        if(trigger.isAfter && trigger.isUpdate && !TriggerUtility.checkMassChatterPost)
        {
            //ReleaseTriggerHandler.chatterPostOnFieldChange(Trigger.old, Trigger.new);
            ReleaseTriggerHandler.EmailCommunicationOnFieldChange(Trigger.oldmap, Trigger.newmap);
        }
        if(Trigger.isInsert){
            for(Release__c rel : Trigger.new){
                System.debug('####rel.VOD_Street_Date__c'+rel.VOD_Street_Date__c+'$$$rel.Street_Date__c'+rel.Street_Date__c);
                
                if(rel.EST_Date__c != null && rel.Brand_Group__c != 'TV' && rel.Brand_Group__c != 'Catalog'){
                    System.debug('####rel.EST_Date__c'+rel.EST_Date__c+'####rel.Brand_Group'+rel.Brand_Group__c);
                    Release_Date__c relDate = new Release_Date__c();
                    relDate.Release__c = rel.id;
                    relDate.Release_Date_Type__c = 'EST Date';
                    relDate.Release_Date__c = rel.EST_Date__c;
                    relDate.Distributor__c = rel.Distributor__c;
                    relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                    relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                    relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                    relDate.Release_Pattern__c = rel.Release_Patterns__c;
                    relDate.Visual_Format__c = rel.Visual_Format__c;
                    relDate.Brand_Group__c = rel.Brand_Group__c;
                    relDate.Label_Code__c = rel.Label_Code__c;
                    relDate.Acquisition__c = rel.Acquisition__c;                    
                    lstRelDate.add(relDate);
                    
                }
                if(rel.Street_Date__c != null){
                    Release_Date__c relDate = new Release_Date__c();
                    relDate.Release__c = rel.id;
                    relDate.Release_Date_Type__c = 'Street Date';
                    //relDate.Release_Date__c = rel.Street_Date__c;
                    relDate.Distributor__c = rel.Distributor__c;
                    relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                    relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                    relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                    relDate.Release_Pattern__c = rel.Release_Patterns__c;
                    relDate.Visual_Format__c = rel.Visual_Format__c;
                    relDate.Brand_Group__c = rel.Brand_Group__c;
                    relDate.Label_Code__c = rel.Label_Code__c;
                    relDate.Acquisition__c = rel.Acquisition__c;                    
                    lstRelDate.add(relDate);
                }
                if(rel.First_Theatrical_Date__c != null){
                    Release_Date__c relDate = new Release_Date__c();
                    relDate.Release__c = rel.id;
                    relDate.Release_Date_Type__c = 'Theatrical Release Date';
                    //relDate.Release_Date__c = rel.First_Theatrical_Date__c;
                    relDate.Distributor__c = rel.Distributor__c;
                    relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                    relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                    relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                    relDate.Release_Pattern__c = rel.Release_Patterns__c;
                    relDate.Visual_Format__c = rel.Visual_Format__c;
                    relDate.Brand_Group__c = rel.Brand_Group__c;
                    relDate.Label_Code__c = rel.Label_Code__c;
                    relDate.Acquisition__c = rel.Acquisition__c;                    
                    lstRelDate.add(relDate);
                }
                // Added condition to prevent creation fo VOD Release Date record if date is equal to Street Date JE 9/29
                if((rel.VOD_Street_Date__c != null && rel.Street_Date__c != rel.VOD_Street_Date__c) && rel.Brand_Group__c != 'TV' && rel.Brand_Group__c != 'Catalog'){
                    system.debug('rel.VOD_Street_Date__c== '+rel.VOD_Street_Date__c);
                    Release_Date__c relDate = new Release_Date__c();
                    relDate.Release__c = rel.id;
                    relDate.Release_Date_Type__c = 'VOD Street Date';
                    //relDate.Release_Date__c = rel.VOD_Street_Date__c;
                    relDate.Distributor__c = rel.Distributor__c;
                    relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                    relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                    relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                    relDate.Release_Pattern__c = rel.Release_Patterns__c;
                    relDate.Visual_Format__c = rel.Visual_Format__c;
                    relDate.Brand_Group__c = rel.Brand_Group__c;
                    relDate.Label_Code__c = rel.Label_Code__c;
                    relDate.Acquisition__c = rel.Acquisition__c;           
                    lstRelDate.add(relDate);
                }
                
                if(rel.Alternate_Physical_Street_Date__c != null){
                    Release_Date__c relDate = new Release_Date__c();
                    relDate.Release__c = rel.id;
                    relDate.Release_Date_Type__c = 'Alternate Street Date';
                    //relDate.Release_Date__c = rel.Alternate_Physical_Street_Date__c;
                    relDate.Distributor__c = rel.Distributor__c;
                    relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                    relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                    relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                    relDate.Release_Pattern__c = rel.Release_Patterns__c;
                    relDate.Visual_Format__c = rel.Visual_Format__c;
                    relDate.Brand_Group__c = rel.Brand_Group__c;
                    relDate.Label_Code__c = rel.Label_Code__c;
                    relDate.Acquisition__c = rel.Acquisition__c;                    
                    lstRelDate.add(relDate);
                } 
                
                if(rel.Alternate_EST_Date__c != null){
                    Release_Date__c relDate = new Release_Date__c();
                    relDate.Release__c = rel.id;
                    relDate.Release_Date_Type__c = 'Alternate EST Date';
                    //relDate.Release_Date__c = rel.Alternate_EST_Date__c;
                    relDate.Distributor__c = rel.Distributor__c;
                    relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                    relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                    relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                    relDate.Release_Pattern__c = rel.Release_Patterns__c;
                    relDate.Visual_Format__c = rel.Visual_Format__c;
                    relDate.Brand_Group__c = rel.Brand_Group__c;
                    relDate.Label_Code__c = rel.Label_Code__c;
                    relDate.Acquisition__c = rel.Acquisition__c;                    
                    lstRelDate.add(relDate);
                } 
                if(rel.Alternate_VOD_Date__c != null){
                    Release_Date__c relDate = new Release_Date__c();
                    relDate.Release__c = rel.id;
                    relDate.Release_Date_Type__c = 'Alternate VOD Street Date';
                    //relDate.Release_Date__c = rel.Alternate_VOD_Date__c;
                    relDate.Distributor__c = rel.Distributor__c;
                    relDate.Distributor_Short_Name__c = rel.Distributor_Short_Name__c;
                    relDate.DOM_Box_Office_Total__c = rel.DOM_Box_Office_Total__c;
                    relDate.DOM_Open_W_E_Total__c = rel.DOM_Open_W_E_Total__c;
                    relDate.Release_Pattern__c = rel.Release_Patterns__c;
                    relDate.Visual_Format__c = rel.Visual_Format__c;
                    relDate.Brand_Group__c = rel.Brand_Group__c;
                    relDate.Label_Code__c = rel.Label_Code__c;
                    relDate.Acquisition__c = rel.Acquisition__c;                    
                    lstRelDate.add(relDate);
                }   
            }
            insert lstRelDate;  
            for(Release__c rel : Trigger.New){
                releaseId.add(rel.Id);
            }
            
            // Modified RE-60
            ReleaseTriggerHandler.syncReleaseDates();
            
            //added as part of REL-43
            if(trigger.isAfter && trigger.isInsert && !TriggerUtility.checkMassFollow){
                Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();
                System.debug('massFollowRelease');
                Set<Id> setRelIds = new Set<Id>();
                for(Release__c rel : trigger.new)
                {
                    if(rel.RecordTypeId != CompRecordTypeId && Email_Notify_Label_Codes__c.getInstance(rel.Label_code__c) != null) //USST-2743
                    {   
                        setRelIds.add(rel.Id);
                    }
                }   
                MassNotifyTriggerHandler.massFollowRelease(setRelIds);
            }
            
        }
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            system.debug('release insert entry');
            //Variable for storing profile details
            String profileName; 

            //Get profile name from trigger utility
            IF (TriggerUtility.currentUser != null){
                profileName = TriggerUtility.currentUser.Profile.Name;
            }

            System.Debug('Profile Value Found>>> '+profileName);      

            Set<Id> titleIds = new Set<Id>();
            List<Distributor_Date__c> distributors = [select id, Distributor__c, HE_Major__c,Theatrical_to_BD_DVD__c,Theatrical_to_VOD__c,EST_to_BD_DVD__c from Distributor_Date__c ];            
            Map<String, Boolean> dHEMajorMap = new Map<String, Boolean>();
            
            ReleaseTriggerHandler.updateBrandGroup(Trigger.new);
            
            for(Distributor_Date__c d : distributors){
                dHEMajorMap.put(d.Distributor__c, d.HE_Major__c);
            }
            //system.debug('start release for loop entry');
            for(Release__c rel : Trigger.new){
                //system.debug('release for loop entry');
                
                List<Distributor_Date__c> dDateList = new List<Distributor_Date__c>();
                Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();
                Id ThrtRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
                
                if(rel.Title__c!=null)
                    titleIds.add(rel.Title__c);
                //Default indicators to 'Exclude'
                rel.Master_Schedule_Indicator__c = 'Exclude';
                rel.Pretty_Indicator__c = 'Exclude';                
                //system.debug('release territory-->'+TriggerUtility.releaseCloneTerritory);
                if(profileName == 'Platform API' ){                
                    rel.Master_Schedule_Indicator__c = 'Include';                
                    
                    //Check Competitive Release to see if Distributor is on Map
                    if(rel.Distributor__c != null){ 
                        //Check map, if HE Major true then update indicators (ignore null or false) 
                        if(dHEMajorMap.get(rel.Distributor__c) == true){
                            rel.Pretty_Indicator__c = 'Include';                        
                        }
                    }
                }
                else if((!(TriggerUtility.checkFromCloning) ) && (rel.Brand_Group__c == 'Universal Pictures' || rel.Brand_Group__c == 'Partners' || rel.Brand_Group__c == 'Family' )){
                    rel.Master_Schedule_Indicator__c = 'Include';
                    rel.Pretty_Indicator__c = 'Include';
                }
                else if((!(TriggerUtility.checkFromCloning) ) && (rel.Brand_Group__c == '1440' || rel.Brand_Group__c == 'Content Group')){ //USST-2972
                    rel.Master_Schedule_Indicator__c = 'Include';
                    rel.Pretty_Indicator__c = 'Exclude';
                }
                else if((!(TriggerUtility.checkFromCloning) ) && (rel.Brand_Group__c == 'TV' || rel.Brand_Group__c == 'Catalog')){
                    rel.Master_Schedule_Indicator__c = 'Include';                        
                }
                
                if(rel.Distributor__c != null){
                    dDateList = [select id, Distributor__c, HE_Major__c,Theatrical_to_BD_DVD__c,Theatrical_to_VOD__c,EST_to_BD_DVD__c from Distributor_Date__c where Distributor__c = : rel.Distributor__c LIMIT 1];
                    if(rel.recordTypeId == CompRecordTypeId || rel.recordTypeId == ThrtRecordTypeId){
                        system.debug('Brand Group==== '+rel.createdBy.Brand_Group__c);
                        
                        if(dDateList.size() > 0){
                            for(Distributor_Date__c dDate : dDateList){
                                system.debug('brand group=== '+rel.Brand_Group__c);
                                system.debug('HE Major=== '+dDate.HE_Major__c);
                                
                                if(rel.First_Theatrical_Date__c != null){
                                    if(dDate.Theatrical_to_BD_DVD__c != null){
                                        rel.Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_BD_DVD__c);
                                        rel.Theatrical_to_BD_DVD__c = dDate.Theatrical_to_BD_DVD__c;
                                    }
                                    else{
                                        rel.Street_Date__c = rel.First_Theatrical_Date__c;
                                    }
                                }
                                if(rel.First_Theatrical_Date__c != null){
                                    if(dDate.Theatrical_to_VOD__c != null ){
                                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972                                  
                                            rel.VOD_Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_VOD__c);
                                        rel.Theatrical_to_VOD__c = dDate.Theatrical_to_VOD__c;
                                    }
                                    else{
                                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                            rel.VOD_Street_Date__c = rel.Street_Date__c;
                                    }
                                }
                                if(rel.Street_Date__c != null){
                                    if(dDate.EST_to_BD_DVD__c != null){
                                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                            rel.EST_Date__c = rel.Street_Date__c - Integer.valueOf(dDate.EST_to_BD_DVD__c);
                                        rel.EST_to_BD_DVD__c = dDate.EST_to_BD_DVD__c;
                                    }
                                    else{
                                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                            rel.EST_Date__c = rel.Street_Date__c;
                                    }
                                }
                            }
                        }
                        else{
                            dDateList = [select id, Distributor__c, HE_Major__c,Theatrical_to_BD_DVD__c,Theatrical_to_VOD__c,EST_to_BD_DVD__c from Distributor_Date__c where Distributor__c = 'All Others' LIMIT 1];
                            for(Distributor_Date__c dDate : dDateList){
                                if(rel.First_Theatrical_Date__c != null){
                                    if(dDate.Theatrical_to_BD_DVD__c != null){
                                        rel.Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_BD_DVD__c);
                                        rel.Theatrical_to_BD_DVD__c = dDate.Theatrical_to_BD_DVD__c;
                                    }
                                    else{
                                        rel.Street_Date__c = rel.First_Theatrical_Date__c;
                                    }
                                }
                                if(rel.First_Theatrical_Date__c != null){
                                    if(dDate.Theatrical_to_VOD__c != null ){
                                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                            rel.VOD_Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_VOD__c);
                                        rel.Theatrical_to_VOD__c = dDate.Theatrical_to_VOD__c;
                                    }
                                    else{
                                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                            rel.VOD_Street_Date__c = rel.Street_Date__c;
                                    }
                                }
                                if(rel.Street_Date__c != null){
                                    if(dDate.EST_to_BD_DVD__c != null){
                                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                            rel.EST_Date__c = rel.Street_Date__c - Integer.valueOf(dDate.EST_to_BD_DVD__c);
                                        rel.EST_to_BD_DVD__c = dDate.EST_to_BD_DVD__c;
                                    }
                                    else{
                                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                            rel.EST_Date__c = rel.Street_Date__c;
                                    }
                                }   
                            }
                        }
                    }
                }
                else{
                    dDateList = [select id, Distributor__c, HE_Major__c,Theatrical_to_BD_DVD__c,Theatrical_to_VOD__c,EST_to_BD_DVD__c from Distributor_Date__c where Distributor__c = 'All Others' LIMIT 1];
                    for(Distributor_Date__c dDate : dDateList){

                        if(rel.First_Theatrical_Date__c != null){
                            if(dDate.Theatrical_to_BD_DVD__c != null){
                                rel.Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_BD_DVD__c);
                                rel.Theatrical_to_BD_DVD__c = dDate.Theatrical_to_BD_DVD__c;
                            }
                            else{
                                rel.Street_Date__c = rel.First_Theatrical_Date__c;
                            }
                        }
                        if(rel.First_Theatrical_Date__c != null){
                            if(dDate.Theatrical_to_VOD__c != null ){
                                if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                    rel.VOD_Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_VOD__c);
                                rel.Theatrical_to_VOD__c = dDate.Theatrical_to_VOD__c;
                            }
                            else{
                                if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                    rel.VOD_Street_Date__c = rel.Street_Date__c;
                            }
                        }
                        if(rel.Street_Date__c != null){
                            if(dDate.EST_to_BD_DVD__c != null){
                                if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                    rel.EST_Date__c = rel.Street_Date__c - Integer.valueOf(dDate.EST_to_BD_DVD__c);
                                rel.EST_to_BD_DVD__c = dDate.EST_to_BD_DVD__c;
                            }
                            else{
                                if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                    rel.EST_Date__c = rel.Street_Date__c;
                            }
                        } 
                    }
                }
                //Releaseforce2.0 RE-50---Defaulting marketing contact to ownerid of release
                if(!TriggerUtility.checkFromCloning){
                    rel.marketing_contact__c=rel.OwnerId;
                }        
            }
                       
            //Get Deal id and update
            ReleaseTriggerHandler.populateDealOnBIBU();
            
            // Added for RE-60
            ReleaseTriggerHandler.syncReleaseDates(); 
        }
        if(Trigger.isUpdate && !TriggerUtility.checkFromCloning){
            Set<Id> titleIds = new Set<Id>();
                   
           Set<string> setDistributor = new Set<string>();
           for(Release__c rel : Trigger.new){
               if(rel.Distributor__c != null && rel.Distributor__c != '' && !setDistributor.contains(rel.Distributor__c)){
                   setDistributor.add(rel.Distributor__c);
               }               
           }
           
           //List<Distributor_Date__c> dDateLst = [select id, Distributor__c, HE_Major__c,Theatrical_to_BD_DVD__c,Theatrical_to_VOD__c,EST_to_BD_DVD__c from Distributor_Date__c]; //commented for 101 error USST-2894
           Map<ID,Distributor_Date__c> mapDateList = new Map<ID,Distributor_Date__c>([select id, Distributor__c, HE_Major__c,Theatrical_to_BD_DVD__c,Theatrical_to_VOD__c,EST_to_BD_DVD__c from Distributor_Date__c where   Distributor__c in : setDistributor OR Distributor__c = 'All Others']);
            
            for(Release__c rel : Trigger.new){
                
                Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();
                Id ThrtRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
              
                if(rel.Distributor__c != null){
                    if(rel.recordTypeId == CompRecordTypeId || rel.recordTypeId == ThrtRecordTypeId){
                        system.debug('Brand Group==== '+rel.createdBy.Brand_Group__c);
                        if(mapDateList.size() > 0){
                            for(Distributor_Date__c dDate : mapDateList.values()){
                                if(dDate.Distributor__c == rel.Distributor__c){
                                system.debug('Testing#@#@%%');
                                    system.debug('brand group=== '+rel.Brand_Group__c);
                                    system.debug('HE Major=== '+dDate.HE_Major__c);
                                    if(rel.First_Theatrical_Date__c != null && rel.First_Theatrical_Date__c != Trigger.OldMap.get(rel.id).First_Theatrical_Date__c){
                                        if(dDate.Theatrical_to_BD_DVD__c != null){
                                            system.debug('inside else@@@@@1111');
                                            rel.Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_BD_DVD__c);
                                            rel.Theatrical_to_BD_DVD__c = dDate.Theatrical_to_BD_DVD__c;
                                            system.debug('inside else@@@@@ sd'+rel.Street_Date__c);
                                        }
                                        else{
                                            rel.Street_Date__c = rel.First_Theatrical_Date__c;
                                        }
                                    }
                                    if(rel.First_Theatrical_Date__c != null && rel.First_Theatrical_Date__c != Trigger.OldMap.get(rel.id).First_Theatrical_Date__c){
                                        if(dDate.Theatrical_to_VOD__c != null ){
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group')  //USST-2972                                      
                                                rel.VOD_Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_VOD__c);
                                            rel.Theatrical_to_VOD__c = dDate.Theatrical_to_VOD__c;
                                        }
                                        else{
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                                rel.VOD_Street_Date__c = rel.Street_Date__c;
                                        }
                                    }
                                    if(rel.Street_Date__c != null && rel.Street_Date__c != Trigger.OldMap.get(rel.id).Street_Date__c){
                                        if(dDate.EST_to_BD_DVD__c != null && rel.brand_group__c!='Catalog' && rel.brand_group__c!='TV'){
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                                rel.EST_Date__c = rel.Street_Date__c - Integer.valueOf(dDate.EST_to_BD_DVD__c);
                                            rel.EST_to_BD_DVD__c = dDate.EST_to_BD_DVD__c;
                                        }
                                        else{
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                                rel.EST_Date__c = rel.Street_Date__c;
                                        }
                                    }
                                }
                                
                                else {
                                    if(rel.Street_Date__c != null && rel.Street_Date__c != Trigger.OldMap.get(rel.id).Street_Date__c){
                                        if(dDate.EST_to_BD_DVD__c != null && rel.brand_group__c!='Catalog' && rel.brand_group__c!='TV'){
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                                rel.EST_Date__c = rel.Street_Date__c - Integer.valueOf(dDate.EST_to_BD_DVD__c);
                                            rel.EST_to_BD_DVD__c = dDate.EST_to_BD_DVD__c;
                                        }
                                        else{
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                                rel.EST_Date__c = rel.Street_Date__c;
                                        }
                                    }           
                                }
                            }
                        }
                        else{
                            for(Distributor_Date__c dDate : mapDateList.values()){
                                if(dDate.Distributor__c == 'All Others'){
                                    if(rel.First_Theatrical_Date__c != null && rel.First_Theatrical_Date__c != Trigger.OldMap.get(rel.id).First_Theatrical_Date__c){
                                        if(dDate.Theatrical_to_BD_DVD__c != null){
                                            system.debug('inside else@@@@@1111');
                                            rel.Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_BD_DVD__c);
                                            rel.Theatrical_to_BD_DVD__c = dDate.Theatrical_to_BD_DVD__c;
                                            system.debug('inside else@@@@@ sd'+rel.Street_Date__c);
                                        }
                                        else{
                                            rel.Street_Date__c = rel.First_Theatrical_Date__c;
                                        }
                                    }
                                    if(rel.First_Theatrical_Date__c != null && rel.First_Theatrical_Date__c != Trigger.OldMap.get(rel.id).First_Theatrical_Date__c){
                                        if(dDate.Theatrical_to_VOD__c != null){
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                                rel.VOD_Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_VOD__c);    
                                            rel.Theatrical_to_VOD__c = dDate.Theatrical_to_VOD__c;
                                        }
                                        else{
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                                rel.VOD_Street_Date__c = rel.Street_Date__c;
                                        }
                                    }
                                    if(rel.Street_Date__c != null && rel.Street_Date__c != Trigger.OldMap.get(rel.id).Street_Date__c){
                                        if(dDate.EST_to_BD_DVD__c != null){
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                                rel.EST_Date__c = rel.Street_Date__c - Integer.valueOf(dDate.EST_to_BD_DVD__c);
                                            rel.EST_to_BD_DVD__c = dDate.EST_to_BD_DVD__c;
                                        }
                                        else{
                                            if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                                rel.EST_Date__c = rel.Street_Date__c;
                                        }
                                    }  
                                }
                            }
                        }
                    }
                }
                else{
                    for(Distributor_Date__c dDate : mapDateList.values()){
                        if(dDate.Distributor__c == 'All Others'){
                            if(rel.First_Theatrical_Date__c != null && rel.First_Theatrical_Date__c != Trigger.OldMap.get(rel.id).First_Theatrical_Date__c){
                                if(dDate.Theatrical_to_BD_DVD__c != null){
                                    rel.Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_BD_DVD__c);
                                    rel.Theatrical_to_BD_DVD__c = dDate.Theatrical_to_BD_DVD__c;
                                }
                                else{
                                    rel.Street_Date__c = rel.First_Theatrical_Date__c;
                                }
                            }
                            if(rel.First_Theatrical_Date__c != null && rel.First_Theatrical_Date__c != Trigger.OldMap.get(rel.id).First_Theatrical_Date__c ){
                                if(dDate.Theatrical_to_VOD__c != null ){
                                    if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                        rel.VOD_Street_Date__c = rel.First_Theatrical_Date__c + Integer.valueOf(dDate.Theatrical_to_VOD__c);
                                    rel.Theatrical_to_VOD__c = dDate.Theatrical_to_VOD__c;
                                }
                                else{
                                    if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                        rel.VOD_Street_Date__c = rel.Street_Date__c;
                                }
                            }
                            if(rel.Street_Date__c != null && rel.Street_Date__c != Trigger.OldMap.get(rel.id).Street_Date__c ){
                                if(dDate.EST_to_BD_DVD__c != null ){
                                    if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                        rel.EST_Date__c = rel.Street_Date__c - Integer.valueOf(dDate.EST_to_BD_DVD__c);
                                    rel.EST_to_BD_DVD__c = dDate.EST_to_BD_DVD__c;
                                }
                                else{
                                    if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV' && rel.Brand_Group__c!='Content Group') //USST-2972
                                        rel.EST_Date__c = rel.Street_Date__c;
                                }
                            } 
                        }
                    }
                }
            }
            
            //Get Deal id and update
            ReleaseTriggerHandler.populateDealOnBIBU();
            
            // Added for RE-60
            if(!TriggerUtility.initiatedFromDeal)    // Added for REL-174
                ReleaseTriggerHandler.syncReleaseDates();
        }
    }
               
    //Code for updating TM version on Material.
     if(Trigger.isUpdate && Trigger.IsAfter && !TriggerUtility.checkFromCloning){//(Trigger.isInsert || 
           List<id> releaseList=new List<id>();
       
         for(Release__c rel:trigger.new){
             if(trigger.newMap.get(rel.id).TM_Version__c!=trigger.oldMap.get(rel.id).TM_Version__c){
                 releaseList.add(rel.id);
             }
         }
         if (!releaseList.isEmpty()) { //added for 101 error USST-2894         
             for(Material__c mat:[Select TM_Version_Lookup__c,id,Release__r.TM_Version__c,Release__c from material__c where Release__c in:releaseList and material_type__c='FERT']){
                 if (TriggerUtility.checkFromUpdateMaterial == false) {
                     mat.TM_Version_Lookup__c=mat.Release__r.TM_Version__c;
                     lstMaterial.add(mat);
                 }
             }
         }
         
         try{
             if(!lstMaterial.isEmpty()){
                 update lstMaterial;
             }
         }
         catch(Exception e){
             System.debug(e);
         }
    }
    
    //if(TriggerUtility.releaseTriggerExecuted()){    
        if(Trigger.isAfter && Trigger.isUpdate && !TriggerUtility.checkFromCloning){
            List<Release__c> lstRel = new List<Release__c>();
            For(Release__c rel : (List<Release__c>)Trigger.New){
                if(rel.v_Project__c == null){
                    lstRel.add(rel);
                }
            }
            
            if(!lstRel.isEmpty()){
                vProjectUtility.createVProject(lstRel);
            }           
        }
    //}
    if(Trigger.isAfter && Trigger.isUpdate && !TriggerUtility.checkFromCloning){
        vProjectUtility.updateVProjectfromRelease(trigger.new);
    }
    //Releaseforce 2.0 RE-11
    Set<Id> cancelRelId=new Set<Id>();
    
    if(Trigger.isAfter && (Trigger.isUpdate ) && !TriggerUtility.checkFromCloning){ //|| Trigger.isInsert
        Set<Id> relId = new set<Id>();
        Set<Id> releaseIdContact=new set<Id>();//RE-50
        String profileName; 
        
        //Get profile name from trigger utility
        IF (TriggerUtility.currentUser != null){
            profileName = TriggerUtility.currentUser.Profile.Name;
        }

        for(Release__c each : trigger.new){

            if(trigger.oldMap.get(each.id).street_date__c != trigger.NewMap.get(each.id).street_date__c){
                relId.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).First_Theatrical_Date__c != trigger.NewMap.get(each.id).First_Theatrical_Date__c){
                relId.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).Pre_Order_Close_Date__c != trigger.NewMap.get(each.id).Pre_Order_Close_Date__c){
                relId.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).Trade_Solicitation_Date__c != trigger.NewMap.get(each.id).Trade_Solicitation_Date__c){
                relId.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).Internal_Announce_Date__c != trigger.NewMap.get(each.id).Internal_Announce_Date__c){
                relId.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).EST_Date__c != trigger.NewMap.get(each.id).EST_Date__c){
                relId.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).Windowed_Rental_Street_Date__c != trigger.NewMap.get(each.id).Windowed_Rental_Street_Date__c){
                relId.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).Windowed_Rental_Pre_Order_Close_Date__c != trigger.NewMap.get(each.id).Windowed_Rental_Pre_Order_Close_Date__c){
                relId.add(each.id);  
            }
            //Releaseforce2.0 RE-50----Contact updates on Release---start
            if(trigger.oldMap.get(each.id).Creative_Contact__c != trigger.NewMap.get(each.id).Creative_Contact__c){
                releaseIdContact.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).Manufacturing_Contact__c != trigger.NewMap.get(each.id).Manufacturing_Contact__c){
                releaseIdContact.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).Marketing_Contact__c != trigger.NewMap.get(each.id).Marketing_Contact__c){
                releaseIdContact.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).Master_Data_Contact__c != trigger.NewMap.get(each.id).Master_Data_Contact__c){
                releaseIdContact.add(each.id);  
            }
            if(trigger.oldMap.get(each.id).Tech_Ops_Contact__c != trigger.NewMap.get(each.id).Tech_Ops_Contact__c){
                releaseIdContact.add(each.id);  
            }
             //USST-3239 --- start
            if(trigger.oldMap.get(each.id).Publicity_Contact__c != trigger.NewMap.get(each.id).Publicity_Contact__c){
                releaseIdContact.add(each.id);  
            }
            //USST-3239 --- end
            //Releaseforce2.0 RE-50----Contact updates on Release---end
            
           //RE-19 As per story Brand group changes shouldn't create any update materials hence commenting
            /*if(trigger.oldMap.get(each.id).Brand_Group__c != trigger.NewMap.get(each.id).Brand_Group__c){
                relId.add(each.id);  
            }*/
            //RE-11 --- create task to cancel VProject on cancellation of release.
            if(trigger.oldMap.get(each.id).Release_Status__c != trigger.NewMap.get(each.id).Release_Status__c && trigger.NewMap.get(each.id).Release_Status__c=='Cancelled'){
                cancelRelId.add(each.id);  
            }
        }
        System.debug('relid11111111-----'+relId);
        if(relId.size()>0) { 
            if(profileName != 'Platform API'){
              ReleaseTriggerHandler.updateMaterialDate(relId);
            }
        }
        //RE-50
        if(releaseIdContact.size()>0) { 
            //if(profileName != 'Platform API'){
                ReleaseTriggerHandler.udpateContactsToMaterial(releaseIdContact);
           // }
        } 
    }
    if(trigger.isBefore && (trigger.isInsert || (trigger.isUpdate && !TriggerUtility.checkFromCloning))){
        ReleaseTriggerHandler.calculateKeyDatesonRelease(Trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate && !TriggerUtility.checkFromCloning){ //DFOR-1528 changed to after update because of rollup summary field on release.
        //changed for 101 error - USST-2780
        List<Release__c> lstRel = new List<Release__c>();
        for (Release__c rel : trigger.new) {
            if (rel.Cancel_Release__c == true) {
                lstRel.add(rel);
            }
        }
        if (lstRel.size() > 0) {
            ReleaseTriggerHandler.cancelRelease(lstRel);
        }
        //changed for 101 error - USST-2780
        
        //ReleaseTriggerHandler.cancelRelease(trigger.new); //changed for 101 error - USST-2780
    }
    
     //RE-11 --- create task to cancel VProject on cancellation of release.
    if(cancelRelId.size()>0){
        System.debug('###----CancelRelease'+cancelRelId);
        vProjectUtility.cancelVProject(cancelRelId);
    }
    
    
    if(trigger.isBefore && trigger.isUpdate && !TriggerUtility.checkFromCloning){
        system.debug('release before updating in process');
        
        Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();
        Id ThrtRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
    
        
        for(Release__c rel : trigger.new){
            if(rel.recordTypeId == CompRecordTypeId && rel.Title__c!= null && rel.SGENNO_ReadOnly__c!=null){
                system.debug('release record type update++++++');
                rel.recordTypeId = ThrtRecordTypeId;
            }
            if(rel.Deal__c == null)rel.Deal_ID__c = '';
            if(rel.street_date__c != trigger.oldMap.get(rel.id).street_date__c){
                rel.Previous_Street_Date__c = trigger.oldMap.get(rel.id).street_date__c;
            }
        }
        //system.debug('release record type--> '+rel.recordTypeId);
    }
   }
   if(trigger.isAfter && trigger.isUpdate){
        //chatterOnDateUpdate.chatterOnMaterialDateUpdate(trigger.new);
        //ReleaseTriggerHandler.copyDealFromReleaseToMaterials(trigger.new); //Added for usst-2477. Modified for REL-136 
    }
    //DFOR - 2780 start
        if(!DGF_TriggerUtility.hasTriggerExecuted('Release__c') && DGF_TriggerUtility.executeReleaseTrigger/*&& !TriggerUtility.checkFromQueueable*/) { //added as part of DFOR-78
    
        system.debug('Go to Sync digital release');
        DGF_SyncDigitalRelease__c csSyncRelease = DGF_SyncDigitalRelease__c.getValues(DGF_Constants.CS_RELEASE_SYNC);
        
        if(csSyncRelease == null || csSyncRelease.Sync_Release__c == FALSE){
            return;
        }
        
        if(Trigger.isAfter){
            system.debug('ETL testing');
            //creating an instance of queueable job
            DGF_QueueableRFAndDGFIntegration instanceDefaults = new DGF_QueueableRFAndDGFIntegration();
            
            //if after insert context
            if(Trigger.isInsert){
                instanceDefaults.mapReleaseNew = Trigger.NewMap;
                instanceDefaults.triggerContext = DGF_Constants.AFTER_INSERT;
                  
            }
            //if after update context
            else if(Trigger.isUpdate){
                            system.debug('ETL testing');
                instanceDefaults.mapReleaseNew = Trigger.NewMap;
                instanceDefaults.mapReleaseOld = Trigger.OldMap;
                instanceDefaults.triggerContext = DGF_Constants.AFTER_UPDATE;
            }
            //if after delete context
            else if(Trigger.isDelete){
                instanceDefaults.mapReleaseOld = Trigger.OldMap;
                instanceDefaults.triggerContext = DGF_Constants.AFTER_DELETE;
            }
            system.debug('DGF_TriggerUtility.isJobAdded is ' + DGF_TriggerUtility.isJobAdded);
            system.debug('instanceDefaults.mapReleaseNew is ' + instanceDefaults.mapReleaseNew);
            //DFOR-1272: if condition added to ensure that job is added to the queue only once. 
            //RF code was triggering update event in insert context which was adding job twice in the queue.            
            //Due to this two digital release were getting created
            if (!DGF_TriggerUtility.isJobAdded) {
                //adding job to queue
                try {
                                system.debug('ETL testing');
                    System.enqueueJob(instanceDefaults);
                }
                catch(Exception ex)  {
                    system.debug('Another job is already enqueued');
                }
                //changing the value of boolean so that if block is not executed again
                DGF_TriggerUtility.isJobAdded = TRUE;
            }                              
        }
        else if(Trigger.isBefore){
            if(Trigger.isInsert){
                DGF_AutoReleaseCreationHandler.executeOnBeforeInsert();
            }
            else if(Trigger.isUpdate){
                            system.debug('ETL testing');
                System.debug('CALLING BEFORE UPDATE>>>>>>>>> AUTORELEASE');
                
                DGF_AutoReleaseCreationHandler.executeOnBeforeUpdate();
            }
        }
    }  
    //DFOR - 2780 End 
    // Adding the below piece of code for 2248
   if(Trigger.isBefore && Trigger.isUpdate){
        Set<Id> lstReleaseId = new Set<Id>();
        Set<Id> lstReleaseMatId = new Set<Id>();
        Map<Id, Boolean> relMatIds = new Map<Id, Boolean>();
        Set<Id> associatedMaterialIds = new Set<Id>(); // This is used to hold the top level fert material
        Boolean havingnonFRValue;
        havingnonFRValue = false;
        //USST-2877 --- start
        String profileName; 
        if (TriggerUtility.currentUser != null){
            profileName = TriggerUtility.currentUser.Profile.Name;
        }   
        //USST-2877 --- end        
        for(Release__c objRel : Trigger.new){
           if((objRel.Street_Date__c != Trigger.oldMap.get(objRel.Id).Street_Date__c || 
               objRel.First_Theatrical_Date__c != Trigger.oldMap.get(objRel.Id).First_Theatrical_Date__c || 
               objRel.EST_Date__c != Trigger.oldMap.get(objRel.Id).EST_Date__c || 
               objRel.Windowed_Rental_Street_Date__c != Trigger.oldMap.get(objRel.Id).Windowed_Rental_Street_Date__c) &&
              profileName != 'System Administrator' && profileName != 'Limited Administrator' && profileName != 'Platform API' && profileName != 'Master Data Admin') //USST-2877 //USST-3008
           {
                lstReleaseId.add(objRel.id);
            }
        }
        // will get the associated releasematerial from list of releaseId
        for(Release_Material__c  objRel : [Select id,Name,Material__c,Material__r.Material_Type__c from Release_Material__c  where Release__c in: lstReleaseId and Material__r.Material_Type__c = 'FERT']){
            lstReleaseMatId.add(objRel.Material__c);
                if(objRel.Material__c != null ){
                    relMatIds.put(objRel.Material__c, true);
                }
        }
        // To diffentiate 1st level and 2nd level fert material iterating Bom_item
        //commented for USST-2803
        /*for(BOM_Item__c bom : [SELECT Material__c,Name, Material_Component__c,Material__r.Name,Material_Component__r.Name
                                   FROM BOM_Item__c 
                                   WHERE Material__c IN :relMatIds.keySet() AND Material_Component__c IN :relMatIds.keySet()]) // will get all release associated bom records from this where condition
        {
            if(bom.Material_Component__c != null && relMatIds.containsKey(bom.Material_Component__c)){
                  relMatIds.put(bom.Material_Component__c, false);
             }
    
        }*///commented for USST-2803
        // Below itertaion will get the top-level fert material
        for(Id matId : relMatIds.keySet()){
           //if(relMatIds.get(matId)){ //USST-2803
                associatedMaterialIds.add(matId);
           //}    //USST-2803
        }
        // Checking the D-chain Spec value by using inner query
        for(Material__c objMat : [select id,Name,Format__c,Item_Code__c,Material_Status__c ,(select id,Name,D_Chain_Spec__c  from Sales__r where D_Chain_Spec__c <> 'FR - Future Release'),Release__c from Material__c where id in : associatedMaterialIds]){
        // Adding Baby FERT and EST condition for newly added condition in 2248
            if(objMat.Sales__r.size()>0 && objMat.Release__c != null && objMat.Material_Status__c != 'Draft' ){
            if((objMat.Format__c !='08 - EST (ELECTRONIC SELL THRU)' && objMat.Item_Code__c !='BF - BABY FERT')){
                    havingnonFRValue = True;
                    break;
                }
            }
        }
        if(havingnonFRValue){
            for(Release__c objRelease : Trigger.New){
                  system.debug('Checking the release id---'+objRelease.id);
                  if(!TriggerUtility.checkFromQueueable){
                    Trigger.newMap.get(objRelease.id).addError('Date changes cannot be made due to Materials being orderable. Please contact Master Data for any questions.');
                   }
            }
        }
        else{}    
        //USST-2714
        for(Release_Material__c  objRel : [Select id,Release__c,Name,Material__c,Material__r.Material_Status__c from Release_Material__c  where Release__c in: lstReleaseId]){
              if(objRel.Material__r.Material_Status__c == 'Submitted'){
                 Trigger.newMap.get(objRel.Release__c).addError('Cannot submit date changes for Release with materials in \'Submitted\' status. Please call back the materials to \'Draft\' status before making a date change or wait until materials have been approved and are \'Processed in SAP\'.'); 
                 break;          
             }
        }
      }  
        // end of 2248 functionalities
  
}