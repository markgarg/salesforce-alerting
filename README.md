# Salesforce Alerting

![CI](https://github.com/markgarg/salesforce-alerting/actions/workflows/ci-pr.yml/badge.svg)

A simple alerting mechanism for Salesforce.com, with a sample Slack integration. There's a [blog post here](https://rohitmacherla.com/slack-alerts-for-salesforce) to elaborate on this. It's also a part of the series I am writing about monitoring your Salesforce enterprise.

## Limits Alerts

This class uses a sample alert mechanism for sending a message to a Slack channel when Salesforce Governor Limits are breached or nearing.

The limit levels can be set in the custom metadata `Config__mdt`. A default value of 70% for `WARNING` and 90% for `SEVERE` messages is already configured in the metadata with the name `All`. If a particular limit needs to be changed, a new metadata record can be introduced with that name. For example, if storage space is already at 85% and you'd like to be alerted only at 95% and 99% for warning and severe messages, respectively, then you'd need to add a new custom metadata record for `Config__mdt`. The key would be `DataStorageMB` (same as what the API returns), and values would be correspondingly configured. This is also present as an example record in the `customMetadata` directory.

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
