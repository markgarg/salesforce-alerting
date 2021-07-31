public with sharing class LimitsServiceImpl implements ILimitsService {
    public List<LimitItem> getLimits() {
		List<LimitItem> limits = new List<LimitItem>();
		for (System.OrgLimit aLimit: OrgLimits.getAll()) {
			limits.add(new LimitItem(aLimit));
		}
		return limits;
	}
}