package controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

import bussines.User_login;
import service.AuthService_login;

@WebServlet("/auth/*")
public class AuthController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final AuthService_login auth = new AuthService_login();

    // ===== GET =====
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // flash from session -> request
        HttpSession s = req.getSession(false);
        if (s != null) {
            Object ok  = s.getAttribute("flash_ok");
            Object err = s.getAttribute("flash_err");
            if (ok  != null) { req.setAttribute("msg", ok);   s.removeAttribute("flash_ok");  }
            if (err != null) { req.setAttribute("error", err); s.removeAttribute("flash_err"); }
        }

        String p = path(req);
        switch (p) {
            case "":
            case "/":
            case "/login":
                // nếu bị filter chặn: ?msg=login_required -> hiện nhắc đăng nhập
                forward(req, resp, "/WEB-INF/views/auth/login.jsp");
                return;

            case "/signup":
                forward(req, resp, "/WEB-INF/views/auth/signup.jsp");
                return;

            case "/forgot":
                forward(req, resp, "/WEB-INF/views/auth/forgot.jsp");
                return;
            default:
                resp.sendError(404);
        }
    }

    // ===== POST =====
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String p   = path(req);
        String ctx = req.getContextPath();

        try {
            switch (p) {
                // --- LOGIN ---
                case "/login": {
                    String loginId  = trim(req.getParameter("username"));
                    String password = trim(req.getParameter("password"));

                    if (loginId.isEmpty() || password.isEmpty()) {
                        flashErr(req, "Username/Password không được để trống");
                        resp.sendRedirect(ctx + "/auth/login");
                        return;
                    }

                    User_login u = auth.login(loginId, password);
                    if (u != null) {
                        // [ADDED] Chống session fixation: hủy session cũ trước khi tạo session mới
                        HttpSession old = req.getSession(false);          // [ADDED]
                        if (old != null) old.invalidate();                // [ADDED]

                        HttpSession session = req.getSession(true);
                        session.setAttribute("user", u);
                        session.setMaxInactiveInterval(30 * 60);

                        // [ADDED] Rẽ nhánh điều hướng theo quyền isAdmin
                        if (isAdmin(u)) {                                  // [ADDED]
                            resp.sendRedirect(ctx + "/admin/dashboard");             // [ADDED] Admin → /admin
                        } else {                                           // [ADDED]
                            resp.sendRedirect(ctx + "/");                  // [ADDED] User thường → /
                        }                                                  // [ADDED]
                    } else {
                        flashErr(req, "Sai username/email hoặc password");
                        resp.sendRedirect(ctx + "/auth/login");
                    }
                    return;
                }

                // --- SIGNUP ---
                case "/signup": {
                    String fullname = trim(req.getParameter("fullname"));
                    String email    = trim(req.getParameter("email"));
                    String username = trim(req.getParameter("username"));
                    String password = trim(req.getParameter("password"));

                    String err = auth.register(fullname, email, username, password);
                    if (err == null) {
                        req.setAttribute("username", username);
                        forward(req, resp, "/WEB-INF/views/auth/signup_done.jsp");
                    } else {
                        req.setAttribute("error", err);
                        forward(req, resp, "/WEB-INF/views/auth/signup.jsp");
                    }
                    return;
                }

                // --- FORGOT ---
                case "/forgot": {
                    String username = trim(req.getParameter("username"));
                    String newPass  = trim(req.getParameter("newPassword"));
                    String confirm  = trim(req.getParameter("confirmPassword"));

                    String err = auth.resetPassword(username, newPass, confirm);
                    if (err != null) {
                        req.setAttribute("error", err);
                        req.setAttribute("username", username);
                        forward(req, resp, "/WEB-INF/views/auth/forgot.jsp");
                        return;
                    }
                    flashOk(req, "Reset password thành công");   // ✅ nhét msg vào session để show 1 lần
                    resp.sendRedirect(ctx + "/auth/login");
                    return;
                }

                default:
                    resp.sendError(404);
            }
        } catch (Exception e) {
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            forward(req, resp, "/WEB-INF/views/auth/login.jsp");
        }
    }

    // ===== helpers =====
    private static String path(HttpServletRequest req){ String p=req.getPathInfo(); return p==null?"":p; }
    private static String trim(String s){ return s==null?"":s.trim(); }
    private static void forward(HttpServletRequest req,HttpServletResponse resp,String view)
            throws ServletException, IOException { req.getRequestDispatcher(view).forward(req, resp); }
    private static void flashOk(HttpServletRequest req,String msg){ req.getSession(true).setAttribute("flash_ok", msg); }
    private static void flashErr(HttpServletRequest req,String msg){ req.getSession(true).setAttribute("flash_err", msg); }

    // [ADDED] Helper xác định quyền admin dựa trên kiểu dữ liệu của User_login.isAdmin
    // Điều chỉnh cho khớp với model của bạn (boolean getIsAdmin() hoặc Integer getIsAdmin())
    private static boolean isAdmin(User_login u) {                         // [ADDED]
        if (u == null) return false;                                       // [ADDED]
        try {                                                              // [ADDED]
            // Thử các khả năng thường gặp: Boolean hoặc Integer 0/1        // [ADDED]
            // Giả sử có getter getIsAdmin(); nếu tên khác, đổi cho đúng.   // [ADDED]
            Object val = u.isAdmin();                                   // [ADDED]
            if (val instanceof Boolean) return (Boolean) val;              // [ADDED]
            if (val instanceof Integer) return ((Integer) val) == 1;       // [ADDED]
        } catch (Throwable ignore) { /* no-op */ }                         // [ADDED]
        // Nếu model có phương thức isAdmin() (kiểu boolean)                // [ADDED]
        try {                                                              // [ADDED]
            // Dùng reflection nhẹ để đỡ lệ thuộc tên field                 // [ADDED]
            java.lang.reflect.Method m = u.getClass().getMethod("isAdmin");
            Object r = m.invoke(u);
            if (r instanceof Boolean) return (Boolean) r;
        } catch (Throwable ignore) { /* no-op */ }                         // [ADDED]
        return false;                                                      // [ADDED]
    }                                                                      // [ADDED]
}
