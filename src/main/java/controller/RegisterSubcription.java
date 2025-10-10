package controller;

import java.io.IOException;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

import javax.sql.DataSource;

import bussines.User;
import bussines.UsersSubscription;
import data.UserDB;
import data.UsersSubscriptionDB;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import types.SubscriptionStatus;

@WebServlet("/RegisterSubcription")
public class RegisterSubcription extends HttpServlet {
	@Resource(name = "jdbc/MySQLDB") // Inject DataSource từ JNDI
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
			
			UsersSubscriptionDB usersSubscriptionDB = new UsersSubscriptionDB(dataSource);

			if(usersSubscriptionDB.checkSubscriptionUser(user.id)) {
				req.setAttribute("message", "");
				req.setAttribute("error", "Bạn Đã Đăng Ký Trước Đó, Vui Lòng Đợi Đăng Ký Hết HIệu Lực");
				getServletContext().getRequestDispatcher("/Subscription.jsp").forward(req, res);
			}
			else if (walletUser >= planCost) {
				double newWallet = walletUser - planCost;
				userDB.updateWallet(newWallet, userId);
				user.setWallet(newWallet);
				req.setAttribute("message", "Subscription successful for plan: " + plan);
				req.setAttribute("message", "Cảm ơn bạn đã mua hàng thành công");
				req.setAttribute("error", "");

				// created UserSubscription to added table user_subscription
				UsersSubscription us = new UsersSubscription();

				us.setId(user.id); // didn't use but must have value

				us.setUser_id(user.id);
				us.setPlan(plan);
				us.setPrice(planCost);

				int months = 0;

				switch (plan) {
				case "oneMonth":
					months = 1;
					break;
				case "sixMonth":
					months = 6;
					break;
				case "twelveMonth":
					months = 12;
					break;
				}

				LocalDateTime now = LocalDateTime.now();
				LocalDateTime exp = months > 0 ? now.plusMonths(months) : now;

				// if UsersSubscription.started_at / expires_at are java.util.Date
				us.setStarted_at(Date.from(now.atZone(ZoneId.systemDefault()).toInstant()));
				us.setExpires_at(Date.from(exp.atZone(ZoneId.systemDefault()).toInstant()));
				
				us.setStatus(SubscriptionStatus.fromDb("active"));
				
				usersSubscriptionDB.addSubscription(us);

				getServletContext().getRequestDispatcher("/Subscription.jsp").forward(req, res); // Forward success page
			} 
			else {
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
		doPost(req, res);
	}
}
