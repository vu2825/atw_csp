package bussines;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import javax.sql.DataSource;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import dao.UserDao_login;
import dao.UserDao_update;
import data.UserDB;

@WebServlet("/ProfileServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, 
    maxFileSize = 5 * 1024 * 1024,   
    maxRequestSize = 10 * 1024 * 1024
)
public class ProfileServlet extends HttpServlet {
    private UserDao_login userDao = new UserDao_login();
    private UserDao_update userDao_u = new UserDao_update();

    private DataSource ds;

    @Override
    public void init() throws ServletException {

        try {
            InitialContext ic = new InitialContext();
            try {
                ds = (DataSource) ic.lookup("java:comp/env/jdbc/loginDB");
            } catch (NamingException ex1) {
 
                ds = (DataSource) ic.lookup("java:/comp/env/jdbc/loginDB");
            }
        } catch (NamingException e) {
            throw new ServletException("Không tìm thấy DataSource jdbc/loginDB. Kiểm tra context.xml", e);
        }
    }

    private void attachPremiumFlag(HttpServletRequest req) {
        User_login user = (User_login) req.getSession().getAttribute("user");
        boolean isPremium = false;
        if (user != null && ds != null) {
            UserDB userDB = new UserDB(ds);

            isPremium = userDB.checkUserIsPremium((int) user.getId());
        }
        req.setAttribute("isPremium", isPremium);
        req.setAttribute("notPremium", !isPremium);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        attachPremiumFlag(req);
        req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("changePassword".equals(action)) {
            changePassword(req, resp);
            return;
        }
        if ("logout".equals(action)) {
            logout(req, resp);
            return;
        }

        try {
            long id = Long.parseLong(req.getParameter("id"));
            String fullname = req.getParameter("fullname");
            String username = req.getParameter("username");
            String email = req.getParameter("email");

            if (email == null || email.trim().isEmpty()) {
                req.setAttribute("error", " Email không được để trống!");
                attachPremiumFlag(req);
                req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);
                return;
            }

            if (!email.matches("^[\\w._%+-]+@[\\w.-]+\\.[a-zA-Z]{2,6}$")) {
                req.setAttribute("error", " Định dạng email không hợp lệ!");
                attachPremiumFlag(req);
                req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);
                return;
            }

            if (userDao_u.existsEmail(email, id)) {
                req.setAttribute("error", " Email này đã tồn tại!");
                attachPremiumFlag(req);
                req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);
                return;
            }

            Part filePart = req.getPart("avatarFile");
            String fileName = null;

            if (filePart != null && filePart.getSize() > 0) {
                fileName = new File(filePart.getSubmittedFileName()).getName();

                String uploadPath = getServletContext().getRealPath("/profile_images");
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();

                filePart.write(uploadPath + File.separator + fileName);
            }

            User_login user = (User_login) req.getSession().getAttribute("user");
            if (fileName == null || fileName.isEmpty()) {
                fileName = user.getAvatar();
            }

            user.setFullname(fullname);
            user.setUsername(username);
            user.setEmail(email);
            user.setAvatar(fileName);

            boolean success = userDao_u.update(user);

            if (success) {
                req.getSession().setAttribute("user", user);
                req.setAttribute("success", " Cập nhật thông tin thành công!");
            } else {
                req.setAttribute("error", " Không thể cập nhật người dùng!");
            }

            attachPremiumFlag(req);
            req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "️ Lỗi: " + e.getMessage());
            attachPremiumFlag(req);
            req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);
        }
    }

    private void changePassword(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        try {
            User_login user = (User_login) req.getSession().getAttribute("user");
            String currentPass = req.getParameter("currentPassword");
            String newPass = req.getParameter("newPassword");
            String confirmPass = req.getParameter("confirmPassword");

            if (!newPass.equals(confirmPass)) {
                req.setAttribute("error", " Mật khẩu xác nhận không khớp!");
                attachPremiumFlag(req);
                req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);
                return;
            }

            if (!user.getPassword().equals(currentPass)) {
                req.setAttribute("error", " Mật khẩu hiện tại không đúng!");
                attachPremiumFlag(req);
                req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);
                return;
            }

            userDao.updatePasswordByUsername(user.getUsername(), newPass);
            user.setPassword(newPass);
            req.getSession().setAttribute("user", user);

            req.setAttribute("success", " Đổi mật khẩu thành công!");
            attachPremiumFlag(req);
            req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "️ Lỗi khi đổi mật khẩu: " + e.getMessage());
            attachPremiumFlag(req);
            req.getRequestDispatcher("/TaiKhoan.jsp").forward(req, resp);
        }
    }

    private void logout(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) session.invalidate();
        resp.sendRedirect(req.getContextPath() + "/auth/login");
    }
}
