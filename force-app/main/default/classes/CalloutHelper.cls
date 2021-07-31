public class CalloutHelper {
	public static String makeHTTPCallout(
		final String url,
		final String method,
		final Map<String, String> headers,
		final String body
	) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod(method);

		if (headers != null) {
			for (String key : headers.keyset()) {
				req.setHeader(key, headers.get(key));
			}
		}
		if (String.isNotBlank(body))
			req.setBody(body);

		HttpResponse res = h.send(req);
		if (res.getStatusCode() / 100 != 2) {
			throw new CalloutHelperException(
				'Callout failed - ' + res.getBody()
			);
		}
		return res.getBody();
	}

	public class CalloutHelperException extends Exception {
	}
}
