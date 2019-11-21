@IsTest
public class RST_MultiRequestMock implements HttpCalloutMock {
	Map<String, HttpCalloutMock> requests;

	public RST_MultiRequestMock(Map<String, HttpCalloutMock> requests) {
		this.requests = requests;
	}

	public HTTPResponse respond(HTTPRequest req) {
		HttpCalloutMock mock = requests.get(req.getEndpoint());
		return mock.respond(req);
	}

	public void addRequestMock(String url, HttpCalloutMock mock) {
		requests.put(url, mock);
	}
}