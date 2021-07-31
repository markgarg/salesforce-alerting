@SuppressWarnings('PMD.ExcessiveParameterList')
@isTest
private class LimitsAlertTest {
	@isTest
	static void itShouldNotAlertWhenThereIsNoProblem() {
		// Given
		final List<LimitItem> limitsStubbedResults = getLimitItems(15000, 5000);

		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		LimitsServiceStub stub = new LimitsServiceStub(limitsStubbedResults);

		// When
		Test.startTest();
		LimitsAlert alert = new LimitsAlert(configList, stub);
		Boolean shouldAlert = alert.shouldAlert();
		Test.stopTest();

		// Then
		System.assert(
			shouldAlert == false,
			'should not alert when there is no problem'
		);
	}

	@isTest
	static void itShouldAlertWithMediumWhenThereIsASmallProblem() {
		// Given
		final List<LimitItem> limitsStubbedResults = getLimitItems(3000, 5000);

		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		LimitsServiceStub stub = new LimitsServiceStub(limitsStubbedResults);

		// When
		Test.startTest();
		LimitsAlert alert = new LimitsAlert(configList, stub);
		Boolean shouldAlert = alert.shouldAlert();
		List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(
			messages.size() == 1,
			'should contain only 1 message in the alert'
		);
		System.assert(
			messages.get(0).level == AlertMessage.Severity.MEDIUM,
			'alert level should match'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('DailyApiRequests'),
			'alert should be for api requests'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('"Max": 15000'),
			'max value should be 15000'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('"Remaining": 3000'),
			'remaining should be 3000'
		);
	}

	@isTest
	static void itShouldAlertWithHighWhenThereIsABigProblem() {
		// Given
		final List<LimitItem> limitsStubbedResults = getLimitItems(15000, 20);

		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		LimitsServiceStub stub = new LimitsServiceStub(limitsStubbedResults);

		// When
		Test.startTest();
		LimitsAlert alert = new LimitsAlert(configList, stub);
		Boolean shouldAlert = alert.shouldAlert();
		List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(
			messages.size() == 1,
			'should contain only 1 message in the alert'
		);
		System.assert(
			messages.get(0).level == AlertMessage.Severity.HIGH,
			'alert level should match'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('DailyBulkApiRequests'),
			'alert should be for bulk api requests'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('"Max": 5000'),
			'max value should be 5000'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('"Remaining": 20'),
			'remaining should be 20'
		);
	}

	@isTest
	static void itShouldAlertWithHighWhenThereAreBigProblems() {
		// Given
		final List<LimitItem> limitsStubbedResults = getLimitItems(200, 20);

		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		LimitsServiceStub stub = new LimitsServiceStub(limitsStubbedResults);

		// When
		Test.startTest();
		LimitsAlert alert = new LimitsAlert(configList, stub);
		Boolean shouldAlert = alert.shouldAlert();
		List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(
			messages.size() == 2,
			'should contain 2 messages in the alert'
		);
		Boolean hasApi = false;
		Boolean hasBulkApi = false;
		for (AlertMessage am : messages) {
			if (am.message.containsIgnoreCase('DailyApiRequests')) {
				hasApi = true;
				System.assert(
					am.level == AlertMessage.Severity.HIGH,
					'alert level should match'
				);
				System.assert(
					am.message.containsIgnoreCase('"Max": 15000'),
					'api max value should be 15000'
				);
				System.assert(
					am.message.containsIgnoreCase('"Remaining": 200'),
					'api remaining value should be 200'
				);
			} else if (am.message.containsIgnoreCase('DailyBulkApiRequests')) {
				hasBulkApi = true;
				System.assert(
					am.level == AlertMessage.Severity.HIGH,
					'alert level should match'
				);
				System.assert(
					am.message.containsIgnoreCase('"Max": 5000'),
					'bulk api max value should be 5000'
				);
				System.assert(
					am.message.containsIgnoreCase('"Remaining": 20'),
					'bulk api remaining value should be 20'
				);
			}
		}
		System.assert(
			hasApi && hasBulkApi,
			'both api and bulk api should be present'
		);
	}

	@isTest
	static void itShouldUseCustomAlerts() {
		// Given
		final List<LimitItem> limitsStubbedResults = getLimitItems(15000, 2500);

		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		Config__mdt dailyBulkAPIRequests = new Config__mdt();
		dailyBulkAPIRequests.DeveloperName = 'DailyBulkApiRequests';
		dailyBulkApiRequests.MasterLabel = 'DailyBulkApiRequests';
		dailyBulkAPIRequests.Warning__c = 0.2;
		dailyBulkAPIRequests.Severe__c = 0.9;
		configList.add(dailyBulkAPIRequests);

		LimitsServiceStub stub = new LimitsServiceStub(limitsStubbedResults);

		// When
		Test.startTest();
		LimitsAlert alert = new LimitsAlert(configList, stub);
		Boolean shouldAlert = alert.shouldAlert();
		List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(
			messages.size() == 1,
			'should contain only 1 message in the alert'
		);
		System.assert(
			messages.get(0).level == AlertMessage.Severity.MEDIUM,
			'alert level should match'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('DailyBulkApiRequests'),
			'alert should be for bulk api requests'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('"Max": 5000'),
			'max value should be 5000'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('"Remaining": 2500'),
			'remaining should be 2500'
		);
	}

	@isTest
	static void itShouldUseCustomAlertsWith100PctUsage() {
		// Given
		final List<LimitItem> limitsStubbedResults = getLimitItems(15000, 0);

		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		Config__mdt dailyBulkAPIRequests = new Config__mdt();
		dailyBulkAPIRequests.DeveloperName = 'DailyBulkApiRequests';
		dailyBulkApiRequests.MasterLabel = 'DailyBulkApiRequests';
		dailyBulkAPIRequests.Warning__c = 1;
		dailyBulkAPIRequests.Severe__c = 1.2;
		configList.add(dailyBulkAPIRequests);

		LimitsServiceStub stub = new LimitsServiceStub(limitsStubbedResults);

		// When
		Test.startTest();
		LimitsAlert alert = new LimitsAlert(configList, stub);
		Boolean shouldAlert = alert.shouldAlert();
		List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(
			messages.size() == 1,
			'should contain only 1 message in the alert'
		);
		System.assert(
			messages.get(0).level == AlertMessage.Severity.MEDIUM,
			'alert level should match'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('DailyBulkApiRequests'),
			'alert should be for bulk api requests'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('"Max": 5000'),
			'max value should be 5000'
		);
		System.assert(
			messages.get(0).message.containsIgnoreCase('"Remaining": 0'),
			'remaining should be 0'
		);
	}

	@isTest
	static void itShouldUseCustomAlertsWithMoreThan100PctUsage() {
		// Given
		final List<LimitItem> limitsStubbedResults = getLimitItems(15000, -20);

		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		Config__mdt dailyBulkAPIRequests = new Config__mdt();
		dailyBulkAPIRequests.DeveloperName = 'DailyBulkApiRequests';
		dailyBulkApiRequests.MasterLabel = 'DailyBulkApiRequests';
		dailyBulkAPIRequests.Warning__c = 1.5;
		dailyBulkAPIRequests.Severe__c = 2.0;
		configList.add(dailyBulkAPIRequests);

		LimitsServiceStub stub = new LimitsServiceStub(limitsStubbedResults);

		// When
		Test.startTest();
		LimitsAlert alert = new LimitsAlert(configList, stub);
		Boolean shouldAlert = alert.shouldAlert();
		List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(
			shouldAlert == false,
			'should not raise an alert when limits have not exceeded'
		);
		System.assert(messages.isEmpty(), 'no messages should be present');
	}

	@isTest
	static void itShouldNotAlertWhenLimitIsNotConfiguredForOrg() {
		// When limit is not configured for org, the max value is 0
		// Given
		final List<LimitItem> limitsStubbedResults = getLimitItems(0, 0, 0, 0);

		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		LimitsServiceStub stub = new LimitsServiceStub(limitsStubbedResults);

		// When
		Test.startTest();
		LimitsAlert alert = new LimitsAlert(configList, stub);
		Boolean shouldAlert = alert.shouldAlert();
		List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(
			shouldAlert == false,
			'should not alert because limit is not configured for org'
		);
		System.assert(
			messages.isEmpty(),
			'no alert messages should be generated'
		);
	}

	static List<LimitItem> getLimitItems(
		Integer remainingAPICount,
		Integer remainingBulkAPICount
	) {
		return getLimitItems(
			remainingAPICount,
			15000,
			remainingBulkAPICount,
			5000
		);
	}

	static List<LimitItem> getLimitItems(
		Integer remainingAPICount,
		Integer maxAPICount,
		Integer remainingBulkAPICount,
		Integer maxBulkAPICount
	) {
		List<LimitItem> limits = new List<LimitItem>();
		limits.add(
			new LimitItem('ConcurrentAsyncGetReportInstances', 200, 200)
		);
		limits.add(new LimitItem('ConcurrentSyncReportRuns', 20, 20));
		limits.add(
			new LimitItem('DailyApiRequests', maxAPICount, remainingAPICount)
		);
		limits.add(new LimitItem('DailyAsyncApexExecutions', 25000, 25000));
		limits.add(
			new LimitItem(
				'DailyBulkApiRequests',
				maxBulkAPICount,
				remainingBulkAPICount
			)
		);
		limits.add(
			new LimitItem('DailyDurableGenericStreamingApiEvents', 10000, 10000)
		);
		limits.add(
			new LimitItem('DailyDurableStreamingApiEvents', 10000, 10000)
		);
		return limits;
	}
}
