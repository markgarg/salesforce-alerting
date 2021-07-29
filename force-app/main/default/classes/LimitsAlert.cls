public without sharing class LimitsAlert implements Alert {
	private LimitsAlertHelper helper;

	public LimitsAlert(List<Config__mdt> monitoringConfig) {
		helper = new LimitsAlertHelper(monitoringConfig);
	}

	public Boolean shouldAlert() {
		return helper.areThereAnyAlerts();
	}

	public List<AlertMessage> getMessages() {
		return helper.alerts;
	}	
}
