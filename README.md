# Salesforce Alerting
A simple alerting mechanism for Salesforce.com, with a sample Slack integration.

## Limits Alerts
This class uses a sample alert mechanism for sending a message to a Slack channel when Salesforce Governor Limits are breached or nearing.

At the moment, these are hardcoded to alert with a MEDIUM alert when 70% of a limit is reached and a HIGH alert at 90% or more. Further iterations will move these to a Custom Metadata Type.

There are interfaces for `Alert` and `AlertInvoker` so custom alerts can easily be built.

In the current codebase, a sample Slack integration is provided.

## Sample usage
First, configure the Slack params in the `Config__mdt` metadata.
Use this for scheduling the alerts:
```
BaseScheduler base = new BaseScheduler();
String sch = '0 21 20 * * ?';
String jobID = System.schedule('Alert job', sch, base);
```

When the governor limits reach the specified values, a Slack alert will be triggered.