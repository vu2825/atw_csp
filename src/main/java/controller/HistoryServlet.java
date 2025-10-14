package controller;

import data.HistoryDAO;
import bussines.HistoryItem;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.RequestDispatcher;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
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
      throw new ServletException("DataSource jdbc/MySQLDB chưa được cấu hình hoặc sai tên JNDI.");
    }
    historyDAO = new HistoryDAO(ds);
  }

  private int getUserId(HttpServletRequest req){
    HttpSession s = req.getSession(true);
    Object uid = s.getAttribute("userId");
    if (uid == null) { 
      s.setAttribute("userId", 1); 
      return 1; 
    }
    if (uid instanceof Integer) return (Integer) uid;
    try { 
      return Integer.parseInt(String.valueOf(uid)); 
    } catch (Exception e) { 
      return 1; 
    }
  }

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");    // (tùy chọn)
    int userId = getUserId(req);
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
    String action = req.getParameter("action");
    int userId = getUserId(req);

    if (action == null || action.isBlank()) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing action");
      return;
    }

    try {
      switch (action) {
        case "remove": {
          String idStr = req.getParameter("id");
          int id = Integer.parseInt(idStr);
          historyDAO.deleteByIdForUser(id, userId);
          // PRG
          resp.sendRedirect(req.getContextPath() + "/history");
          break;
        }
        case "saveProgress": {
          String vStr = req.getParameter("videoId");
          String pStr = req.getParameter("progressSeconds");
          int videoId = Integer.parseInt(vStr);
          int progress = Integer.parseInt(pStr);
          historyDAO.upsertProgress(userId, videoId, progress);
          resp.setContentType("application/json");
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
