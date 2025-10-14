package controller;

import data.TopUpDB;
import types.TopUpRequestTypes;
import bussines.TopUp;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import jakarta.annotation.Resource;
import javax.sql.DataSource;
import java.io.IOException;
import java.util.List;

@WebServlet("/AdminTopUpServlet")
public class AdminTopUpServlet extends HttpServlet {

	@Resource(name = "jdbc/MySQLDB")
	private DataSource ds;

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
		try {
			TopUpDB topUpDB = new TopUpDB(ds);
			switch (action) {
			case "ACCEPT":
			case "DISCARD": {
				int id = Integer.parseInt(request.getParameter("id"));
				TopUpRequestTypes st = TopUpRequestTypes.valueOf(action);
				boolean ok = topUpDB.updateStatusIfPending(id, st);
				String url = request.getContextPath() + "/AdminTopUpServlet";
				if (!ok) {
					response.sendRedirect(url + "?error=" + enc("Yêu cầu #" + id + " không còn pending"));
					return;
				}
				response.sendRedirect(
						url + "?message=" + enc((action.equals("ACCEPT") ? "Đã duyệt " : "Đã từ chối ") + "#" + id));
				return;
			}
			case "BulkAction": {
				TopUpRequestTypes st = TopUpRequestTypes.valueOf(request.getParameter("bulkType"));
				String[] ids = request.getParameterValues("ids");
				int ok = 0, fail = 0;
				if (ids != null) {
					for (String s : ids) {
						int id = Integer.parseInt(s);
						if (topUpDB.updateStatusIfPending(id, st))
							ok++;
						else
							fail++;
					}
				}
				response.sendRedirect(request.getContextPath() + "/AdminTopUpServlet?ok=" + ok + "&fail=" + fail);
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
