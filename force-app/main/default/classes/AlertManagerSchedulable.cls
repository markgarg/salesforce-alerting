global class AlertManagerSchedulable implements BaseScheduler.ISchedule {
	global void execute(SchedulableContext sc) {
		List<Config__mdt> monitoringConfig = [
			SELECT Id, MasterLabel, Warning__c, Severe__c
			FROM Config__mdt
			LIMIT 1000
		];
		Alert limitsAlert = new LimitsAlert(monitoringConfig);
		if (limitsAlert.shouldAlert()) {
			AlertInvoker slack = new SlackAlertInvoker();
			slack.invokeAlert(limitsAlert.getMessages());
		}
	}
}
