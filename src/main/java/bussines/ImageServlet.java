package bussines;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;

@WebServlet("/ImageServlet")
public class ImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String filename = req.getParameter("file");
        if (filename == null || filename.isEmpty()) {
            serveDefaultImage(resp);
            return;
        }


        File file = new File(getServletContext().getRealPath("/profile_images/"), filename);

        if (!file.exists()) {
            // Let's try to serve it from an absolute path if it's not in profile_images
            file = new File(filename);
            if (!file.exists()) {
                serveDefaultImage(resp);
                return;
            }
        }

        String mimeType = getServletContext().getMimeType(file.getName());
        if (mimeType == null) mimeType = "image/jpeg";
        resp.setContentType(mimeType);
        resp.setContentLengthLong(file.length());

        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {
            in.transferTo(out);
        }
    }

    private void serveDefaultImage(HttpServletResponse resp) throws IOException {
        File defaultFile = new File(getServletContext().getRealPath("/profile_images/default-avatar.jpg"));

        if (!defaultFile.exists()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Ảnh mặc định không tồn tại.");
            return;
        }

        String mimeType = getServletContext().getMimeType(defaultFile.getName());
        if (mimeType == null) mimeType = "image/jpeg";
        resp.setContentType(mimeType);
        resp.setContentLengthLong(defaultFile.length());

        try (FileInputStream in = new FileInputStream(defaultFile);
             OutputStream out = resp.getOutputStream()) {
            in.transferTo(out);
        }
    }
}
