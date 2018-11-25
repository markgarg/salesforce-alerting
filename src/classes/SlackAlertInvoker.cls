public without sharing class SlackAlertInvoker implements AlertInvoker {
	public void invokeAlert(List<AlertMessage> alertMessages) {
		Config__mdt slackConfig = getSlackConfig();
		SlackAlertRequestBody reqBody = buildRequestBody(slackConfig, alertMessages);

		CalloutHelper.makeHTTPCallout(slackConfig.Alert_URL__c, 'POST',
		                              null, JSON.serialize(reqBody));
	}

	private Config__mdt getSlackConfig() {
		return [SELECT Id, Alert_URL__c, Channel_Name__c, Emoji_Icon__c,
			        	Username__c
			        FROM Config__mdt WHERE DeveloperName = 'Slack' LIMIT 1];
	}

	private SlackAlertRequestBody buildRequestBody(final Config__mdt slackConfig,
			final List<AlertMessage> alertMessages) {
		SlackAlertRequestBody reqBody = new SlackAlertRequestBody();
		reqBody.channel = slackConfig.Channel_Name__c;
		reqBody.username = slackConfig.Username__c;
		reqBody.icon_emoji = slackConfig.Emoji_Icon__c;

		List<String> msgBody = new List<String>();
		final String template = '```Severity: {0}\n{1}```';
		for(AlertMessage am : alertMessages) {
			msgBody.add(String.format(template, 
				new List<String>{am.level.name(), am.message}));
		}
		reqBody.text = String.join(msgBody, '\n');

		return reqBody;
	}

	public class SlackAlertRequestBody {
		public String channel {get; set;}
		public String username {get; set;}
		public String text {get; set;}
		public String icon_emoji {get; set;}
	}
}