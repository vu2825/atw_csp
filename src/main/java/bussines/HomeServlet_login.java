package bussines;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(urlPatterns = {"/home", "/account"})
public class HomeServlet_login extends HttpServlet {
  private static final String BASE_VIEW = "/WEB-INF/views/auth";

  private void forward(HttpServletRequest req, HttpServletResponse resp, String view)
      throws ServletException, IOException {
    req.getRequestDispatcher(view).forward(req, resp);
  }

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    String ctx = req.getContextPath();
    String uri = req.getRequestURI().substring(ctx.length());

    // bypass static (an toàn)
    if (uri.startsWith("/styles/") || uri.startsWith("/images/")
        || "/favicon.ico".equals(uri) || "/robots.txt".equals(uri)) {
      RequestDispatcher d = req.getServletContext().getNamedDispatcher("default");
      if (d != null) { d.forward(req, resp); return; }
      resp.sendError(HttpServletResponse.SC_NOT_FOUND); return;
    }

    switch (req.getServletPath()) {
      case "/home":

        resp.sendRedirect(ctx + "/auth/login");
        return;

      case "/account":

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("user") == null) {
          resp.sendRedirect(ctx + "/auth/login");    
        } else {
          forward(req, resp, "/TaiKhoan.jsp");      
        }
        return;

      default:
        resp.sendRedirect(ctx + "/auth/login");
    }
  }
}
