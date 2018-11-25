global class AlertManagerSchedulable implements BaseScheduler.ISchedule {
	global void execute(SchedulableContext sc) {
		Alert limitsAlert = new LimitsAlert();
		if(limitsAlert.shouldAlert()){
			AlertInvoker slack = new SlackAlertInvoker();
			slack.invokeAlert(limitsAlert.getMessages());
		}
	}
}