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

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String plan = req.getParameter("plan");
        String userIdStr = req.getParameter("userId");  // Lấy userId từ form/param
        int userId = Integer.parseInt(userIdStr != null ? userIdStr : "1");  // Default 1 nếu null, nhưng tốt hơn validate

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

            int walletUser = user.getWallet();  // Giả sử User có getWallet()
            System.out.println("Wallet: " + walletUser);

            // Logic subscription cơ bản (ví dụ: check wallet đủ cho plan)
            int planCost = getPlanCost(plan);  // Implement method này, ví dụ dựa trên plan
            if (walletUser >= planCost) {
                // Update wallet: trừ cost
                int newWallet = walletUser - planCost;
                userDB.updateWallet(userId, newWallet);
                user.setWallet(newWallet);
                req.setAttribute("message", "Subscription successful for plan: " + plan);
                getServletContext().getRequestDispatcher("/success.jsp").forward(req, res);  // Forward success page
            } else {
                req.setAttribute("error", "Insufficient wallet for plan: " + plan);
                getServletContext().getRequestDispatcher("/error.jsp").forward(req, res);
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
