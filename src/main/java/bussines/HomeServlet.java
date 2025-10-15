package bussines;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/HomeServlet") // <- CHỈ map duy nhất đường này
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) action = "TrangChu"; // tránh NPE

        String url;
        switch (action) {
            case "ListPhim":
                url = "/movies";
                break;
            case "TheLoai":
                url = "/TheLoaiServlet";
                break;
                
            case "GioHang":
                url = "/Subscription.jsp";
                break;
            case "TaiKhoan":
                url = "/TaiKhoan.jsp";
                break;
            case "TrangChu":
            default:
                url = "/index.jsp";
                break;
        }

        getServletContext().getRequestDispatcher(url).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        doGet(request, response);
    }
}
