@isTest
private class LimitsAlertTest
{
	@isTest
	static void itShouldNotAlertWhenThereIsNoProblem()
	{
		// Given
		final String responseBody = getLimitsBody('15000', '5000');
		final Map<String, String> responseHeaders = new Map<String, String>();
		responseHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		AlertHttpCalloutMock mock = new AlertHttpCalloutMock(200, 'OK',
			responseBody, responseHeaders);
		
		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert();
			Boolean shouldAlert = alert.shouldAlert();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == false);
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
		
		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert();
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true);
		System.assert(messages.size() == 1);
		System.assert(messages.get(0).level == AlertMessage.Severity.MEDIUM);
		System.assert(messages.get(0).message.containsIgnoreCase('DailyApiRequests'));
		System.assert(messages.get(0).message.containsIgnoreCase('"Max": 15000'));
		System.assert(messages.get(0).message.containsIgnoreCase('"Remaining": 3000'));
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
		
		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert();
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true);
		System.assert(messages.size() == 1);
		System.assert(messages.get(0).level == AlertMessage.Severity.HIGH);
		System.assert(messages.get(0).message.containsIgnoreCase('DailyBulkApiRequests'));
		System.assert(messages.get(0).message.containsIgnoreCase('"Max": 5000'));
		System.assert(messages.get(0).message.containsIgnoreCase('"Remaining": 20'));
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
		
		// When
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			LimitsAlert alert = new LimitsAlert();
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true);
		System.assert(messages.size() == 2);
		Boolean hasApi = false, hasBulkApi = false;
		for(AlertMessage am : messages) {
			if (am.message.containsIgnoreCase('DailyApiRequests')){
				hasApi = true;
				System.assert(am.level == AlertMessage.Severity.HIGH);
				System.assert(am.message.containsIgnoreCase('"Max": 15000'));
				System.assert(am.message.containsIgnoreCase('"Remaining": 200'));
			} else if (am.message.containsIgnoreCase('DailyBulkApiRequests')) {
				hasBulkApi = true;
				System.assert(am.level == AlertMessage.Severity.HIGH);
				System.assert(am.message.containsIgnoreCase('"Max": 5000'));
				System.assert(am.message.containsIgnoreCase('"Remaining": 20'));
			}
		}
		System.assert(hasApi && hasBulkApi);
	}

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
			LimitsAlert alert = new LimitsAlert();
			Boolean shouldAlert = alert.shouldAlert();
			List<AlertMessage> messages = alert.getMessages();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true);
		System.assert(messages.get(0).level == AlertMessage.Severity.HIGH);
		System.assert(messages.get(0).message.contains(LimitsAlert.LIMIT_EXCEPTION_BASE_MSG));
	}

	static String getLimitsBody(String apiCount, String bulkApiCount) {
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
				+'    "Max": 15000,'
				+'    "Remaining": ' + apiCount + ''
				+'  },'
				+'  "DailyAsyncApexExecutions": {'
				+'    "Max": 250000,'
				+'    "Remaining": 250000'
				+'  },'
				+'  "DailyBulkApiRequests": {'
				+'    "Max": 5000,'
				+'    "Remaining": ' + bulkApiCount + ''
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