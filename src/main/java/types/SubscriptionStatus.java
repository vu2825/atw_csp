package types;

public enum SubscriptionStatus {
	 ACTIVE, EXPIRED, CANCELED;

	  public static SubscriptionStatus fromDb(String dbValue) {
	    if (dbValue == null) return null; // or return a default, e.g., EXPIRED
	    switch (dbValue.toLowerCase(java.util.Locale.ROOT)) {
	      case "active":   return ACTIVE;
	      case "expired":  return EXPIRED;
	      case "canceled":
	      case "cancelled": return CANCELED;
	      default:
	        throw new IllegalArgumentException("Unknown status: " + dbValue);
	    }
	  }

	  public String toDb() {
	    return name().toLowerCase(java.util.Locale.ROOT);
	  }
}

