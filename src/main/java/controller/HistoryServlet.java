package controller;

import data.HistoryDAO;
import bussines.HistoryItem;
import bussines.User_login;
import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.RequestDispatcher;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/history")
public class HistoryServlet extends HttpServlet {
  private static final long serialVersionUID = 1L;

  @Resource(name = "jdbc/loginDB")
  private DataSource ds;

  private HistoryDAO historyDAO;

  @Override
  public void init() throws ServletException {
    if (ds == null) {

      throw new ServletException("DataSource jdbc/loginDB chưa được cấu hình hoặc sai tên JNDI.");
    }
    historyDAO = new HistoryDAO(ds);
  }

  private Integer requireUserIdOrRedirect(HttpServletRequest req, HttpServletResponse resp) throws IOException {
	    HttpSession session = req.getSession(false); // ❗ không tạo mới
	    if (session == null) {
	        String back = req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "");
	        resp.sendRedirect(req.getContextPath() + "/login?redirect=" +
	            URLEncoder.encode(back, StandardCharsets.UTF_8));
	        return null;
	    }

	    User_login u = (User_login) session.getAttribute("user");
	    if (u != null) {
	        return (int) u.getId(); 
	    }

	    Object uid = session.getAttribute("userId");
	    if (uid instanceof Integer) return (Integer) uid;
	    if (uid != null) {
	        try { return Integer.parseInt(uid.toString()); } catch (NumberFormatException ignore) {}
	    }

	    String back = req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "");
	    resp.sendRedirect(req.getContextPath() + "/login?redirect=" +
	        URLEncoder.encode(back, StandardCharsets.UTF_8));
	    return null;
	}


  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");

    Integer userId = requireUserIdOrRedirect(req, resp);
    if (userId == null) return; 

    try {
      List<HistoryItem> list = historyDAO.findByUser(userId);
      req.setAttribute("history", list);

      RequestDispatcher rd = req.getRequestDispatcher("/history.jsp");
      rd.forward(req, resp);
    } catch (SQLException e) {
      throw new ServletException(e);
    }
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");

    Integer userId = requireUserIdOrRedirect(req, resp);
    if (userId == null) return;

    String action = req.getParameter("action");
    if (action == null || action.isBlank()) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing action");
      return;
    }

    try {
      switch (action) {
        case "remove": {
          int id = Integer.parseInt(req.getParameter("id"));
          historyDAO.deleteByIdForUser(id, userId);
          resp.sendRedirect(req.getContextPath() + "/history");
          break;
        }
        case "saveProgress": {
          int videoId = Integer.parseInt(req.getParameter("videoId"));
          int progress = Integer.parseInt(req.getParameter("progressSeconds"));
          historyDAO.upsertProgress(userId, videoId, progress);
          resp.setStatus(HttpServletResponse.SC_NO_CONTENT); // 204
          break;
        }
        default:
          resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
      }
    } catch (NumberFormatException nfe) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid numeric parameter");
    } catch (Exception e) {
      throw new ServletException(e);
    }
  }
}
