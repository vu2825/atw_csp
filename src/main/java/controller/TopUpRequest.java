package controller;

import java.io.IOException;
import java.util.List;

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
	@Resource(name = "jdbc/loginDB")
	private DataSource dataSource;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		int userId = 3; // TODO: get from session/auth
		try {
			UserDB userDB = new UserDB(dataSource);
			List<service.TopUpRequest> topups = userDB.findAllTopupsOfUser(userId);
			
			req.setAttribute("topups", topups) ;

			String msg = req.getParameter("message");
			if (msg != null && !msg.isEmpty()) {
				req.setAttribute("message", msg);
			}

			getServletContext().getRequestDispatcher("/AddCreditUser.jsp").forward(req, res);
		} catch (Exception e) {
			e.printStackTrace();
			res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database or server error");
		}
	}

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

				int userId = 3; // TODO: from session/auth
				UserDB userDB = new UserDB(dataSource);
				userDB.sendAddCredit(amount, userId);

				// PRG: redirect to GET so JSP loads fresh data
				res.sendRedirect(req.getContextPath() + "/TopUpRequest?message="
						+ java.net.URLEncoder.encode("Send Request Successfully !", "UTF-8"));
				return;
			} catch (NumberFormatException e) {
				res.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid amount");
				return;
			} catch (Exception e) {
				e.printStackTrace();
				res.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database or server error");
				return;
			}
		}

		// Default: show page via GET
		res.sendRedirect(req.getContextPath() + "/TopUpRequest");
	}

}
