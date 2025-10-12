package types;

public enum TopUpRequestTypes {
	PENDING, ACCEPT, DISCARD;
	public static TopUpRequestTypes fromDb(String dbValue) {
		if (dbValue == null) return null; // or return a default, e.g., EXPIRED
	    switch (dbValue.toLowerCase(java.util.Locale.ROOT)) {
	      case "pending":   return PENDING;
	      case "accept":  return ACCEPT;
	      case "discard": return DISCARD;
	      default:
	        throw new IllegalArgumentException("Unknown status: " + dbValue);
	    }
	  }

	  public String toDb() {
	    return name().toLowerCase(java.util.Locale.ROOT);
	  }
}
