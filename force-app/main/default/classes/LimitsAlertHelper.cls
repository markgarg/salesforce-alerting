public without sharing class LimitsAlertHelper {
	public static final String LIMIT_EXCEPTION_BASE_MSG = 'Something wrong with Limits API:';
	public static final String KEY_GLOBAL_CONFIG = 'All';

	public List<AlertMessage> alerts {get; private set;}
	private Map<String, Config__mdt> monitoringConfigMap;
	private ILimitsService limitsService;

	public LimitsAlertHelper(List<Config__mdt> monitoringConfig, ILimitsService limitsService) {
		this.limitsService = limitsService;
		this.monitoringConfigMap = new Map<String, Config__mdt>();
		if(monitoringConfig != null) {
			for(Config__mdt config : monitoringConfig) {
				this.monitoringConfigMap.put(config.MasterLabel, config);
			}
		}
		this.checkForAlerts();
	}

	public Boolean areThereAnyAlerts() {
		return alerts != null && !alerts.isEmpty();
	}

	public void checkForAlerts() {
		try {
			List<LimitItem> allLimits = this.limitsService.getLimits();
			List<LimitItemWithSeverity> breachedLimits = evaluateLimitBreach(allLimits);
			this.alerts = getAlertMessagesFor(breachedLimits);
		} catch(Exception ex) {
			AlertMessage alert = new AlertMessage(AlertMessage.Severity.HIGH,
			        LIMIT_EXCEPTION_BASE_MSG + ex.getMessage());
			this.alerts = new List<AlertMessage>();
			this.alerts.add(alert);
		}
	}

	private List<LimitItemWithSeverity> evaluateLimitBreach(List<LimitItem> allLimits) {
		List<LimitItemWithSeverity> limitItemsWithSeverity = new List<LimitItemWithSeverity>();
		Config__mdt globalConfig = monitoringConfigMap.get(KEY_GLOBAL_CONFIG);
		for(LimitItem li : allLimits) {
			if (li.max == 0) {
				// the limit is not configured for the Org, so skip it
				continue;
			}
			
			Decimal warningPct = 1 - globalConfig.Warning__c;
			Decimal severePct = 1 - globalConfig.Severe__c;
			if(monitoringConfigMap.containsKey(li.key)) {
				warningPct = 1 - monitoringConfigMap.get(li.key).Warning__c;
				severePct = 1 - monitoringConfigMap.get(li.key).Severe__c;
			}

			LimitItemWithSeverity liWithSeverity = new LimitItemWithSeverity(li);
			if(li.remaining > li.max || (li.remaining <= severePct * li.max)) {
				// SEVERE
				liWithSeverity.severityLevel = AlertMessage.Severity.HIGH;
				limitItemsWithSeverity.add(liWithSeverity);
			} else if(li.remaining <= warningPct * li.max) {
				// WARNING
				liWithSeverity.severityLevel = AlertMessage.Severity.MEDIUM;
				limitItemsWithSeverity.add(liWithSeverity);
			}
		}
		return limitItemsWithSeverity;
	}

	private List<AlertMessage> getAlertMessagesFor(List<LimitItemWithSeverity> limitItemsWithSeverity) {
		List<AlertMessage> alertMessages = new List<AlertMessage>();
		for(LimitItemWithSeverity liWithSeverity : limitItemsWithSeverity) {
			final String msg = buildMessage(liWithSeverity.limitItem.key, liWithSeverity.limitItem.max, liWithSeverity.limitItem.remaining);
			alertMessages.add(new AlertMessage(liWithSeverity.severityLevel, msg));
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

	public class LimitItemWithSeverity {
		public LimitItem limitItem;
		public AlertMessage.Severity severityLevel;
		
		public LimitItemWithSeverity(LimitItem limitItem) {
			this.limitItem = limitItem;
		}
	}
}
