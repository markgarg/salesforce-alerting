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
			String message = alert.getMessage();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true);
		System.assert(message.containsIgnoreCase('DailyApiRequests'));
		System.assert(message.containsIgnoreCase('"Max": 15000'));
		System.assert(message.containsIgnoreCase('"Remaining": 3000'));
	}

	@isTest
	static void itShouldAlertWithMediumWhenThereIsABigProblem()
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
			String message = alert.getMessage();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true);
		System.assert(message.containsIgnoreCase('DailyBulkApiRequests'));
		System.assert(message.containsIgnoreCase('"Max": 5000'));
		System.assert(message.containsIgnoreCase('"Remaining": 20'));
	}

	@isTest
	static void itShouldAlertWithMediumWhenThereAreProblems()
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
			String message = alert.getMessage();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true);
		System.assert(message.containsIgnoreCase('DailyApiRequests'));
		System.assert(message.containsIgnoreCase('"Max": 15000'));
		System.assert(message.containsIgnoreCase('"Remaining": 200'));
		System.assert(message.containsIgnoreCase('DailyBulkApiRequests'));
		System.assert(message.containsIgnoreCase('"Max": 5000'));
		System.assert(message.containsIgnoreCase('"Remaining": 20'));
	}

	@isTest
	static void itShouldAlertWhenAPIFails()
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
			String message = alert.getMessage();
		Test.stopTest();

		// Then
		System.assert(shouldAlert == true);
		System.assert(message.contains(LimitsAlert.LIMIT_EXCEPTION_BASE_MSG));
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