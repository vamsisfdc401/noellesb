@isTest
public class SendJSONString_MockTest implements HttpCalloutMock {
    	public HTTPResponse respond(HTTPRequest req) {
          		String jsString='{"Message":"test","error":"read time out","Status":"Success","SysGen":"" ,"External Request ID":" SSS" }';
                HTTPResponse res = new HTTPResponse();            	
                res.setHeader('Content-Type', 'application/json');
                res.setBody(jsString);
                res.setStatusCode(200);
            	
                return res;            
            
        }
}