package controller;

import data.WatchlistDAO;
import bussines.Movie;
import bussines.User_login;
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

@WebServlet("/watchlist")
public class WatchlistServlet extends HttpServlet {

  @Resource(name = "jdbc/loginDB")
  private DataSource ds;

  private WatchlistDAO watchlistDAO;

  @Override
  public void init() throws ServletException {
    if (ds == null) throw new ServletException("DataSource jdbc/MySQLDB chưa cấu hình");
    watchlistDAO = new WatchlistDAO(ds);
  }

  private Integer requireUserIdOrRedirect(HttpServletRequest req, HttpServletResponse resp) throws IOException {
	    HttpSession session = req.getSession(false);
	    if (session != null) {

	        User_login u = (User_login) session.getAttribute("user");
	        if (u != null) {
	
	            return (int) u.getId();
	        }
	    }

	 
	    String redirectTo = req.getContextPath() + "/login?redirect=" + req.getRequestURI();
	    resp.sendRedirect(redirectTo);
	    return null;
	}


  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    
    String action = req.getParameter("action");
    if ("add".equals(action) || "remove".equals(action)) {
      doPost(req, resp);
      return;
    }
	  	  
    Integer userId = requireUserIdOrRedirect(req, resp);
    if (userId == null) return; 
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
    if (userId == null) return; 

    String action = req.getParameter("action");
    String vidRaw = req.getParameter("videoId");

    try {
      if ("add".equals(action)) {
        int videoId = Integer.parseInt(vidRaw);
        try {
          watchlistDAO.add(userId, videoId);
        } catch (SQLIntegrityConstraintViolationException dup) {

        }
      } else if ("remove".equals(action)) {
        int videoId = Integer.parseInt(vidRaw);
        watchlistDAO.remove(userId, videoId);
      }

      resp.sendRedirect(req.getContextPath() + "/watchlist");

    } catch (NumberFormatException nfe) {
      resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "videoId không hợp lệ");
    } catch (SQLException e) {
      throw new ServletException(e);
    }
  }
}
