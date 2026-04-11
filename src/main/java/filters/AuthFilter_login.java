package filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter_login implements Filter {
  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException {

    HttpServletRequest req = (HttpServletRequest) request;
    HttpServletResponse resp = (HttpServletResponse) response;

    // 🔒 FIX #2: CSP đầy đủ — thêm connect-src, object-src, base-uri, form-action
    //
    // Tại sao cần thêm:
    // connect-src 'self' → chặn fetch/XHR đến domain lạ (chống data exfiltration
    // qua XSS)
    // object-src 'none' → chặn Flash/plugin cũ — vector tấn công phổ biến
    // base-uri 'self' → chặn <base href="https://evil.com"> inject — hijack tất cả
    // relative URL
    // form-action 'self' → chặn form submit đến domain ngoài — chống CSRF nâng cao
    resp.setHeader("Content-Security-Policy",
        "default-src 'self'; " +
            "script-src 'self'; " +
            "style-src 'self' https://cdnjs.cloudflare.com; " +
            "font-src 'self' https://cdnjs.cloudflare.com; " +
            "img-src 'self' data:; " +
            "connect-src 'self'; " +
            "object-src 'none'; " +
            "base-uri 'self'; " +
            "form-action 'self'; " +
            "frame-ancestors 'none';");

    resp.setHeader("X-Frame-Options", "DENY");
    resp.setHeader("X-Content-Type-Options", "nosniff");
    resp.setHeader("X-XSS-Protection", "1; mode=block");
    resp.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
    resp.setHeader("Permissions-Policy", "geolocation=(), microphone=(), camera=()");

    String ctx = req.getContextPath();
    String uri = req.getRequestURI();
    boolean isPublic = uri.startsWith(ctx + "/auth/")
        || uri.startsWith(ctx + "/styles/")
        || uri.startsWith(ctx + "/images/")
        || uri.equals(ctx + "/") || uri.equals(ctx + "/index.jsp")
        || uri.contains("SearchServlet");

    HttpSession session = req.getSession(false);
    boolean loggedIn = (session != null && session.getAttribute("user") != null);

    if (!isPublic && !loggedIn) {
      resp.sendRedirect(ctx + "/auth/login");
      return;
    }

    chain.doFilter(request, response);
  }
}
