package controller;

import java.io.IOException;

import javax.sql.DataSource;

import bussines.User;
import data.UserDB;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/RegisterSubcription")
public class RegisterSubcription extends HttpServlet {
    @Resource(name = "jdbc/MySQLDB")  // Inject DataSource từ JNDI
    private DataSource dataSource;
    double oneMonth = 9.99;
    double sixMonth = 49.99;
    double twelveMonth = 99.99;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String plan = req.getParameter("plan");
        
        String userIdStr = req.getParameter("userId"); 
        int userId = Integer.parseInt(userIdStr != null ? userIdStr : "1");  
        System.out.println(plan);
        System.out.println("Plan: " + plan + ", UserId: " + userId);

        try {
            // Sửa: Truyền dataSource vào constructor
            UserDB userDB = new UserDB(dataSource);
//            User user = userDB.getUserById(userId);
            User user = userDB.getUserById(1);

            if (user == null) {
                // Forward login nếu user không tồn tại
//                getServletContext().getRequestDispatcher("/login.jsp").forward(req, res);
            	getServletContext().getRequestDispatcher("/").forward(req, res);
                return;
            }

            double walletUser = user.getWallet();

            double planCost = 0;
            switch (plan) {
              case "oneMonth":
                planCost = oneMonth;
                break;
              case "sixMonth":
                planCost = sixMonth;
                break;
              case "twelveMonth":
                planCost = twelveMonth;
                break;
              default:
                planCost = 0;
            }


            
            if (walletUser >= planCost) {
                double newWallet = walletUser - planCost;
                userDB.updateWallet(newWallet, userId);
                user.setWallet(newWallet);
                req.setAttribute("message", "Subscription successful for plan: " + plan);
                req.setAttribute("message", "Cảm ơn bạn đã mua hàng thành công");
            	req.setAttribute("error", "");
                getServletContext().getRequestDispatcher("/Subscription.jsp").forward(req, res);  // Forward success page
            } else {
            	req.setAttribute("message", "");
            	req.setAttribute("error", "Ban Không Đủ Số Dư Để Thanh Toán, Vui Lòng Nạp Thêm");
                getServletContext().getRequestDispatcher("/Subscription.jsp").forward(req, res);
            }
        } catch (NumberFormatException e) {
            // Handle invalid userId
            System.out.println("Invalid userId: " + e.getMessage());
            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
        } catch (Exception e) {
            e.printStackTrace();
            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database or server error");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        // Xử lý GET nếu cần, ví dụ: hiển thị form subscription
        getServletContext().getRequestDispatcher("/subscriptionForm.jsp").forward(req, res);
    }

    // Helper method: Xác định cost của plan (có thể từ DB hoặc hardcode tạm)
    private int getPlanCost(String plan) {
        switch (plan != null ? plan.toLowerCase() : "") {
            case "basic": return 100;
            case "premium": return 500;
            default: return 0;
        }
    }
}
