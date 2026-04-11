package bussines;

public class User_login {
    private long id;
    private String fullname;
    private String email;
    private String username;
    private String password;   
    private String avatar;     
    private double wallet;   
    private boolean isAdmin;   
    private boolean isPremium; 

    public User_login() {}

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public String getFullname() { return fullname; }
    public void setFullname(String fullname) { this.fullname = fullname; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public double getWallet() { return wallet; }
    public void setWallet(double wallet) { this.wallet = wallet; }

    public boolean isAdmin() { return isAdmin; }
    public void setAdmin(boolean admin) { isAdmin = admin; }

    public boolean isPremium() { return isPremium; }
    public void setPremium(boolean premium) { isPremium = premium; }
}
