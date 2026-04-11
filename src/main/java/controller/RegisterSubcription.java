package controller;

import java.io.IOException;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

import javax.sql.DataSource;

import bussines.User;
import bussines.User_login;
import data.UserDB;
import data.UsersSubscriptionDB;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import service.UsersSubscription;
import types.SubscriptionStatus;

@WebServlet("/RegisterSubscription")
public class RegisterSubcription extends HttpServlet {
    @Resource(name = "jdbc/loginDB") 
	private DataSource dataSource;
	double oneMonth = 9.99;
	double sixMonth = 49.99;
	double twelveMonth = 99.99;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		HttpSession session = req.getSession();
		String plan = req.getParameter("plan");

		User_login u = (User_login) session.getAttribute("user");
		int userId = (int) u.getId();
		System.out.println("Plan: " + plan + ", UserId: " + userId);

		try {
			UserDB userDB = new UserDB(dataSource);

			User user = userDB.getUserById(userId);

			if (user == null) {

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

			if(usersSubscriptionDB.checkSubscriptionUser(userId)) {
				req.setAttribute("messageUser", "");
				req.setAttribute("errorUser", "Bạn Đã Đăng Ký Trước Đó, Vui Lòng Đợi Đăng Ký Hết HIệu Lực");
				getServletContext().getRequestDispatcher("/Subscription.jsp").forward(req, res);
			}
			else if (walletUser >= planCost) {
				double newWallet = walletUser - planCost;
				userDB.updateWallet(newWallet, userId);
				user.setWallet(newWallet);
				req.setAttribute("messageUser", "Cảm ơn bạn đã mua hàng thành công");
				req.setAttribute("errorUser", "");

				UsersSubscription us = new UsersSubscription();

				us.setId(user.getId()); 

				us.setUser_id(userId);
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

				us.setStarted_at(Date.from(now.atZone(ZoneId.systemDefault()).toInstant()));
				us.setExpires_at(Date.from(exp.atZone(ZoneId.systemDefault()).toInstant()));
				
				us.setStatus(SubscriptionStatus.fromDb("active"));
				
				usersSubscriptionDB.addSubscription(us);
				
				getServletContext().getRequestDispatcher("/Subscription.jsp").forward(req, res); // Forward success page
			} 
			else {
				req.setAttribute("messageUser", "");
				req.setAttribute("errorUser", "Ban Không Đủ Số Dư Để Thanh Toán, Vui Lòng Nạp Thêm");
				getServletContext().getRequestDispatcher("/Subscription.jsp").forward(req, res);
			}
		} catch (NumberFormatException e) {

			System.out.println("Invalid userId: " + e.getMessage());
			res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
		} catch (Exception e) {
			e.printStackTrace();
			res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database or server error");
		}
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		doPost(req, res);
	}
}
