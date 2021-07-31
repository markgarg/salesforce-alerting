@isTest
private class SlackAlertInvokerTest {
	@isTest
	static void itShouldSendMessagesToSlack() {
		// Given
		AlertMessage am1 = new AlertMessage(
			AlertMessage.Severity.HIGH,
			'Test 1'
		);
		AlertMessage am2 = new AlertMessage(
			AlertMessage.Severity.MEDIUM,
			'Test 2'
		);

		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'text/html');

		List<String> bodyContainsAsserts = new List<String>();
		bodyContainsAsserts.add('Alert:');
		bodyContainsAsserts.add('"channel":"#test-channel"');
		bodyContainsAsserts.add('"username":"salesforcebot"');
		bodyContainsAsserts.add('"icon_emoji":":salesforce:"');
		bodyContainsAsserts.add('Test 1');
		bodyContainsAsserts.add('Test 2');

		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(
				200,
				'OK',
				'ok',
				responseHeaders
			)
			.assertURL('https://hooks.slack.com/services') // Then
			.assertBodyContains(bodyContainsAsserts); // Then

		// When
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, mock);
		SlackAlertInvoker invoker = new SlackAlertInvoker();
		invoker.invokeAlert(new List<AlertMessage>{ am1, am2 });
		Test.stopTest();
	}
}
