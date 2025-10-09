package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.naming.Context;
import javax.naming.InitialContext;

import javax.sql.DataSource;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/testConnection")
public class test extends HttpServlet {
    private static final long serialVersionUID = 1L;
    @Resource(name = "jdbc/MySQLDB")
    private DataSource dataSource;

    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><body>");

        try {
            Context ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/MySQLDB");  // Tên từ context.xml
            Connection conn = ds.getConnection();
            
            // Test truy vấn đơn giản
            PreparedStatement ps = conn.prepareStatement("SELECT * from user");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                out.println("<p>Kết nối thành công! Giá trị test: " + rs.getInt(1) + "</p>");
            }
            rs.close();
            ps.close();
            conn.close();
        } catch (Exception e) {
            out.println("<p>Lỗi kết nối: " + e.getMessage() + "</p>");
            e.printStackTrace();  // Log lỗi chi tiết
        }

        out.println("</body></html>");
    }
}
