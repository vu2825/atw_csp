package bussines;


import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;

// Servlet phục vụ ảnh từ thư mục profile_images
@WebServlet("/profile_images/*")
public class ImageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        String filename = req.getPathInfo().substring(1); // bỏ dấu '/'
        File file = new File(getServletContext().getRealPath("/profile_images/"), filename);

        if (!file.exists()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        resp.setContentType(getServletContext().getMimeType(file.getName()));
        resp.setContentLengthLong(file.length());

        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {
            in.transferTo(out);
        }
    }
}
