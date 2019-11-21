declare module "@salesforce/apex/DGF_PackageComponentController.fetchBonusRecords" {
  export default function fetchBonusRecords(param: {recordID: any}): Promise<any>;
}
declare module "@salesforce/apex/DGF_PackageComponentController.getBonusDetails" {
  export default function getBonusDetails(param: {releaseId: any, pkgName: any}): Promise<any>;
}
declare module "@salesforce/apex/DGF_PackageComponentController.getRecordTypeId" {
  export default function getRecordTypeId(): Promise<any>;
}
declare module "@salesforce/apex/DGF_PackageComponentController.getReleaseName" {
  export default function getReleaseName(param: {releaseId: any}): Promise<any>;
}
declare module "@salesforce/apex/DGF_PackageComponentController.createBonusRecord" {
  export default function createBonusRecord(param: {recordID: any, packageSelected: any, pkgList: any}): Promise<any>;
}
declare module "@salesforce/apex/DGF_PackageComponentController.getProfileDetails" {
  export default function getProfileDetails(): Promise<any>;
}
declare module "@salesforce/apex/DGF_PackageComponentController.removePackage" {
  export default function removePackage(param: {recordID: any, packageRemoved: any, pkgList: any}): Promise<any>;
}
