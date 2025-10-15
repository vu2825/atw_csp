package controller;

import data.TopUpDB;
import data.UserDB;
import types.TopUpRequestTypes;
import bussines.TopUp;
import bussines.User;
import bussines.User_login;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import jakarta.annotation.Resource;
import javax.sql.DataSource;
import java.io.IOException;
import java.util.List;

@WebServlet("/AdminTopUpServlet")
public class AdminTopUpServlet extends HttpServlet {

	@Resource(name = "jdbc/loginDB")
	private DataSource ds;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession(false);
		User_login u = (User_login) session.getAttribute("user");
		if(!u.isAdmin()) {
			getServletContext().getRequestDispatcher("/").forward(req, resp);
		};
		
		try {
			TopUpDB topUpDB = new TopUpDB(ds);
			String status = req.getParameter("status"); // PENDING | ACCEPT | DISCARD | null
			String q = req.getParameter("q"); // id hoặc userId (số) hoặc trống
			List<TopUp> topups = topUpDB.search(status, q); // triển khai dưới DAO
			req.setAttribute("topups", topups);
			getServletContext().getRequestDispatcher("/ManageRequestCredit.jsp").forward(req, resp);
		} catch (Exception e) {
			e.printStackTrace();
			resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Load failed");
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String action = request.getParameter("action");
		HttpSession session = request.getSession(false);
		User_login u = (User_login) session.getAttribute("user");
		if(!u.isAdmin()) {
			System.out.print(u.isAdmin());
			getServletContext().getRequestDispatcher("/").forward(request, response);
		};
		try {
			switch (action) {
			case "ACCEPT":
			case "DISCARD": {
				int topupId = Integer.parseInt(request.getParameter("id"));
				TopUpRequestTypes st = TopUpRequestTypes.valueOf(action);

				// 1) Lấy topup để biết userId & amount
				TopUp topup = new TopUpDB(ds).getById(topupId);
				if (topup == null) {
					response.sendRedirect(request.getContextPath() + "/AdminTopUpServlet?error="
							+ enc("Không tìm thấy yêu cầu #" + topupId));
					return;
				}

				// 2) Cập nhật trạng thái nếu còn pending
				boolean ok = new TopUpDB(ds).updateStatusIfPending(topupId, st);
				if (!ok) {
					response.sendRedirect(request.getContextPath() + "/AdminTopUpServlet?error="
							+ enc("Yêu cầu #" + topupId + " không còn pending"));
					return;
				}

				// 3) Nếu ACCEPT thì cộng ví bằng updateWallet
				if (st == TopUpRequestTypes.ACCEPT) {
					UserDB userDB = new UserDB(ds);
					User user = userDB.getUserById(topup.getUserId());
					if (user == null) {
						response.sendRedirect(request.getContextPath() + "/AdminTopUpServlet?error="
								+ enc("Không tìm thấy user #" + topup.getUserId()));
						return;
					}
					double newWallet = user.getWallet() + topup.getAmount();
					userDB.updateWallet(newWallet, user.getId());
				}

				// 4) PRG
				String msg = (st == TopUpRequestTypes.ACCEPT ? "Đã duyệt " : "Đã từ chối ") + "#" + topupId;
				response.sendRedirect(request.getContextPath() + "/AdminTopUpServlet?message=" + enc(msg));
				return;
			}

			default:
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
			}
		} catch (Exception e) {
			e.printStackTrace();
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Update failed");
		}
	}
	private static String enc(String s) {
		return java.net.URLEncoder.encode(s, java.nio.charset.StandardCharsets.UTF_8);
	}

}