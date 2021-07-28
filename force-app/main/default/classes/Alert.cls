public interface Alert {
	Boolean shouldAlert();
	List<AlertMessage> getMessages();
}