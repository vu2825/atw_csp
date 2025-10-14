package controller;

import data.WatchlistDAO;
import bussines.Movie;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.RequestDispatcher;

import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.List;

@WebServlet("/WatchlistServlet")
public class WatchlistServlet extends HttpServlet {

  @Resource(name = "jdbc/loginDB")
  private DataSource ds;

  private WatchlistDAO watchlistDAO;

  @Override
  public void init() throws ServletException {
    if (ds == null) throw new ServletException("DataSource jdbc/MySQLDB chưa cấu hình");
    watchlistDAO = new WatchlistDAO(ds);
  }

  /** Lấy userId từ session; nếu chưa đăng nhập thì redirect sang /login và trả về null */
  private Integer requireUserIdOrRedirect(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    HttpSession session = req.getSession(false);
    Object uid = (session != null) ? session.getAttribute("userId") : null;
    if (uid instanceof Integer) return (Integer) uid;
   

    // Chưa đăng nhập -> chuyển đến /login?redirect=<path hiện tại>
    String redirectTo = req.getContextPath() + "/login?redirect=" + req.getRequestURI();
    resp.sendRedirect(redirectTo);
    return null;
  }

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
	 
	// 🧩 In ra console để check userId đang dùng
	  HttpSession session = req.getSession(false);
	  Object uid = (session != null) ? session.getAttribute("userId") : null;
	  System.out.println("🔍 WatchlistServlet: userId trong session = " + uid);
	  	  
    Integer userId = requireUserIdOrRedirect(req, resp);
    if (userId == null) return; // đã redirect
    try {
      List<Movie> watchlist = watchlistDAO.findByUser(userId);
      req.setAttribute("watchlist", watchlist);
      RequestDispatcher rd = req.getRequestDispatcher("/watchlist.jsp");
      rd.forward(req, resp);
    } catch (SQLException e) {
      throw new ServletException(e);
    }
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {

    Integer userId = requireUserIdOrRedirect(req, resp);
    if (userId == null) return; // đã redirect

    String action = req.getParameter("action");
    String vidRaw = req.getParameter("videoId");
    System.out.print(123);

    try {
      if ("add".equals(action)) {
        int videoId = Integer.parseInt(vidRaw);
        try {
          watchlistDAO.add(userId, videoId);
        } catch (SQLIntegrityConstraintViolationException dup) {
          // Nếu đã có UNIQUE(user_id, video_id) thì bỏ qua trùng cho mượt
        }
      } else if ("remove".equals(action)) {
        int videoId = Integer.parseInt(vidRaw);
        watchlistDAO.remove(userId, videoId);
      }
      // Quay lại trang watchlist sau thao tác
      resp.sendRedirect(req.getContextPath() + "/watchlist");

    } catch (NumberFormatException nfe) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "videoId không hợp lệ");
    } catch (SQLException e) {
      throw new ServletException(e);
    }
  }
}
