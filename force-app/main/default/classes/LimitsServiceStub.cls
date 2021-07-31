public with sharing class LimitsServiceStub implements ILimitsService {
	private List<LimitItem> limits;

	public LimitsServiceStub(List<LimitItem> limits) {
		this.limits = limits;
	}

	public List<LimitItem> getLimits() {
		return limits;
	}
}
