public without sharing class LimitsAlertHelper {
	public static final String API_VERSION = 'v44.0';
	public static final String URL_PATH = 'callout:{0}/services/data/{1}/limits';
	public static final String NAMED_CREDENTIAL = 'InternalRestAPI';
	public static final String LIMIT_EXCEPTION_BASE_MSG = 'Something wrong with Limits API:';
	public static final String KEY_GLOBAL_CONFIG = 'All';

	public List<AlertMessage> alerts {get; private set;}
	private Map<String, Config__mdt> monitoringConfigMap;

	public LimitsAlertHelper(List<Config__mdt> monitoringConfig) {
		monitoringConfigMap = new Map<String, Config__mdt>();
		if(monitoringConfig != null) {
			for(Config__mdt config : monitoringConfig) {
				monitoringConfigMap.put(config.MasterLabel, config);
			}
		}
		this.checkForAlerts();
	}

	public Boolean areThereAnyAlerts() {
		return alerts != null && !alerts.isEmpty();
	}

	public void checkForAlerts() {
		try {
			Map<String, Object> limitsMap = getLimits();
			List<LimitItem> breachedLimits = evaluateLimitBreach(limitsMap);
			this.alerts = getAlertMessagesFor(breachedLimits);
		} catch(Exception ex) {
			AlertMessage alert = new AlertMessage(AlertMessage.Severity.HIGH,
			        LIMIT_EXCEPTION_BASE_MSG + ex.getMessage());
			this.alerts = new List<AlertMessage>();
			this.alerts.add(alert);
		}
	}

	private Map<String, Object> getLimits() {
		final String path = String.format(URL_PATH,
		                                  new List<String> {NAMED_CREDENTIAL, API_VERSION});
		final String response = CalloutHelper.makeHTTPCallout(path, 'GET', null, null);
		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

		return responseMap;
	}

	private List<LimitItem> evaluateLimitBreach(Map<String, Object> limitsMap) {
		List<LimitItem> limitItems = new List<LimitItem>();
		Config__mdt globalConfig = monitoringConfigMap.get(KEY_GLOBAL_CONFIG);
		for(String key : limitsMap.keyset()) {
			Map<String, Object> limitResults = (Map<String, Object>) limitsMap.get(key);
			final Integer max = (Integer) limitResults.get('Max');
			final Integer remaining = (Integer) limitResults.get('Remaining');

			if (max == 0) {
				// the limit is not configured for the Org, so skip it
				continue;
			}
			
			Decimal warningPct = 1 - globalConfig.Warning__c;
			Decimal severePct = 1 - globalConfig.Severe__c;
			if(monitoringConfigMap.containsKey(key)) {
				warningPct = 1 - monitoringConfigMap.get(key).Warning__c;
				severePct = 1 - monitoringConfigMap.get(key).Severe__c;
			}

			LimitItem li = new LimitItem();
			li.key = key;
			li.max = max;
			li.remaining = remaining;
			if(remaining > max || (remaining <= severePct * max)) {
				// SEVERE
				li.severityLevel = AlertMessage.Severity.HIGH;
				limitItems.add(li);
			} else if(remaining <= warningPct * max) {
				// WARNING
				li.severityLevel = AlertMessage.Severity.MEDIUM;
				limitItems.add(li);
			}
		}
		return limitItems;
	}

	private List<AlertMessage> getAlertMessagesFor(List<LimitItem> limitItems) {
		List<AlertMessage> alertMessages = new List<AlertMessage>();
		for(LimitItem li : limitItems) {
			final String msg = buildMessage(li.key, li.max, li.remaining);
			alertMessages.add(new AlertMessage(li.severityLevel, msg));
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

	public class LimitItem {
		public String key {get; set;}
		public AlertMessage.Severity severityLevel {get; set;}
		public Integer max {get; set;}
		public Integer remaining {get; set;}
	}
}
