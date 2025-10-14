package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import com.google.gson.Gson;
import bussines.Video;
import data.VideoDB;

@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String query = req.getParameter("query");

        if ("suggest".equals(action)) {
            List<String> suggestions = VideoDB.getSuggestions(query);
            resp.setContentType("application/json; charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");
            System.out.println("🎯 Gợi ý trả về từ Servlet: " + suggestions); // Debug log
            new Gson().toJson(suggestions, resp.getWriter());
        } else {
            List<Video> results = VideoDB.searchVideos(query);
            req.setAttribute("query", query);
            req.setAttribute("results", results);
            req.getRequestDispatcher("/search_result.jsp").forward(req, resp);
        }
    }
}
