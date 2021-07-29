// Follows design pattern from http://advancedapex.com/2012/11/14/scheduledapex/
// so that Scheduled job implementation can change
global class BaseScheduler implements Schedulable, Database.Batchable<sObject>,
		Database.AllowsCallouts {
	
	private SchedulableContext sc;

	global BaseScheduler() {
	}

	global BaseScheduler(SchedulableContext scc) {
		this.sc = scc;
	}

	global interface ISchedule {
		void execute(SchedulableContext sc);
	}

	global void execute(SchedulableContext sc) {
		System.scheduleBatch(new BaseScheduler(sc), 'Limits Alert job', 0);
	}

	// Batch job is used so that callouts are available from scheduled job
	// The batch doesn't do anything.
	global Database.QueryLocator start(Database.BatchableContext bc) {
		Type targettype = Type.forName('AlertManagerSchedulable');
		if(targettype != null) {
			ISchedule obj = (ISchedule)targettype.newInstance();
			obj.execute(sc);
		}

		// Dummy SOQL
		return Database.getQueryLocator('SELECT Id FROM Account LIMIT 1');
	}

	global void execute(Database.BatchableContext bc, List<sObject> unused) {}
	global void finish(Database.BatchableContext bc) {}
}
