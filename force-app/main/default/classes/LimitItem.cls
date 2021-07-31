public without sharing class LimitItem {
	public String key { get; set; }
	public AlertMessage.Severity severityLevel { get; set; }
	public Integer max { get; set; }
	public Integer remaining { get; set; }

	public LimitItem(OrgLimit orgLimit) {
		this.key = orgLimit.getName();
		this.max = orgLimit.getLimit();
		this.remaining = orgLimit.getValue();
	}

	public LimitItem(String name, Integer max, Integer remaining) {
		this.key = name;
		this.max = max;
		this.remaining = remaining;
	}
}
