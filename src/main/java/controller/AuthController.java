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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String p   = path(req);
        String ctx = req.getContextPath();

        try {
            switch (p) {

                case "/login": {
                    // ❌ VULNERABLE: No trimming, no validation
                    String loginId  = req.getParameter("username");
                    String password = req.getParameter("password");

                    User_login u = auth.login(loginId, password);
                    if (u != null) {
                        

                        HttpSession session = req.getSession(true);
                        session.setAttribute("user", u);
                        session.setMaxInactiveInterval(30 * 60);

                        if (isAdmin(u)) {                                  
                            resp.sendRedirect(ctx + "/admin/dashboard");            
                        } else {                                         
                            resp.sendRedirect(ctx + "/");                 
                        }                                            
                    } else {
                        flashErr(req, "Sai username/email hoặc password");
                        resp.sendRedirect(ctx + "/auth/login");
                    }
                    return;
                }


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
                    flashOk(req, "Reset password thành công");
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

    private static String path(HttpServletRequest req){ String p=req.getPathInfo(); return p==null?"":p; }
    private static String trim(String s){ return s==null?"":s.trim(); }
    private static void forward(HttpServletRequest req,HttpServletResponse resp,String view)
            throws ServletException, IOException { req.getRequestDispatcher(view).forward(req, resp); }
    private static void flashOk(HttpServletRequest req,String msg){ req.getSession(true).setAttribute("flash_ok", msg); }
    private static void flashErr(HttpServletRequest req,String msg){ req.getSession(true).setAttribute("flash_err", msg); }

    private static boolean isAdmin(User_login u) {                      
        if (u == null) return false;                                  
        try {                                                            

            Object val = u.isAdmin();                              
            if (val instanceof Boolean) return (Boolean) val;        
            if (val instanceof Integer) return ((Integer) val) == 1;      
        } catch (Throwable ignore) { /* no-op */ }                         
           
        try {                                           
       
            java.lang.reflect.Method m = u.getClass().getMethod("isAdmin");
            Object r = m.invoke(u);
            if (r instanceof Boolean) return (Boolean) r;
        } catch (Throwable ignore) { /* no-op */ }                      
        return false;                                                    
    }                                                                   
}
