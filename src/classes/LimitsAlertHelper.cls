public without sharing class LimitsAlertHelper {
	public static final String API_VERSION = 'v44.0';

	public static List<AlertMessage> getAlerts() {
		Map<String, Object> limitsMap = getLimits();
		return getAlertMessagesFor(limitsMap);
	}

	private static Map<String, Object> getLimits() {
		final String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
		final String path = String.format('/services/data/{0}/limits',
		                                  new List<String> {API_VERSION});
		final String url = baseURL + path;

		final String response = CalloutHelper.makeHTTPCallout(url, 'GET', null, null);
		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

		return responseMap;
	}

	private static List<AlertMessage> getAlertMessagesFor(Map<String, Object> limitsMap) {
		List<AlertMessage> alertMessages = new List<AlertMessage>();
		for(String key : limitsMap.keyset()) {
			Map<String, Object> limitResults = (Map<String, Object>) limitsMap.get(key);
			final Integer max = (Integer) limitResults.get('Max');
			final Integer remaining = (Integer) limitResults.get('Remaining');
			final String msg = buildMessage(key, max, remaining);
			if(remaining > max || (remaining < 0.1 * max)) {
				// SEVERE
				alertMessages.add(new AlertMessage(AlertMessage.Severity.HIGH, msg));
			} else if(remaining < 0.3 * max) {
				// WARNING
				alertMessages.add(new AlertMessage(AlertMessage.Severity.MEDIUM, msg));
			}
		}
		return alertMessages;
	}

	private static String buildMessage(String key, Integer max, Integer remaining) {
		final String msg = '"' + key + '": {'
		                   + '\n\t"Max": ' + max + ','
		                   + '\n\t"Remaining": ' + remaining
		                   + '\n}';
		return msg;
	}
}