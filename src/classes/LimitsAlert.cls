public without sharing class LimitsAlert implements Alert {
	private List<AlertMessage> alertMessages;
	public static final String LIMIT_EXCEPTION_BASE_MSG = 'Something wrong with Limits API:';

	public Boolean shouldAlert() {
		try {
			alertMessages = LimitsAlertHelper.getAlerts();
		} catch(Exception ex) {
			AlertMessage alert = new AlertMessage(AlertMessage.Severity.HIGH,
				 LIMIT_EXCEPTION_BASE_MSG + ex.getMessage());
			alertMessages = new List<AlertMessage>();
			alertMessages.add(alert);
		}
		return !alertMessages.isEmpty();
	}

	public String getMessage() {
		if(alertMessages == null)
			return null;

		String message = '';
		for(AlertMessage am : alertMessages) {
			message += am;
			message += '\n';
		}

		return message;
	}	
}