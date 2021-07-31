public without sharing class SlackAlertInvoker implements AlertInvoker {
	public static final String TEMPLATE = '```Severity: {0}\n{1}```';

	public void invokeAlert(List<AlertMessage> alertMessages) {
		String slackUrl = System.Label.SLACK_URL;
		SlackAlertRequestBody reqBody = buildRequestBody(alertMessages);

		CalloutHelper.makeHTTPCallout(
			slackUrl,
			'POST',
			null,
			JSON.serialize(reqBody)
		);
	}

	private SlackAlertRequestBody buildRequestBody(
		final List<AlertMessage> alertMessages
	) {
		SlackAlertRequestBody reqBody = new SlackAlertRequestBody();
		reqBody.channel = System.Label.SLACK_CHANNEL_NAME;
		reqBody.username = System.Label.SLACK_USERNAME;
		reqBody.icon_emoji = System.Label.SLACK_EMOJI_ICON;

		List<String> msgBody = new List<String>();
		for (AlertMessage am : alertMessages) {
			msgBody.add(
				String.format(
					TEMPLATE,
					new List<String>{ am.level.name(), am.message }
				)
			);
		}
		String fullMessage = String.format(
			'Alert: {0}',
			new List<String>{ String.join(msgBody, '\n') }
		);
		reqBody.text = fullMessage;

		return reqBody;
	}

	public class SlackAlertRequestBody {
		public String channel { get; set; }
		public String username { get; set; }
		public String text { get; set; }
		public String icon_emoji { get; set; }
	}

	public class AlertException extends Exception {
	}
}
