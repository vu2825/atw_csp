package bussines;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

//anotation
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException ,ServletException{
        String action = request.getParameter("action");
        
        String url = "/index.jsp";
        if (action.equals("PhimBo")){
            url="/PhimBo.jsp";
        }
        if (action.equals("PhimLe")){
            url="/PhimLe.jsp";
        }
        if (action.equals("QuocGia")){
            url="/QuocGia.jsp";
        }
        if (action.equals("GioHang")){
            url="/GioHang.jsp";
        }
        if (action.equals("TaiKhoan")){
            url="/TaiKhoan.jsp";
        }
        
        getServletContext().getRequestDispatcher(url).forward(request,response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws  IOException ,ServletException{
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}