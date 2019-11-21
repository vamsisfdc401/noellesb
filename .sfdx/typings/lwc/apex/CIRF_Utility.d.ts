declare module "@salesforce/apex/CIRF_Utility.ReadCSV" {
  export default function ReadCSV(param: {uploadedFile: any}): Promise<any>;
}
declare module "@salesforce/apex/CIRF_Utility.ReviseCIRF" {
  export default function ReviseCIRF(param: {header: any, revision: any}): Promise<any>;
}
