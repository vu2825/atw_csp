package controller;

import java.io.IOException;

import javax.sql.DataSource;

import data.UserDB;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/TopUpRequest")
public class TopUpRequest extends HttpServlet {
	@Resource(name = "jdbc/MySQLDB")
	private DataSource dataSource;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
	    String action = req.getParameter("action");
	    String amountStr = req.getParameter("amount");

	    if ("AddCredit".equals(action)) {
	        try {
	            double amount = Double.parseDouble(amountStr);
	            if (amount <= 0d) {
	                res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Amount must be > 0");
	                return;
	            }

	            UserDB userDB = new UserDB(dataSource);
	            userDB.sendAddCredit(amount, 1);

	            // PRG: tránh double submit
	            res.sendRedirect(req.getContextPath() + "/AddCreditUser.jsp?message=Send+Add+Credit+Successfully!");
	            return; // rất quan trọng để không chạy tiếp
	        } catch (NumberFormatException e) {
	            res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid amount");
	            return;
	        } catch (Exception e) {
	            e.printStackTrace();
	            res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database or server error");
	            return;
	        }
	    }

	    // Mặc định điều hướng trang chủ (GET)
	    res.sendRedirect(req.getContextPath() + "/");
	}


	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doPost(req, res);
	}

}
