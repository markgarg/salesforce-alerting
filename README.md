# Salesforce Alerting

A simple alerting mechanism for Salesforce.com, with a sample Slack integration.

## Limits Alerts

This class uses a sample alert mechanism for sending a message to a Slack channel when Salesforce Governor Limits are breached or nearing.

The limit levels can be set in the custom metadata `Config__mdt`. A default value of 70% for `WARNING` and 90% for `SEVERE` messages is already configured in the metadata with the name `All`. If a particular limit needs to be changed, a new metadata record can be introduced with that name. For example, if storage space is already at 85% and you'd like to be alerted only at 95% and 99% for warning and severe messages, respectively, then you'd need to add a new custom metadata record for `Config__mdt`. The key would be `DataStorageMB` (same as what the API returns), and values would be correspondingly configured. This is also present as an example record in the `customMetadata` directory.

There are interfaces for `Alert` and `AlertInvoker` so custom alerts can easily be built.

In the current codebase, a sample Slack integration is provided.

## Setup

As the sessionId from `UserInfo.getSessionId()` no longer works for accessing Salesforce REST API, a Named Credential must be used. Further dependencies include settingup a `ConnectedApp` for OAuth, which will be used to configure an `AuthProvider`, which will then be used in the `NamedCredential` setup. All of these components are included in this repo, but you'd have to create one and update the OAuth `ClientId` and `ClientSecret` in the `AuthProvider` yourself. Care must be taken to include the `AuthProvider`'s callback URL as the `ConnectedApp`'s callback URL.

At the moment, the logic to fire an alert at 90% and 70% of max allowed is in `LimitsAlertHelper.cls` and will be moved to a custom metadata in upcoming releases.

## Sample usage

First, configure the Slack params in the `Config__mdt` metadata.
Use this for scheduling the alerts, the following alerts every minute but note that the Limits API callouts count against your org's API daily callout limit. Having said that, 1440 API calls isn't bad for the good monitoring you get.

```
BaseScheduler base = new BaseScheduler();
String sch = '0 21 20 * * ?';
String jobID = System.schedule('Alert job', sch, base);
```

When the governor limits reach the specified values, a Slack alert will be triggered.
