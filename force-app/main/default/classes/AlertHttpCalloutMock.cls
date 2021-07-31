@isTest
public class AlertHttpCalloutMock implements HttpCalloutMock {
	protected Integer code;
	protected String status;
	protected String body;
	protected Map<String, String> responseHeaders;
	private String urlToCheck;
	private List<String> bodyContainsToCheck;

	public AlertHttpCalloutMock(
		Integer code,
		String status,
		String body,
		Map<String, String> responseHeaders
	) {
		this.code = code;
		this.status = status;
		this.body = body;
		this.responseHeaders = responseHeaders;
	}

	public AlertHttpCalloutMock assertURL(final String url) {
		this.urlToCheck = url;
		return this;
	}

	public AlertHttpCalloutMock assertBodyContains(
		final List<String> bodyToCheck
	) {
		this.bodyContainsToCheck = bodyToCheck;
		return this;
	}

	public HTTPResponse respond(HTTPRequest req) {
		if (String.isNotBlank(urlToCheck)) {
			System.assert(req.getEndpoint().contains(urlToCheck));
		}

		if (bodyContainsToCheck != null) {
			final String body = req.getBody();
			for (String toCheck : bodyContainsToCheck) {
				System.assert(body.contains(toCheck));
			}
		}

		HttpResponse res = new HttpResponse();
		for (String key : this.responseHeaders.keySet()) {
			res.setHeader(key, this.responseHeaders.get(key));
		}
		res.setBody(this.body);
		res.setStatusCode(this.code);
		res.setStatus(this.status);
		return res;
	}
}
