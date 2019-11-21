/**
 * CSVReader contains static methods used for reading a CSV file and returning
 * the contained values in a nested List of Strings.
 * 
 * used in example of batch csv processing found here: 
 * http://developer.financialforce.com/customizations/importing-large-csv-files-via-batch-apex/
 */
public class CSV_Reader {

    public static List<String> parseCSVLines(String contents,Boolean skipHeaders){
        Boolean showDebug = true;
        if(showDebug) system.debug('entered parseCSV');
		List<List<String>> allFields = new List<List<String>>();
	
		// replace instances where a double quote begins a field containing a comma
		// in this case you get a double quote followed by a doubled double quote
		// do this for beginning and end of a field
		//contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        //if(showDebug) system.debug('replaced double quotes');
		// now replace all remaining double quotes - we do this so that we can reconstruct
		// fields with commas inside assuming they begin and end with a double quote
		//contents = contents.replaceAll('""','DBLQT');
        //if(showDebug) system.debug('replaced double quotes again');
		// we are not attempting to handle fields with a newline inside of them
		// so, split on newline to get the spreadsheet rows
		List<String> lines = new List<String>();
		try {
            lines = safeSplit(contents, '\n');
            if(showDebug) system.debug('split lines');

			//lines = contents.split('\n');
			//if(lines.size() == 1) lines = contents.split('\r');
            if(lines.size() == 1) lines =  safeSplit(contents, '\r');
		} catch (System.ListException e) {
			System.debug('Limits exceeded?' + e.getMessage());
		}
        system.debug('sucessfully split the lines');
        return lines;

    }
    public static List<List<String>> parseCSVColumns(List<String> lines,Boolean skipHeaders){
        List<List<String>> allFields = new List<List<String>>();
        Integer num = 0;
		for(String line : lines) {
			//
			// check for blank CSV lines (only commas) // system.debug('line = ' + line);
			// 
			if(line == null) break;
			if(line.replaceAll(',','').trim().length() == 0) break;
			
			//List<String> fields = line.split(',');	
            List<String> fields = safeSplit(line, ',');	
            
			List<String> cleanFields = new List<String>();
			String compositeField;
			Boolean makeCompositeField = false;
			for(String field : fields) {
				//system.debug('field = ' + field);
				if (field.startsWith('"') && field.endsWith('"')) {
					cleanFields.add(field.replaceAll('DBLQT','"'));
				} else if (field.startsWith('"')) {
					makeCompositeField = true;
					compositeField = field;
				} else if (field.endsWith('"')) {
					compositeField += ',' + field;
					cleanFields.add(compositeField.replaceAll('DBLQT','"'));
					makeCompositeField = false;
				} else if (makeCompositeField) {
					compositeField +=  ',' + field;
				} else {
					cleanFields.add(field.replaceAll('DBLQT','"'));
				}
			}
			
			allFields.add(cleanFields);
		}
		if (skipHeaders) allFields.remove(0);
		return allFields;	
    }

	// default csv parsing option
	public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        Boolean showDebug = true;
        if(showDebug) system.debug('entered parseCSV');
		List<List<String>> allFields = new List<List<String>>();
	
		// replace instances where a double quote begins a field containing a comma
		// in this case you get a double quote followed by a doubled double quote
		// do this for beginning and end of a field
		//contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        //if(showDebug) system.debug('replaced double quotes');
		// now replace all remaining double quotes - we do this so that we can reconstruct
		// fields with commas inside assuming they begin and end with a double quote
		//contents = contents.replaceAll('""','DBLQT');
        //if(showDebug) system.debug('replaced double quotes again');
		// we are not attempting to handle fields with a newline inside of them
		// so, split on newline to get the spreadsheet rows
		List<String> lines = new List<String>();
		try {
            lines = safeSplit(contents, '\n');
            if(showDebug) system.debug('split lines');

			//lines = contents.split('\n');
			//if(lines.size() == 1) lines = contents.split('\r');
            if(lines.size() == 1) lines =  safeSplit(contents, '\r');
		} catch (System.ListException e) {
			System.debug('Limits exceeded?' + e.getMessage());
		}
        system.debug('sucessfully split the lines');
		Integer num = 0;
		for(String line : lines) {
			//system.debug('line = ' + line);
			// check for blank CSV lines (only commas)
			if (line.replaceAll(',','').trim().length() == 0) break;
			
			//List<String> fields = line.split(',');	
            List<String> fields = safeSplit(line, ',');	
            
			List<String> cleanFields = new List<String>();
			String compositeField;
			Boolean makeCompositeField = false;
			for(String field : fields) {
				//system.debug('field = ' + field);
				if (field.startsWith('"') && field.endsWith('"')) {
					cleanFields.add(field.replaceAll('DBLQT','"'));
				} else if (field.startsWith('"')) {
					makeCompositeField = true;
					compositeField = field;
				} else if (field.endsWith('"')) {
					compositeField += ',' + field;
					cleanFields.add(compositeField.replaceAll('DBLQT','"'));
					makeCompositeField = false;
				} else if (makeCompositeField) {
					compositeField +=  ',' + field;
				} else {
					cleanFields.add(field.replaceAll('DBLQT','"'));
				}
			}
			
			allFields.add(cleanFields);
		}
		if (skipHeaders) allFields.remove(0);
		return allFields;		
	}
	// complex csv parsing options 
	// 
	/*
	public static List<List<String>> readIETFRFC4180CSVFile(Blob file) {
        String fileString = file.toString();
        
        if (!fileString.endsWith(Parser.CRLF)) {
          fileString = fileString + Parser.CRLF;
        }
        
        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CSVValue csvValue = new CSVValue();
        
        Boolean eod = false;  // Whether end of CSV data is reached
        while (!eod) {
          //System.debug(fileString);
          
            csvValue = readIETFRFC4180CSVValue(fileString);
            
            rowValues.add(csvValue.value);
            
            if (csvValue.delimiter == Parser.CRLF) {
              fileValues.add(rowValues);
              
              //System.debug(rowValues);
              
              if (fileValues.size() > 0) {
                System.assertEquals(fileValues.get(0).size(),
                      rowValues.size());
              }
              
              rowValues = new List<String>();
            }
            
            if (csvValue.biteSize() == fileString.length()) {
              eod = true;
            }
            else {
              fileString = fileString.substring(csvValue.biteSize());
            }
        }
        
        return fileValues;
    }
    */
    
    /**
     * Returns the first String value read from a String representation of
     * data contained in an IETF RFC 4180-compliant CSV file.
     *
     * The data is assumed to be terminated with a CRLF.
     *
     * @param  data the textual CSV data in one long string
     * @return      the first CSV value read from <code>data</code>.
     *              null is returned if no value is discerned.
     */
    /*
    public static CSVValue readIETFRFC4180CSVValue(String data) {
        System.assert(data.endsWith(Parser.CRLF));
        
        CSVValue csvValue = new CSVValue();
        
        if (data.startsWith(Parser.DQUOTE)) {
          csvValue.enclosed = true;
          
            Integer searchIndex = 1;      // starting index to search
            Integer dquoteIndex = -1;     // index of DQUOTE
            Integer dquotesIndex = -1;    // index of DQUOTEDQUOTE
                            
            Boolean closerFound = false;
            
            while (!closerFound) {
                dquoteIndex = data.indexOf(Parser.DQUOTE, searchIndex);
                
                dquotesIndex = data.indexOf(Parser.DQUOTEDQUOTE,
                        searchIndex);
                
                System.assert(dquoteIndex != -1);
                
                if (dquoteIndex == dquotesIndex) {
                    searchIndex = dquotesIndex
                            + Parser.DQUOTEDQUOTE.length();
                }
                else {
                    closerFound = true;
                }
            }
            
            csvValue.value = data.substring(
                    Parser.DQUOTE.length(), dquoteIndex)
                            .replaceAll(Parser.DQUOTEDQUOTE, Parser.DQUOTE);
            
            Integer commaIndex = data.indexOf(Parser.COMMA, dquoteIndex);
            Integer crlfIndex = data.indexOf(Parser.CRLF, dquoteIndex);
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.delimiter = Parser.COMMA;
            }
            else {
                csvValue.delimiter = Parser.CRLF;
            }
        }
        else {
          csvValue.enclosed = false;
          
            Integer commaIndex = data.indexOf(Parser.COMMA);
            Integer crlfIndex = data.indexOf(Parser.CRLF);
            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.value = data.substring(0, commaIndex);
                csvValue.delimiter = Parser.COMMA;
            }
            else {
                csvValue.value = data.substring(0, crlfIndex);
                csvValue.delimiter = Parser.CRLF;
            }
        }
        
        //System.debug('Returning: ' + csvValue);
        
        return csvValue;
    }
    */
    /**
* Split a string of any size, while avoiding the dreaded 'Regex too complicated'
* error, which the String.split(String) method causes on some large inputs.
*
* Note that this method does not avoid other errors, such as those related to 
* excess heap size or CPU time.
*/
private static List<String> safeSplit(String inStr, String delim)
{
    //system.debug('using safe split');
    Integer regexFindLimit = 100;
    Integer regexFindCount = 0;
    
    List<String> output = new List<String>();
    
    Matcher m = Pattern.compile(delim).matcher(inStr);
    
    Integer lastEnd = 0;

    while(!m.hitEnd())
    {
        while(regexFindCount < regexFindLimit && !m.hitEnd())
        {
            if(m.find())
            {
                output.add(inStr.substring(lastEnd, m.start()));  
                lastEnd = m.end();
            }
            else
            {
                output.add(inStr.substring(lastEnd));
                lastEnd = inStr.length();
            }
            
            regexFindCount++;
        }

        // Note: Using region() to advance instead of substring() saves 
        // drastically on heap size. Nonetheless, we still must reset the 
        // (unmodified) input sequence to avoid a 'Regex too complicated' 
        // error.
        m.reset(inStr);        
        m.region(lastEnd, m.regionEnd());
        
        regexFindCount = 0;
    }
    
    return output;
}
/*
// Testing code
///////////////////

Integer numRepeats = 50000;
String bigInput = 'All work and no play makes Jack a dull boy.\r\n'.repeat(numRepeats);

// This generates a 'Regex too complicated' exception.
//
// List<String> a = bigInput.split('\r\n');

// This avoids a 'Regex too complicated' exception.
//
String[] a = safeSplit(bigInput, '\r\n');

System.assertEquals(numRepeats+1, a.size());
*/

    /**
     * CSVValue is a class structure containing information about a CSV
     * value that was read from a CSV file, including such information as
     * whether the value was encapsulated in double-quotes.
     */
    //private class CSVValue {
        /**
         * The field value that was read from the CSV file.
         */
//public String value;
        
        /**
         * Whether the value was surrounded by double-quotes.
         */
        //public Boolean enclosed;
        
        /**
         * The comma or CRLF delimiter that identified the end of the CSV value.
         */
        //public String delimiter;
        
        /**
         * Default constructor, setting all members to null.
         */
        //public CSVValue() {
        //    this(null, null, null);
        //}
        
        /**
         * Constructor.
         *
         * @param value     the field value
         * @param enclosed  whether the value was surrounded by double-quotes
         * @param delimiter the delimiter that identified the end
         *                  of the CSV value
         */
        //public CSVValue(String value, Boolean enclosed, String delimiter) {
        //    this.value = value;
        //    this.enclosed = enclosed;
        //    this.delimiter = delimiter;
        //}
        
        /**
         * Returns the number of characters to remove from the data
         * String which produced the CSVValue in order to reach the next
         * value in the data String.
         */
        //public Integer biteSize() {
        //  Integer biteSize = value
        //         .replaceAll(Parser.DQUOTE, Parser.DQUOTEDQUOTE).length()
        //                 + delimiter.length();
          
        //  if (enclosed) {
        //    biteSize += Parser.DQUOTE.length() * 2;
        //  }
          
          //System.debug('biteSize: ' + biteSize);
          
        //  return biteSize;
        //}
        
        /**
         * Returns whether a CSVValue has the same <code>value</code> and
         * <code>enclosed</code> as another CSVValue.
         */
        //public Boolean equals(CSVValue compCSVValue) {
        //    return this.value.equals(compCSVValue.value)
        //            && this.enclosed == compCSVValue.enclosed
        //                    && this.delimiter == compCSVValue.delimiter;
        //}
        
        /**
         * Asserts that two <code>CSVValue</code> instances have the same
         * <code>value</code> and <code>enclosed</code>.
         */
       // public void assertEquals(CSVValue compCSVValue) {
       //     System.assertEquals(value, compCSVValue.value);
       //     System.assertEquals(enclosed, compCSVValue.enclosed);
       //     System.assertEquals(delimiter, compCSVValue.delimiter);
       // }
    //}
}