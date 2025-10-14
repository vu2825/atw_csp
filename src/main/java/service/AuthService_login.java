package service;

import dao.UserDao_login;
import bussines.User_login;

public class AuthService_login {
    private final UserDao_login userDao = new UserDao_login();

    public User_login login(String loginId, String password) throws Exception {
        if (loginId == null || password == null) return null;
        loginId = loginId.trim();
        password = password.trim();
        if (loginId.isEmpty() || password.isEmpty()) return null;

        User_login u = userDao.findByUsernameOrEmail(loginId);
        // So sánh trực tiếp vì DB đang lưu plain text
        if (u != null && u.getPassword() != null
                && u.getPassword().equals(password)) {
            return u;
        }
        return null;
    }

    public String register(String fullname, String email, String username, String password) throws Exception {
        fullname = fullname == null ? null : fullname.trim();
        email    = email == null ? null : email.trim().toLowerCase();
        username = username == null ? null : username.trim();
        password = password == null ? null : password.trim();

        if (userDao.existsEmail(email)) return "Email đã tồn tại";
        if (userDao.existsUsername(username)) return "Username đã tồn tại";

        User_login u = new User_login();
        u.setFullname(fullname);
        u.setEmail(email);
        u.setUsername(username);
        u.setPassword(password);  
        u.setAvatar(null);

        userDao.create(u);
        return null;
    }
public String resetPassword(String username, String newPassword, String confirm) throws Exception {
    if (username == null || newPassword == null || confirm == null) return "Thiếu dữ liệu";
    username = username.trim();
    newPassword = newPassword.trim();
    confirm = confirm.trim();

    if (username.isEmpty() || newPassword.isEmpty() || confirm.isEmpty()) return "Không được để trống";
    if (!newPassword.equals(confirm)) return "Xác nhận mật khẩu không khớp";
    //if (newPassword.length() < 4) return "Mật khẩu tối thiểu 4 ký tự";

    if (!userDao.existsUsername(username)) return "Username không tồn tại";

    int updated = userDao.updatePasswordByUsername(username, newPassword);
    if (updated == 0) return "Không cập nhật được (user không tồn tại?)";

    return null;
}
}
