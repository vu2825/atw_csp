package controller;

import bussines.Video;
import data.VideoDB;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/TheLoaiServlet")
public class TheLoaiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String genre = request.getParameter("genre");
        List<String> genres = VideoDB.getAllGenres();
        List<Video> videos;

        if (genre != null && !genre.isEmpty()) {
            videos = VideoDB.getVideosByGenre(genre);
            request.setAttribute("selectedGenre", genre);
        } else {
            videos = VideoDB.getAllVideos();
        }

        request.setAttribute("genres", genres);
        request.setAttribute("videos", videos);

        RequestDispatcher rd = request.getRequestDispatcher("TheLoai.jsp");
        rd.forward(request, response);
    }
}
