public without sharing class AlertMessage {
	public enum Severity {LOW, MEDIUM, HIGH}
	public Severity level {get; set;}
	public String message {get; set;}

	public AlertMessage(Severity level, final String message) {
		this.level = level;
		this.message = message;
	}
}