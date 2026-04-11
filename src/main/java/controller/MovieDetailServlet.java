package controller;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import bussines.Movie;
import bussines.User_login;
import dao.RatingDao;
import data.UserDB;

@WebServlet("/movie-detail")
public class MovieDetailServlet extends HttpServlet {


    @Resource(lookup = "java:comp/env/jdbc/loginDB")
    private DataSource injected;

    private DataSource ds;

    @Override
    public void init() throws ServletException {

        if (injected != null) {
            ds = injected;
            return;
        }
        try {
            ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/loginDB");
        } catch (NamingException e) {
            throw new ServletException("Không tìm thấy JNDI DataSource: java:comp/env/jdbc/loginDB", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
 
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        User_login user = (User_login) session.getAttribute("user");

        try {
            int movieId = Integer.parseInt(req.getParameter("id"));
            Movie movie = getMovieById(movieId);
            if (movie == null) {
                resp.sendError(404, "Movie not found");
                return;
            }

            boolean isInWatchlist = checkIfInWatchlist((int) user.getId(), movieId);
            req.setAttribute("isInWatchlist", isInWatchlist);

            RatingDao rdao = new RatingDao();
            req.setAttribute("summary", rdao.summary(String.valueOf(movieId)));
            req.setAttribute("reviews", rdao.listByVideoId(movieId));

            UserDB userDB = new UserDB(ds);

            boolean isUserPremium = userDB.checkUserIsPremium((int) user.getId());
            boolean notPremium = !isUserPremium;

            String ctx = req.getContextPath();
            String watchUrl360 = ctx + "/watch?id=" + movieId + "&quality=360";
            String watchUrl480 = ctx + "/watch?id=" + movieId + "&quality=" + (notPremium ? "360" : "480");

            req.setAttribute("movie", movie);
            req.setAttribute("notPremium", notPremium);
            req.setAttribute("watchUrl360", watchUrl360);
            req.setAttribute("watchUrl480", watchUrl480);
            if (notPremium) {
                req.setAttribute("qualityMessage", "🔒 Cần nâng cấp tài khoản Premium để xem chất lượng 480P");
            }

            req.getRequestDispatcher("/movie-detail.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(400, "Invalid movie ID");
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(500, "Database error");
        } catch (Exception e) {

            throw new ServletException(e);
        }
    }

    private boolean checkIfInWatchlist(int userId, int movieId) throws SQLException {
        final String sql = "SELECT COUNT(*) FROM thanh_toan.watchlist WHERE user_id = ? AND video_id = ?";
        try (Connection cn = ds.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private Movie getMovieById(int movieId) throws SQLException {
        final String sql = """
            SELECT id, title, genre, duration, url_video_360P, url_video_480P, poster_url
            FROM videos WHERE id = ?
        """;
        try (Connection cn = ds.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                Movie m = new Movie();
                m.setId(rs.getInt("id"));
                m.setTitle(rs.getString("title"));
                m.setGenre(rs.getString("genre")); 
                m.setDuration(rs.getString("duration"));
                m.setSrc(rs.getString("url_video_360P"));
                m.setPoster(rs.getString("poster_url"));
                return m;
            }
        }
    }
}
