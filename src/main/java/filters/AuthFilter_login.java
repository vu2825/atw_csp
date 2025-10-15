package filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;  
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter_login implements Filter {
  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {
    HttpServletRequest req  = (HttpServletRequest) request;
    HttpServletResponse resp = (HttpServletResponse) response;

    String ctx = req.getContextPath();
    String uri = req.getRequestURI();

    boolean isStatic = uri.startsWith(ctx + "/styles/") || uri.startsWith(ctx + "/images/")
        || uri.endsWith(".css") || uri.endsWith(".js")
        || uri.endsWith(".png") || uri.endsWith(".jpg") || uri.endsWith(".jpeg")
        || uri.endsWith(".gif") || uri.endsWith(".svg") || uri.endsWith(".ico");

    boolean isAuth = uri.startsWith(ctx + "/auth/");

    if (isStatic || isAuth) {
      chain.doFilter(request, response);
      return;
    }

    boolean loggedIn = (req.getSession(false) != null &&
                        req.getSession(false).getAttribute("user") != null);

    if (!loggedIn) {
      resp.sendRedirect(ctx + "/auth/login?msg=login_required");
      return;
    }

    // [ADDED] Kiểm tra nếu truy cập /admin mà không phải admin → chặn
    String adminPath = ctx + "/admin/dashboard";
    if (uri.startsWith(adminPath)) {
      bussines.User_login u = (bussines.User_login) req.getSession(false).getAttribute("user");
      if (u == null || !u.isAdmin()) {
        resp.sendRedirect(ctx + "/?err=no_permission"); // hoặc resp.setStatus(403);
        return;
      }
    }

    // Cho qua nếu hợp lệ
    chain.doFilter(request, response);

  }
}
