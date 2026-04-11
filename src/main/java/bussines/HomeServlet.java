package bussines;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import bussines.User_login;
import data.UserDB;

@WebServlet("/HomeServlet") 
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null) action = "TrangChu";

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

            case "TaiKhoan": {
                HttpSession session = request.getSession(false);
                if (session == null || session.getAttribute("user") == null) {
                    response.sendRedirect(request.getContextPath() + "/auth/login");
                    return; 
                }

                User_login user = (User_login) session.getAttribute("user");

                boolean isPremium = false;
                try {
                    InitialContext ic = new InitialContext();
                    DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/loginDB");
                    UserDB userDB = new UserDB(ds);
                    isPremium = userDB.checkUserIsPremium((int) user.getId());
                } catch (NamingException e) {

                    e.printStackTrace();
                }

                request.setAttribute("isPremium", isPremium);
                user.setPremium(isPremium);
                session.setAttribute("user", user);

                url = "/TaiKhoan.jsp";  
                break;
            }

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
