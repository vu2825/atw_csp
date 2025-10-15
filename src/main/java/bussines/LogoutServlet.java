package bussines;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        // 🔹 Lấy session hiện tại (nếu có)
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate(); // 🔹 Xóa toàn bộ session hiện tại
        }

        // 🔹 Xóa cache trình duyệt để tránh quay lại trang sau khi logout
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        resp.setHeader("Pragma", "no-cache"); // HTTP 1.0
        resp.setDateHeader("Expires", 0); // Proxies

        // 🔹 Chuyển hướng đến trang đăng nhập
        resp.sendRedirect(req.getContextPath() + "/auth/login");
        return;
    }

    // Nếu ai đó gửi POST đến logout → vẫn xử lý như GET
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        doGet(req, resp);
    }
}
