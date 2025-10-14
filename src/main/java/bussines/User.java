package bussines;

public class User {
	private int id;
	private String username;
	private String password;
	private String email;
	private double wallet;
	private Boolean isPremium;
	private Boolean isAdmin;
	
	public User(int id,String username,  String email, int wallet, Boolean isPremium, Boolean isAdmin){
		this.id = id;
		this.username = username;
		this.email = email;
		this.wallet = wallet;
		this.isPremium = isPremium;
		this.isAdmin = isAdmin;
	}
	public User() {
		
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public double getWallet() {
		return wallet;
	}

	public void setWallet(double wallet) {
		this.wallet = wallet;
	}

	public Boolean getIsPremium() {
		return isPremium;
	}

	public void setIsPremium(Boolean isPremium) {
		this.isPremium = isPremium;
	}

	public Boolean getIsAdmin() {
		return isAdmin;
	}

	public void setIsAdmin(Boolean isAdmin) {
		this.isAdmin = isAdmin;
	}
			
}
