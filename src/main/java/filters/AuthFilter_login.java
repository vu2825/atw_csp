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

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 1. CONTENT SECURITY POLICY (có report-uri để monitoring)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
            "frame-ancestors 'none'; " +
            // ✅ MỚI: upgrade HTTP request thành HTTPS tự động
            "upgrade-insecure-requests; " +
            // ✅ MỚI: gửi báo cáo vi phạm CSP về endpoint /csp-report
            "report-uri /csp-report;");

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 2. HTTPS READINESS — HSTS (chỉ kích hoạt khi chạy HTTPS)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // Khi deploy HTTPS thật, bỏ comment dòng dưới:
    // resp.setHeader("Strict-Transport-Security", "max-age=31536000;
    // includeSubDomains");

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 3. CÁC SECURITY HEADER KHÁC (giữ nguyên như cũ)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    resp.setHeader("X-Frame-Options", "DENY");
    resp.setHeader("X-Content-Type-Options", "nosniff");
    resp.setHeader("X-XSS-Protection", "1; mode=block");
    resp.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
    resp.setHeader("Permissions-Policy", "geolocation=(), microphone=(), camera=()");

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 4. AUTH GUARD (giữ nguyên logic cũ)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    String ctx = req.getContextPath();
    String uri = req.getRequestURI();
    boolean isPublic = uri.startsWith(ctx + "/auth/")
        || uri.startsWith(ctx + "/styles/")
        || uri.startsWith(ctx + "/images/")
        || uri.equals(ctx + "/") || uri.equals(ctx + "/index.jsp")
        || uri.contains("SearchServlet")
        // ✅ MỚI: cho phép endpoint nhận báo cáo CSP (không cần login)
        || uri.equals(ctx + "/csp-report");

    HttpSession session = req.getSession(false);
    boolean loggedIn = (session != null && session.getAttribute("user") != null);

    if (!isPublic && !loggedIn) {
      resp.sendRedirect(ctx + "/auth/login");
      return;
    }

    chain.doFilter(request, response);
  }
}
