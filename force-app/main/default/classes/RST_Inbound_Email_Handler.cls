/*
 * Author: Kyle Novelli
 * Date: 12/06/2018
 * Company: Slalom
 * Description: Class used to handle Inbound Email with CSV attachment.
 * 				CSV attachment will be uploaded and parsed and used for the
 * 				batch process to create Title and PlayWeek records.
 * 
 */ 
global class RST_Inbound_Email_Handler implements Messaging.InboundEmailHandler {
	
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        List<Messaging.InboundEmail.binaryAttachment> binAttachments = email.binaryAttachments;
        String csvbody = '';
        String resultMessage = '';
        Boolean resultSuccess = false;
        
        try {
            //Proccess Binary Attachment. Make sure we only have one attachment and the file type is CSV
            if(binAttachments != NULL) {
                //We only want to process a single CSV attachment
                if (binAttachments.size() == 1) {
                    for (Messaging.InboundEmail.binaryAttachment ba : binAttachments) {
                        //Check that binary attachment ends with .csv
                        if(ba.filename.endsWith('.csv')) {
                            csvbody = ba.body.toString();
                            System.debug('CSV body as string: ' + csvbody);
                            
                            //Create Forecast Upload Record
                        	RST_Forecast_Upload__c forecastUpload = new RST_Forecast_Upload__c();
                            insert forecastUpload;

                            ContentVersion cv = new ContentVersion();
                            //cv.ContentLocation = 'E'; // Specify 'E' for external files and 'S' for files in Salesforce
                            cv.PathOnClient = ba.filename;
                            cv.Title = 'ba.filename - ' + String.valueOf(System.Today());
                            cv.VersionData = ba.body;
                            System.debug('Content Version: ' + cv);
                            insert cv;
                            
                            //Get the content document id from cv
                            Id conDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                            
							ContentDocumentLink cdl = new ContentDocumentLink();
							cdl.ContentDocumentId = conDocumentId;
							cdl.LinkedEntityId = forecastUpload.id;
							cdl.ShareType = 'I';   
                            //cdl.Visibility = 'InternalUsers';
                            insert cdl;
                            
                            //Pass ForeCast Upload to be loaded/parsed which will upsert title and play week data.
                            //try {
                                RST_Controller.ParseResults pr_ProcessCSVLines = RST_Controller.processCSVLines(forecastUpload.id);
                                if (pr_ProcessCSVLines.result == 'success') {
                                    //try {
                                        RST_Controller.ParseResults pr_ProcessRawCSV_Batch = RST_Controller.processRawCSV_Batch(forecastUpload.id);
                                        if (pr_ProcessRawCSV_Batch.result == 'success') {
                                            resultSuccess = true;
                                            resultMessage = 'Successfully processed attached CSV file from Inbound Email.';
                                            resultMessage += '\r\nYour file: ' + ba.filename + ' has been processed for the Release Scheduling Tool.';
                                        }
                                        else {
                                            resultSuccess = false;
                                            resultMessage = 'Failed to process Raw CSV from Batch Process. Issues: ';
                                            for (String s : pr_ProcessRawCSV_Batch.issues) {
                                                resultMessage += s + '\r\n';
                                            }
                                        }
                                    //}
                                    //catch (Exception e) {
                                    //    result.success = false;
                                	//	result.message = 'Failed to process Raw CSV from Batch Process: Error Message: ' + e.getMessage();
                                    //}
                                }
                                else {
                                    resultSuccess = false;
                                    resultMessage = 'Failed to Process CSV Lines for attachment. Issues: ';
                                    for (String s : pr_ProcessCSVLines.issues) {
                                                resultMessage += s + '\r\n';
                                            }
                                }
                            //}
                            //catch (Exception e) {
                            //    result.success = false;
                            //    result.message = 'Failed to Process CSV Lines: Error Message: ' + e.getMessage();
                            //}
                            
                        }
                        else {
                            //file type is not CSV
                            resultSuccess = false;
                            resultMessage = 'Inbound Email attached file is not of type CSV. Please ensure the file attached to your Inbound Email is of type CSV.';
                        }
                    }
            	}
                else {
                    //More than one attachment was found
                    resultSuccess = false;
                    resultMessage = 'Inbound Email contains more than one file. Please ensure there is only one file attached to your Inbound Email.';
                }
            }
            else {
                //No attachments found
                resultSuccess = false;
                resultMessage = 'Inbound Email did not contain any CSV attachment. Please ensure there is a CSV attached to your Inbound Email.';
            }
            result.success = resultSuccess;
            result.message = resultMessage;
        }
        catch (Exception e) {
            //Any other type of uncaught error
            result.success = false;
            result.message = 'Failed to Process Inbound Email. Error message: ' + e.getMessage();
        }
          return result;
      }
}