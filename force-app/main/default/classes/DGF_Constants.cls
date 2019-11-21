/*****************************************************************************************
Class Name: DGF_Constants
Purpose: Class for maintaining constants used in the application
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             27/04/2017           Mohit                    Initial Development
******************************************************************************************/
public class DGF_Constants{

    public static final string PRE_ORDER = 'Pre-Order'; 
    public static final string FILM = 'Film'; 
    public static final string TV = 'TV'; 
    public static final string COMPETETIVE = 'Competitive'; 
    public static final string BUNDLE = 'Bundle'; 
    public static final string PREORDER = 'Pre-Order';
    public static final string FILM_BONUS = 'Film Bonus';
    public static final string TV_BONUS = 'TV Bonus';
    public static final string TERRITORY_US='US';
    public static final string TERRITORY_CA='CA';
    public static final string PLATFORM_VOD='VOD';
    public static final string PLATFORM_EST='EST';
    public static final string PLATFORM_IVOD='iVOD';
    public static final string PLATFORM_CVOD='cVOD';
    public static final string PRODUCT_THEATRICAL='Theatrical';
    public static final string PRODUCT_DIRECT_TO_VIDEO='Direct to Video';
    public static final string EPISODE_PRICING='Episode Pricing';
    public static final string TV_EPISODE='TV Episode';
    public static final string PROFILE_PRODUCT_USER = 'DD Product User'; 
    public static final string PROFILE_ACCOUNT_USER = 'DD Account User'; 
    public static final string PROFILE_SYS_ADMIN = 'System Administrator'; 
    public static final string ORIGINAL = 'Original';
    public static final string REPRICE = 'Reprice';
    public static final string SD = 'SD';
    public static final string HD = 'HD';
    public static final string UHD = 'UHD';
    public static final string X3D = '3D';
    public static final string iTUNES = 'iTunes';
    public static final string PRE_THEATRICAL='Pre-Theatrical';
    public static final string DAY_AND_DATE='Day and Date with Theatrical';
    public static Final string NEW_RELEASE_PREMIUM='New Release Premium';
    public static Final string NEW_RELEASE_STANDARD='New Release Standard';
    public static Final string TIER_2='Tier 2';
    public static Final string TIER_3='Tier 3';
    public static final String CURRENT='Current';
    public Static final String CATALOG='Catalog';
    public Static final String TPR_National='TPR National';
    public Static final String TPR_Account='TPR Account';
    public static final String COLLECTION = 'Collection';
    public static final String DIGITAL_PARTNER = 'Digital Partner';
    public static final String SERIES = 'Series';
    public static final String ALA_CARTE ='A la carte';
    public static final String MAIN ='Main';
    
    //below are used for DFOR-152 WSP/SRP Calculation
    public Static final Decimal DEFAULT_WSP_SRP=.7;
    public Static final Decimal DEFAULT_WSP1=.9;
    public Static final Decimal DEFAULT_WSP2=.85;
    public Static final Decimal DEFAULT_WSP3=.775;
    
    public Static final Decimal BUNDLE_iTune_WSP1=10;
    public Static final Decimal BUNDLE_iTune_WSP2=22.5;
    
    //below are used for DFOR-78 releaseforce integration
    public static Final string BG_UNIVERSAL_PICTURES ='Universal Pictures';
    public static Final string BG_1440 ='1440';
    public static Final string BG_PARTNERS ='Partners';
    public static Final string BG_FAMILY ='Family';
    public static Final string BG_CONTENT_GROUP ='Content Group'; //USST-2972
    public static Final string RT_COMPETITIVE ='Competitive';
    public static Final string RT_THEATRICAL ='Theatrical';
    public static Final string CS_RELEASE_SYNC = 'Release_Sync';
    public static final string TERRITORY_CDN ='CDN';
    public static final string TERRITORY_US_CA = 'US & CA';
    public static final string CANCELLED = 'Cancelled';
    public static final string UNCANCELLED = 'Uncancelled';
    public static final string UNIVERSAL = 'Universal';
    public static final string DD_PRODUCT_USER_CHATTER_GROUP = 'DD Product Team'; //USST-3287
    public static final string DD_OPS_USER_CHATTER_GROUP = 'DD Ops Team'; //USST-3287
    public static final string DD_ACCOUNT_USER_CHATTER_GROUP = 'Account Management Group';
    
    //constants related to Promotion
    public static final String ACCOUNT_PROMOTION='Account Promotion';
    public static final String NATIONAL_PROMOTION='National Promotion';
    public static final String FREE_EPISODE='Free Episode';
    
    //validation error messages
    public static final string DGF_Account_User_Free_Episode_Creation='Account user is not allowed to create a Free Episode';
    public static final string DGF_Account_User_Free_Episode_Deletion='Account user is not allowed to delete a Free Episode';
    public static final string DGF_Account_User_Nation_Promo_Creation='Account user is not allowed to create a National Promotion';
    public static final string DGF_Product_user_Account_Promotion_Validation='Product user is not allowed to create an Account Promotion';
    public static final String DGF_Product_User_Account_Promotion_Deletion='Product user is not allowed to delete an Account Promotion';
    public static final string DGF_Product_User_National_Promotion_Deletion='Product user is not allowed to delete a National Promotion';
    public static final String DGF_CA_EST_Date_Validation='Entered CA EST Date is greater than the Valid To Date of the Pricing Records.';
    public static final String DGF_CA_Pre_Order_Date_Validation='Entered CA Pre Order Date is greater than the Valid To Date of the Pricing Records.';
    public static final String DGF_US_EST_Date_Validation='Entered US EST Date is greater than the Valid To Date of the Pricing Records.';
    public static final String DGF_US_Pre_Order_Date_Validation='Entered US Pre Order Date is greater than the Valid To Date of the Pricing Records.';
    public static final String DGF_Enter_Valid_From_Date='Enter Valid From Date';
    public static final String DGF_Update_Valid_From_Date='Update Valid From Date. Conflict With Pricing Record for Product';
    public static final String DGF_Update_Valid_To_Date='Update Valid To Date. Conflict With Pricing Record for Product';
    public static final String DGF_RecordID='RecordID';
    public static final String DGF_Valid_From ='Valid From';
    public static final String DGF_Valid_To='Valid To';
    public static final String DGF_Please_enter_US_EST_Date_on_the_Release='Please enter US EST Date on the Release';
    public static final String DGF_Please_enter_CA_EST_Date_on_the_Release='Please enter CA EST Date on the Release';
    public static final String DGF_Please_enter_US_VOD_Start_Date_on_the_Release='Please enter US VOD Start Date on the Release';
    public static final String DGF_Please_enter_CA_VOD_Start_Date_on_the_Release='Please enter CA VOD Start Date on the Release';
    public static final String DGF_Valid_To_should_be_after_Valid_From_Date_For_Pricing_Record='Valid To should be after Valid From Date For Pricing Record';
    public static final String DGF_PPV_End_Date_should_be_after_PPV_Start_Date='PPV End Date should be after PPV Start Date';
    public static final String DGF_Push_VOD_End_Date_should_be_after_Push_VOD_Start_Date='Push VOD End Date should be after Push VOD Start Date';
    public static final String DGF_VOD_End_Date_should_be_after_VOD_Start_Date='VOD End Date should be after VOD Start Date';
    public static final string FREE_EPISODE_SYNC_MESSAGE ='Only one Product can be selected when syncing Free First Episode dates.';
    //Below for cloning DFOR-133
    public static final String PRICE_TPR_ACCOUNT = 'TPR Account'; 
    
    //Below added as part of DFOR-1223
    public static final String AFTER_INSERT = 'AFTER INSERT'; 
    public static final String AFTER_UPDATE = 'AFTER UPDATE'; 
    public static final String AFTER_DELETE = 'AFTER DELETE'; 
}