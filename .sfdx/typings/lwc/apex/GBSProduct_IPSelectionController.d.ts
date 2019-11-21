declare module "@salesforce/apex/GBSProduct_IPSelectionController.loadLMSDetails" {
  export default function loadLMSDetails(param: {LMSId: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.loadRelatedProductRights" {
  export default function loadRelatedProductRights(param: {alreadySelectedProducts: any, ContractId: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.loadRelatedIPRights" {
  export default function loadRelatedIPRights(param: {alreadySelectedProducts: any, PRGId: any, LMS: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.loadRelatedIPRightsUpdated" {
  export default function loadRelatedIPRightsUpdated(param: {alreadySelectedProducts: any, PRGId: any, LMS: any, alreadySelectedIP: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.loadSelectedProductRights" {
  export default function loadSelectedProductRights(param: {PRGId: any, LMS: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.loadSelectedIPRights" {
  export default function loadSelectedIPRights(param: {PRGId: any, LMSId: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.getProductRights" {
  export default function getProductRights(param: {selectedProducts: any, searchKey: any, PRGId: any, contractId: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.getIPRights" {
  export default function getIPRights(param: {selectedIPRights: any, searchKey: any, PRGId: any, contractId: any, selectedProductGroup: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.setLMSStatus" {
  export default function setLMSStatus(param: {LMSId: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.setLMSFlagonPRGUpdated" {
  export default function setLMSFlagonPRGUpdated(param: {PRGId: any, selectedProducts: any, selectedIPs: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.saveSelectedProductsUpdated" {
  export default function saveSelectedProductsUpdated(param: {selectedProducts: any, LMSId: any, PRGId: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.saveSelectedIPsUpdated" {
  export default function saveSelectedIPsUpdated(param: {selectedIPs: any, LMSId: any, PRGId: any}): Promise<any>;
}
declare module "@salesforce/apex/GBSProduct_IPSelectionController.saveUpdated" {
  export default function saveUpdated(param: {selectedProducts: any, selectedIPs: any, LMSId: any, PRGId: any, contactId: any}): Promise<any>;
}
