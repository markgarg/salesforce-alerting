public without sharing class LimitsAlert implements Alert {
	private LimitsAlertHelper helper;

	public LimitsAlert(List<Config__mdt> monitoringConfig, ILimitsService limitsService) {
		helper = new LimitsAlertHelper(monitoringConfig, limitsService);
	}

	public Boolean shouldAlert() {
		return helper.areThereAnyAlerts();
	}

	public List<AlertMessage> getMessages() {
		return helper.alerts;
	}	
}

