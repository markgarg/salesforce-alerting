public without sharing class SlackAlertInvoker implements AlertInvoker {
	public void invokeAlert(List<AlertMessage> alertMessages) {
		Config__mdt slackConfig = getSlackConfig();
		CalloutHelper.makeHTTPCallout(slackConfig.Alert_URL__c, 'POST',
			null, null);
	}

	public Config__mdt getSlackConfig() {
		return [SELECT Id, Alert_URL__c
					FROM Config__mdt LIMIT 1];
	}

	public class SlackAlertRequestBody {
		public String channel {get; set;}
		public String username {get; set;}
		public String text {get; set;}
		public String icon_emoji {get; set;}
	}
}