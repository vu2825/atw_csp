package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.time.Instant;
import java.util.logging.Logger;

/**
 * CspReportServlet — nhận báo cáo vi phạm CSP từ browser
 *
 * Browser tự động POST dữ liệu JSON đến đây khi có:
 *  - Script/style bị chặn bởi CSP
 *  - Inline script không có nonce/hash hợp lệ
 *  - Tài nguyên bị chặn từ domain ngoài
 *
 * Endpoint: POST /csp-report
 *
 * Cách dùng:
 *  1. Xem log bằng: docker logs <container> | grep "CSP_VIOLATION"
 *  2. Hoặc mở rộng: lưu vào DB, gửi alert Slack, v.v.
 */
@WebServlet("/csp-report")
public class CspReportServlet extends HttpServlet {

    private static final Logger log = Logger.getLogger(CspReportServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Đọc JSON body từ browser
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String reportJson = sb.toString();
        String clientIp   = req.getHeader("X-Forwarded-For");
        if (clientIp == null) clientIp = req.getRemoteAddr();

        // Ghi vào log — dễ dàng grep sau này
        log.warning("CSP_VIOLATION | ip=" + clientIp
                + " | time=" + Instant.now()
                + " | report=" + reportJson);

        // Trả về 204 No Content theo chuẩn CSP
        resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }
}
