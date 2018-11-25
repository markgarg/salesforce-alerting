// Follows design pattern from http://advancedapex.com/2012/11/14/scheduledapex/
// so that Scheduled job implementation can change
global class BaseScheduler implements Schedulable {
	global interface ISchedule {
		void execute(SchedulableContext sc);
	}

	global void execute(SchedulableContext sc) {
		Type targettype = Type.forName('AlertManagerSchedulable');
		if(targettype != null) {
			ISchedule obj = (ISchedule)targettype.newInstance();
			obj.execute(sc);
		}
	}
}