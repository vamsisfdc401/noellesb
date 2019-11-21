/*****************************************************************************************
Class Name: legalSummaryViewsOnAcqDeal 
Purpose: Apex class for the VF pages LAQ_LegalSummaryViewsApproved and LAQ_LegalSummaryViewsNonApproved to display the summary fields on a pdf vf page
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             4/08/2016            Ashwini                  Initial Development
******************************************************************************************/
public class legalSummaryViewsOnAcqDeal {
    
    public Acquisition_Deal__c currentDeal {get; set;}
    public Title__c approvedTitle {get; set;}
    public Title__c nonApprovedTitle {get; set;}
    public Primary_Terms__c approvedPT {get; set;}
    public Primary_Terms__c nonApprovedPT {get; set;}
    public Financials__c approvedFinancials {get; set;}
    public Financials__c nonApprovedFinancials {get; set;}
    public Risk_Compliance__c approvedRisk {get; set;}
    public Risk_Compliance__c nonApprovedRisk {get; set;}
    public Comps__c approvedComps {get; set;}
    public Comps__c nonApprovedComps {get; set;}
    
    /************************************
    Method Name: legalSummaryViewsOnAcqDeal
    Purpose: Constructor
    *************************************/ 
    public legalSummaryViewsOnAcqDeal(ApexPages.StandardController controller) {
        this.currentDeal = (Acquisition_Deal__c)controller.getRecord(); 
        approvedTitle = new Title__c ();
        nonApprovedTitle = new Title__c (); 
        approvedPT = new Primary_Terms__c ();  
        nonApprovedPT = new Primary_Terms__c ();   
        approvedFinancials = new Financials__c (); 
        nonApprovedFinancials = new Financials__c ();  
        approvedRisk = new Risk_Compliance__c ();   
        nonApprovedRisk = new Risk_Compliance__c (); 
        approvedComps = new Comps__c (); 
        nonApprovedComps = new Comps__c ();          
    }
    
    /************************************
    Method Name: queryRelatedObjects
    Purpose: Fetch the summary fields from the approved and working board pack records
    *************************************/ 
    public void queryRelatedObjects(){    
        currentDeal = [Select id,Title_Context__c,Title_Approved__c,Primary_Term__c,Primary_Term_Approved__c,Financials__c,Financials_Approved__c,Risk_Compliance__c,Risk_Compliance_Approved__c,Comps__c,Comps_Approved__c,Licensor__r.Name,Licensor__c from Acquisition_Deal__c where Id=:currentDeal.id];
        
        if(currentDeal.Title_Approved__c!=NULL){
            approvedTitle = [Select id,Name,LAQ_Genre__c,LAQ_Sub_Genre__c,LAQ_Cast__c,LAQ_Directors__c,LAQ_Producers__c,LAQ_Writers__c,LAQ_Original_Language__c,LAQ_Other_Languages__c,LAQ_Production_Budget__c from Title__c where id=:currentDeal.Title_Approved__c];
        }
        if(currentDeal.Title_Context__c!=NULL){
            nonApprovedTitle = [Select id,Name,LAQ_Genre__c,LAQ_Sub_Genre__c,LAQ_Cast__c,LAQ_Directors__c,LAQ_Producers__c,LAQ_Writers__c,LAQ_Original_Language__c,LAQ_Other_Languages__c,LAQ_Production_Budget__c from Title__c where id=:currentDeal.Title_Context__c];
        }        
        if(currentDeal.Primary_Term_Approved__c!=NULL){
            approvedPT = [Select id,PR_Obligation__c, Clearances_Details_of_the_Exclusions__c,Music_Payments__c,Music_Payments_Details_of_the_Exclusions__c,Other_Conditions__c,Years_of_the_Term__c,Plus_Years_if_Unrecouped__c,Plus_Sell_off_Period__c,Term_Start_Date_On__c,Term_Start_Date_On_If_Other__c,Extend_the_Term__c,
                                 Acquire_future_productions__c,Acquire_reserved_territories__c,Acquire_reserved_rights__c,Other_please_list__c,Other_Options_details__c,Future_production_details__c,Cross_collaterisation__c,Licensors_Release_Condition__c,Licensors_Release_Condition_Details__c,Universal_Release_Condition__c,Universal_Release_Condition_Details__c,Deal_Structure__c,
                                 Other_Deal_Structure__c,Interest__c,Interest_Caps__c,Interest_Source__c,DLT_Origination__c,DLT_Origination_Caps__c,Central_Marketing__c,Central_Marketing_Caps__c,MG_Checkbox__c,MG_Caps__c,Delivery_Materials__c,Delivery_Materials_Caps__c,Clearances__c,Clearances_Caps__c,P_A__c,P_A_Caps__c,Television_Costs__c,Television_Costs_Caps__c,Other_Costs__c,Other_Costs_Caps__c,Costs_on_Universals_resp__c,Signature_payterms__c,
                                 Acceptance_of_Delivery_pt__c,Fulfilment_of_Release_Condition_pt__c,First_Release_by_Universal_pt__c,Fulfilment_of_Talent_PR_obl_pt__c,Commencement_of_Princ_Photo_pt__c,Commencement_of_Post_Prod_pt__c,Other_pt__c,Other_Payment_Terms__c,Other_Financial_Terms__c,Acquisition_Territories__c,Other_Territories__c,Exclusion_within_Territories__c,
                                 Free_TV_If_Chosen_Paid_On__c, Catchup_TV_If_Chosen_Paid_On__c, Pay_TV_if_chosen_output_Paid_On__c, Catch_UP_TV_Paid_On__c, Airlines_Paid_On__c, Ship_Rights_Paid_On__c, Other_Rights_Paid_On__c,   
                                 Clip_Promotional__c, NonTheatrical_Promotional__c, Merchandising_Promotional__c, Literary_Publishing_Promotional__c, Interactive_Promotional__c, Theme_Park_Promotional__c, Sponsorship_Promotional__c,Audio_Only_Promotional__c,Stage_Play_Promotional__c,Soundtrack_Promotional__c,Airlines_Promotional__c,Ship_Promotional__c,Other_Promotional__c, 
                                 Home_Video_Percent_for_Catalogue__c,EST_Percent_for_Catalogue__c,TVOD_Percent_for_Catalogue__c,SVOD_Percent_for_Catalogue__c,FVOD_AVOD_Percent_for_Catalogue__c,PPV_Percent_for_Catalogue__c,Home_Video_Percent_for_New_Release__c,EST_Percent_for_New_Release__c,TVOD_Percent_for_New_Release__c,SVOD_Percent_for_New_Release__c,FVOD_AVOD_Percent_for_New_Release__c,PPV_Percent_for_New_Release__c,
                                 Explanation_Intro__c,TVOD_Paid_On__c ,SVOD_Paid_On__c ,Theme_Park_Paid_On__c,Theatrical_Paid_On__c,Stage_Play_Paid_On__c,Sponsorship_Paid_On__c,Soundtrack_Paid_On__c,Pay_TV_Paid_On__c,NonTheatrical_Paid_On__c,Merchandising_Paid_On__c,Literary_Publ_Paid_On__c,Interactive_Paid_On__c,Paid_On_Home_Ent__c,
                                 Holdbacks_intro__c,All_Rights_Universal_Holdbacks__c,All_Rights_Licensor_Holdbacks__c,Theatrical_Universal_Holdbacks__c,Theatrical_Licensor_Holdbacks__c,Home_Video_Universal_Holdbacks__c,Home_Video_Licensor_Holdbacks__c,
                                 EST_Universal_Holdbacks__c,EST_Licensor_Holdbacks__c,TVOD_Universal_Holdbacks__c,TVOD_Licensor_Holdbacks__c,SVOD_Universal_Holdbacks__c,SVOD_Licensor_Holdbacks__c,FVOD_AVOD_Universal_Holdbacks__c,FVOD_AVOD_Licensor_Holdbacks__c,
                                 Pay_TV_Universal_Holdbacks__c,Pay_TV_Licensor_Holdbacks__c,Free_TV_Universal_Holdbacks__c,Free_TV_Licensor_Holdbacks__c,CatchUp_TV_Universal_Holdbacks__c,CatchUp_TV_Licensor_Holdbacks__c,Further_Holdbacks_Details__c,
                                 Mark_All_Rights_Acquired__c,Change_All_Rights_Paid_On__c,Theatrical_Acquired__c,Theatrical_MustHave__c,Licensor_s_Share_of_Receipts_Theatrical__c,Home_Ent_Acquired__c,Home_Ent_Must_Have__c,Licensor_s_Share_of_Receipts_DVD__c,Licensor_s_Share_of_Receipts_Blu_Ray__c,Licensor_s_Share_of_Receipts_UHD__c,EST_Acquired__c,EST_MustHave__c,
                                 TVOD_Acquired__c,TVOD_MustHave__c,SVOD_Acquired__c,FVOD_AVOD_Acquired__c,FVOD_AVOD_MustHave__c,PPV_Acquired_Rights__c,PPV_Must_Have_Rights__c,Pay_TV_Acquired__c,Pay_TV_MustHave__c,Licensor_s_Share_of_Rec_Pay_TV__c,Pay_If_Chosen__c,Free_TV_Acquired__c,Free_TV_MustHave__c,Licensor_s_Share_of_Rec_Free_TV__c,Catch_Up_TV_Acquired__c,Catch_Up_TV_MustHave__c,Licensor_s_Share_of_Rec_Catch_Up_TV__c,Further_Details_Primary__c,Universal_s_Share_of_Receipts_Primary__c,
                                 NonTheatrical_Acquired__c,NonTheatrical_MustHave__c,Licensor_s_Share_of_Receipts_NonTheatric__c,Merchandising_Acquired__c,Merchandising_MustHave__c,Licensor_s_Share_of_Rec_Merchandising__c,Literary_Publishing_Acquired__c,Literary_Publishing_MustHave__c,Licensor_s_Share_of_Rec_Literary_Publ__c,Clip_Acquired__c,Clip_MustHave__c,Licensor_s_Share_of_Rec_Clip__c,Clip_Non_Exclusive__c,Interactive_Acquired__c,Interactive_MustHave__c,Licensor_s_Share_of_Rec_Interactive__c,Theme_Park_Acquired__c,Theme_Park_MustHave__c,Licensor_s_Share_of_Rec_Theme_Park__c,Sponsorship_Acquired__c,
                                 Sponsorship_MustHave__c,Licensor_s_Share_of_Rec_Sponsorship__c,Audio_Only_Acquired__c,Audio_Only_MustHave__c,Licensor_s_Share_of_Rec_Audio_Only__c,Stage_Play_Acquired__c,Stage_Play_MustHave__c,Licensor_s_Share_of_Rec_Stage_Play__c,Soundtrack_Acquired__c,Soundtrack_MustHave__c,Licensor_s_Share_of_Rec_Soundtrack__c,Airlines_Acquired_Rights__c,Airlines_Must_Have_Rights__c,Licensor_s_Share_of_Rec_Airlines__c,Ship_Acquired_Rights__c,Ship_Must_Have_Rights__c,Other_Acquired_Rights__c,Other_Must_Have_Rights__c,If_Other_please_list_Other_Rights__c,Licensor_s_Share_of_Rec_Other__c,
                                 Further_Details_Sec__c,Universal_Share_of_Receipts_Secondary__c,SVOD_MustHave__c,Free_TV_If_Chosen__c,CatchUp_TV_If_Chosen__c,Clearances_PL__c,EST_Paid_On__c,Audio_Only_Paid_On__c,Clip_Paid_On__c,Free_TV_Paid_On__c,FVOD_Paid_On__c,PPV_Paid_On__c,Licensor_s_Share_of_Rec_Ship__c                                   
                                 from Primary_Terms__c where id=:currentDeal.Primary_Term_Approved__c];
        }
        if(currentDeal.Primary_Term__c!=NULL){
           nonApprovedPT = [Select id,PR_Obligation__c, Clearances_Details_of_the_Exclusions__c,Music_Payments__c,Music_Payments_Details_of_the_Exclusions__c,Other_Conditions__c,Years_of_the_Term__c,Plus_Years_if_Unrecouped__c,Plus_Sell_off_Period__c,Term_Start_Date_On__c,Term_Start_Date_On_If_Other__c,Extend_the_Term__c,
                                 Acquire_future_productions__c,Acquire_reserved_territories__c,Acquire_reserved_rights__c,Other_please_list__c,Other_Options_details__c,Future_production_details__c,Cross_collaterisation__c,Licensors_Release_Condition__c,Licensors_Release_Condition_Details__c,Universal_Release_Condition__c,Universal_Release_Condition_Details__c,Deal_Structure__c,
                                 Other_Deal_Structure__c,Interest__c,Interest_Caps__c,Interest_Source__c,DLT_Origination__c,DLT_Origination_Caps__c,Central_Marketing__c,Central_Marketing_Caps__c,MG_Checkbox__c,MG_Caps__c,Delivery_Materials__c,Delivery_Materials_Caps__c,Clearances__c,Clearances_Caps__c,P_A__c,P_A_Caps__c,Television_Costs__c,Television_Costs_Caps__c,Other_Costs__c,Other_Costs_Caps__c,Costs_on_Universals_resp__c,Signature_payterms__c,
                                 Acceptance_of_Delivery_pt__c,Fulfilment_of_Release_Condition_pt__c,First_Release_by_Universal_pt__c,Fulfilment_of_Talent_PR_obl_pt__c,Commencement_of_Princ_Photo_pt__c,Commencement_of_Post_Prod_pt__c,Other_pt__c,Other_Payment_Terms__c,Other_Financial_Terms__c,Acquisition_Territories__c,Other_Territories__c,Exclusion_within_Territories__c,
                                 Free_TV_If_Chosen_Paid_On__c, Catchup_TV_If_Chosen_Paid_On__c, Pay_TV_if_chosen_output_Paid_On__c, Catch_UP_TV_Paid_On__c, Airlines_Paid_On__c, Ship_Rights_Paid_On__c, Other_Rights_Paid_On__c,   
                                 Clip_Promotional__c, NonTheatrical_Promotional__c, Merchandising_Promotional__c, Literary_Publishing_Promotional__c, Interactive_Promotional__c, Theme_Park_Promotional__c, Sponsorship_Promotional__c,Audio_Only_Promotional__c,Stage_Play_Promotional__c,Soundtrack_Promotional__c,Airlines_Promotional__c,Ship_Promotional__c,Other_Promotional__c, 
                                 Home_Video_Percent_for_Catalogue__c,EST_Percent_for_Catalogue__c,TVOD_Percent_for_Catalogue__c,SVOD_Percent_for_Catalogue__c,FVOD_AVOD_Percent_for_Catalogue__c,PPV_Percent_for_Catalogue__c,Home_Video_Percent_for_New_Release__c,EST_Percent_for_New_Release__c,TVOD_Percent_for_New_Release__c,SVOD_Percent_for_New_Release__c,FVOD_AVOD_Percent_for_New_Release__c,PPV_Percent_for_New_Release__c,
                                 Explanation_Intro__c,TVOD_Paid_On__c ,SVOD_Paid_On__c ,Theme_Park_Paid_On__c,Theatrical_Paid_On__c,Stage_Play_Paid_On__c,Sponsorship_Paid_On__c,Soundtrack_Paid_On__c,Pay_TV_Paid_On__c,NonTheatrical_Paid_On__c,Merchandising_Paid_On__c,Literary_Publ_Paid_On__c,Interactive_Paid_On__c,Paid_On_Home_Ent__c,
                                 Holdbacks_intro__c,All_Rights_Universal_Holdbacks__c,All_Rights_Licensor_Holdbacks__c,Theatrical_Universal_Holdbacks__c,Theatrical_Licensor_Holdbacks__c,Home_Video_Universal_Holdbacks__c,Home_Video_Licensor_Holdbacks__c,
                                 EST_Universal_Holdbacks__c,EST_Licensor_Holdbacks__c,TVOD_Universal_Holdbacks__c,TVOD_Licensor_Holdbacks__c,SVOD_Universal_Holdbacks__c,SVOD_Licensor_Holdbacks__c,FVOD_AVOD_Universal_Holdbacks__c,FVOD_AVOD_Licensor_Holdbacks__c,
                                 Pay_TV_Universal_Holdbacks__c,Pay_TV_Licensor_Holdbacks__c,Free_TV_Universal_Holdbacks__c,Free_TV_Licensor_Holdbacks__c,CatchUp_TV_Universal_Holdbacks__c,CatchUp_TV_Licensor_Holdbacks__c,Further_Holdbacks_Details__c,
                                 Mark_All_Rights_Acquired__c,Change_All_Rights_Paid_On__c,Theatrical_Acquired__c,Theatrical_MustHave__c,Licensor_s_Share_of_Receipts_Theatrical__c,Home_Ent_Acquired__c,Home_Ent_Must_Have__c,Licensor_s_Share_of_Receipts_DVD__c,Licensor_s_Share_of_Receipts_Blu_Ray__c,Licensor_s_Share_of_Receipts_UHD__c,EST_Acquired__c,EST_MustHave__c,
                                 TVOD_Acquired__c,TVOD_MustHave__c,SVOD_Acquired__c,FVOD_AVOD_Acquired__c,FVOD_AVOD_MustHave__c,PPV_Acquired_Rights__c,PPV_Must_Have_Rights__c,Pay_TV_Acquired__c,Pay_TV_MustHave__c,Licensor_s_Share_of_Rec_Pay_TV__c,Pay_If_Chosen__c,Free_TV_Acquired__c,Free_TV_MustHave__c,Licensor_s_Share_of_Rec_Free_TV__c,Catch_Up_TV_Acquired__c,Catch_Up_TV_MustHave__c,Licensor_s_Share_of_Rec_Catch_Up_TV__c,Further_Details_Primary__c,Universal_s_Share_of_Receipts_Primary__c,
                                 NonTheatrical_Acquired__c,NonTheatrical_MustHave__c,Licensor_s_Share_of_Receipts_NonTheatric__c,Merchandising_Acquired__c,Merchandising_MustHave__c,Licensor_s_Share_of_Rec_Merchandising__c,Literary_Publishing_Acquired__c,Literary_Publishing_MustHave__c,Licensor_s_Share_of_Rec_Literary_Publ__c,Clip_Acquired__c,Clip_MustHave__c,Licensor_s_Share_of_Rec_Clip__c,Clip_Non_Exclusive__c,Interactive_Acquired__c,Interactive_MustHave__c,Licensor_s_Share_of_Rec_Interactive__c,Theme_Park_Acquired__c,Theme_Park_MustHave__c,Licensor_s_Share_of_Rec_Theme_Park__c,Sponsorship_Acquired__c,
                                 Sponsorship_MustHave__c,Licensor_s_Share_of_Rec_Sponsorship__c,Audio_Only_Acquired__c,Audio_Only_MustHave__c,Licensor_s_Share_of_Rec_Audio_Only__c,Stage_Play_Acquired__c,Stage_Play_MustHave__c,Licensor_s_Share_of_Rec_Stage_Play__c,Soundtrack_Acquired__c,Soundtrack_MustHave__c,Licensor_s_Share_of_Rec_Soundtrack__c,Airlines_Acquired_Rights__c,Airlines_Must_Have_Rights__c,Licensor_s_Share_of_Rec_Airlines__c,Ship_Acquired_Rights__c,Ship_Must_Have_Rights__c,Other_Acquired_Rights__c,Other_Must_Have_Rights__c,If_Other_please_list_Other_Rights__c,Licensor_s_Share_of_Rec_Other__c,
                                 Further_Details_Sec__c,Universal_Share_of_Receipts_Secondary__c,SVOD_MustHave__c,Free_TV_If_Chosen__c,CatchUp_TV_If_Chosen__c,Clearances_PL__c,EST_Paid_On__c,Audio_Only_Paid_On__c,Clip_Paid_On__c,Free_TV_Paid_On__c,FVOD_Paid_On__c,PPV_Paid_On__c,Licensor_s_Share_of_Rec_Ship__c                                   
                                 from Primary_Terms__c where id=:currentDeal.Primary_Term__c];
        }
        if(currentDeal.Financials_Approved__c!=NULL){
            approvedFinancials = [Select id,Interparty_Agreement__c,MG__c from Financials__c where id=:currentDeal.Financials_Approved__c];
        }
        if(currentDeal.Financials__c!=NULL){
            nonApprovedFinancials = [Select id,Interparty_Agreement__c,MG__c from Financials__c where id=:currentDeal.Financials__c];
        }
        if(currentDeal.Risk_Compliance_Approved__c!=NULL){
            approvedRisk = [Select id,Risk_level__c,Unsecure_Payment_Risk__c,Percent_of_Unsecure_Payment__c,Steps_to_mitigate__c,Production_Services__c,Approvals__c,MG_Budget_Ratio__c from Risk_Compliance__c where id=:currentDeal.Risk_Compliance_Approved__c];
        }
        if(currentDeal.Risk_Compliance__c!=NULL){
            nonApprovedRisk = [Select id,Risk_level__c,Unsecure_Payment_Risk__c,Percent_of_Unsecure_Payment__c,Steps_to_mitigate__c,Production_Services__c,Approvals__c,MG_Budget_Ratio__c from Risk_Compliance__c where id=:currentDeal.Risk_Compliance__c];
        }
        
    }

}