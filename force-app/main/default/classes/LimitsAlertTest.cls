
@SuppressWarnings('PMD.ExcessiveParameterList')
@isTest
private class LimitsAlertTest
{
	@isTest
	static void itShouldAlertHighWhenAPIFails()
	{
		// Given
		final Map<String, String> responseHeaders = new Map<String, String>();
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(500, 'Internal Server Error',
			null, responseHeaders);
		
		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert(null);
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(messages.get(0).level == AlertMessage.Severity.HIGH, 'should raise alert with HIGH severity');
		System.assert(messages.get(0).message.contains(LimitsAlertHelper.LIMIT_EXCEPTION_BASE_MSG), 'should raise alert with matching message');
	}

	@isTest
	static void itShouldNotAlertWhenThereIsNoProblem()
	{
		// Given
		final String responseBody = getLimitsBody('15000', '5000');
		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(200, 'OK',
			responseBody, responseHeaders);
		
		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert(configList);
			Boolean shouldAlert = alert.shouldAlert();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == false, 'should not alert when there is no problem');
	}

	@isTest
	static void itShouldAlertWithMediumWhenThereIsASmallProblem()
	{
		// Given
		final String responseBody = getLimitsBody('3000', '5000');
		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(200, 'OK',
			responseBody, responseHeaders);
		
		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert(configList);
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(messages.size() == 1, 'should contain only 1 message in the alert');
		System.assert(messages.get(0).level == AlertMessage.Severity.MEDIUM, 'alert level should match');
		System.assert(messages.get(0).message.containsIgnoreCase('DailyApiRequests'), 'alert should be for api requests');
		System.assert(messages.get(0).message.containsIgnoreCase('"Max": 15000'), 'max value should be 15000');
		System.assert(messages.get(0).message.containsIgnoreCase('"Remaining": 3000'), 'remaining should be 3000');
	}

	@isTest
	static void itShouldAlertWithHighWhenThereIsABigProblem()
	{
		// Given
		final String responseBody = getLimitsBody('15000', '20');
		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(200, 'OK',
			responseBody, responseHeaders);
		
		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert(configList);
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(messages.size() == 1, 'should contain only 1 message in the alert');
		System.assert(messages.get(0).level == AlertMessage.Severity.HIGH, 'alert level should match');
		System.assert(messages.get(0).message.containsIgnoreCase('DailyBulkApiRequests'), 'alert should be for bulk api requests');
		System.assert(messages.get(0).message.containsIgnoreCase('"Max": 5000'), 'max value should be 5000');
		System.assert(messages.get(0).message.containsIgnoreCase('"Remaining": 20'), 'remaining should be 20');
	}

	@isTest
	static void itShouldAlertWithHighWhenThereAreBigProblems()
	{
		// Given
		final String responseBody = getLimitsBody('200', '20');
		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(200, 'OK',
			responseBody, responseHeaders);

		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);
		
		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert(configList);
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(messages.size() == 2, 'should contain 2 messages in the alert');
		Boolean hasApi = false;
		Boolean hasBulkApi = false;
		for(AlertMessage am : messages) {
			if (am.message.containsIgnoreCase('DailyApiRequests')){
				hasApi = true;
				System.assert(am.level == AlertMessage.Severity.HIGH, 'alert level should match');
				System.assert(am.message.containsIgnoreCase('"Max": 15000'), 'api max value should be 15000');
				System.assert(am.message.containsIgnoreCase('"Remaining": 200'), 'api remaining value should be 200');
			} else if (am.message.containsIgnoreCase('DailyBulkApiRequests')) {
				hasBulkApi = true;
				System.assert(am.level == AlertMessage.Severity.HIGH, 'alert level should match');
				System.assert(am.message.containsIgnoreCase('"Max": 5000'), 'bulk api max value should be 5000');
				System.assert(am.message.containsIgnoreCase('"Remaining": 20'), 'bulk api remaining value should be 20');
			}
		}
		System.assert(hasApi && hasBulkApi, 'both api and bulk api should be present');
	}

	@isTest
	static void itShouldUseCustomAlerts()
	{
		// Given
		final String responseBody = getLimitsBody('15000', '2500');
		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(200, 'OK',
			responseBody, responseHeaders);
		
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

		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert(configList);
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(messages.size() == 1, 'should contain only 1 message in the alert');
		System.assert(messages.get(0).level == AlertMessage.Severity.MEDIUM, 'alert level should match');
		System.assert(messages.get(0).message.containsIgnoreCase('DailyBulkApiRequests'), 'alert should be for bulk api requests');
		System.assert(messages.get(0).message.containsIgnoreCase('"Max": 5000'), 'max value should be 5000');
		System.assert(messages.get(0).message.containsIgnoreCase('"Remaining": 2500'), 'remaining should be 2500');
	}

	@isTest
	static void itShouldUseCustomAlertsWith100PctUsage()
	{
		// Given
		final String responseBody = getLimitsBody('15000', '0');
		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(200, 'OK',
			responseBody, responseHeaders);
		
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

		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert(configList);
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true, 'should raise an alert');
		System.assert(messages.size() == 1, 'should contain only 1 message in the alert');
		System.assert(messages.get(0).level == AlertMessage.Severity.MEDIUM, 'alert level should match');
		System.assert(messages.get(0).message.containsIgnoreCase('DailyBulkApiRequests'), 'alert should be for bulk api requests');
		System.assert(messages.get(0).message.containsIgnoreCase('"Max": 5000'), 'max value should be 5000');
		System.assert(messages.get(0).message.containsIgnoreCase('"Remaining": 0'), 'remaining should be 0');
	}

	@isTest
	static void itShouldUseCustomAlertsWithMoreThan100PctUsage()
	{
		// Given
		final String responseBody = getLimitsBody('15000', '-20');
		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(200, 'OK',
			responseBody, responseHeaders);
		
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

		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert(configList);
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == false, 'should not raise an alert when limits have not exceeded');
		System.assert(messages.isEmpty(), 'no messages should be present');
	}

	@isTest
	static void itShouldNotAlertWhenLimitIsNotConfiguredForOrg()
	{
		// When limit is not configured for org, the max value is 0
		// Given
		final String responseBody = getLimitsBody('15000', '15000', '0', '0');
		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(200, 'OK',
			responseBody, responseHeaders);
		
		List<Config__mdt> configList = new List<Config__mdt>();
		Config__mdt all = new Config__mdt();
		all.DeveloperName = 'All';
		all.MasterLabel = 'All';
		all.Warning__c = 0.7;
		all.Severe__c = 0.9;
		configList.add(all);

		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert(configList);
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == false, 'should not alert because limit is not configured for org');
		System.assert(messages.isEmpty(), 'no alert messages should be generated');
	}

	static String getLimitsBody(String remainingAPICount, String remainingBulkAPICount) {
		return getLimitsBody(remainingAPICount, '15000', remainingBulkAPICount, '5000');
	}

	static String getLimitsBody(String remainingAPICount, 
		String maxAPICount, 
		String remainingBulkAPICount, 
		String maxBulkAPICount) 
	{
        // prettier-ignore
		return '{'
				+'  "ConcurrentAsyncGetReportInstances": {'
				+'    "Max": 200,'
				+'    "Remaining": 200'
				+'  },'
				+'  "ConcurrentSyncReportRuns": {'
				+'    "Max": 20,'
				+'    "Remaining": 20'
				+'  },'
				+'  "DailyApiRequests": {'
				+'    "Max": ' + maxAPICount + ','
				+'    "Remaining": ' + remainingAPICount + ''
				+'  },'
				+'  "DailyAsyncApexExecutions": {'
				+'    "Max": 250000,'
				+'    "Remaining": 250000'
				+'  },'
				+'  "DailyBulkApiRequests": {'
				+'    "Max": ' + maxBulkAPICount + ','
				+'    "Remaining": ' + remainingBulkAPICount + ''
				+'  },'
				+'  "DailyDurableGenericStreamingApiEvents": {'
				+'    "Max": 10000,'
				+'    "Remaining": 10000'
				+'  },'
				+'  "DailyDurableStreamingApiEvents": {'
				+'    "Max": 10000,'
				+'    "Remaining": 10000'
				+'  },'
				+'  "DailyWorkflowEmails": {'
				+'    "Max": 390,'
				+'    "Remaining": 390'
				+'  },'
				+'  "DataStorageMB": {'
				+'    "Max": 5,'
				+'    "Remaining": 5'
				+'  },'
				+'  "DurableStreamingApiConcurrentClients": {'
				+'    "Max": 20,'
				+'    "Remaining": 20'
				+'  },'
				+'  "FileStorageMB": {'
				+'    "Max": 20,'
				+'    "Remaining": 20'
				+'  },'
				+'  "HourlyAsyncReportRuns": {'
				+'    "Max": 1200,'
				+'    "Remaining": 1200'
				+'  },'
				+'  "HourlyDashboardRefreshes": {'
				+'    "Max": 200,'
				+'    "Remaining": 200'
				+'  },'
				+'  "HourlyDashboardResults": {'
				+'    "Max": 5000,'
				+'    "Remaining": 5000'
				+'  },'
				+'  "HourlyDashboardStatuses": {'
				+'    "Max": 999999999,'
				+'    "Remaining": 999999999'
				+'  },'
				+'  "HourlyODataCallout": {'
				+'    "Remaining": 9999,'
				+'    "Max": 10000'
				+'  },'
				+'  "HourlySyncReportRuns": {'
				+'    "Max": 500,'
				+'    "Remaining": 500'
				+'  },'
				+'  "HourlyTimeBasedWorkflow": {'
				+'    "Max": 50,'
				+'    "Remaining": 50'
				+'  },'
				+'  "MassEmail": {'
				+'    "Max": 10,'
				+'    "Remaining": 10'
				+'  },'
				+'  "MonthlyPlatformEvents": {'
				+'    "Max": 300000,'
				+'    "Remaining": 300000'
				+'  },'
				+'  "SingleEmail": {'
				+'    "Max": 15,'
				+'    "Remaining": 15'
				+'  }'
				+'}';
	}
}
