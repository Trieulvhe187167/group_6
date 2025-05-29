package controller;

import dal.BlogDAO;
import model.Blog;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name="BlogDetailServlet", urlPatterns={"/BlogDetailServlet"})
public class BlogDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String slug = req.getParameter("slug");
        if (slug == null || slug.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing slug");
            return;
        }
        Blog b = new BlogDAO().getBlogBySlug(slug);
        if (b == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Blog not found");
            return;
        }
        req.setAttribute("blog", b);
        // Nếu cần recent posts sidebar
        req.setAttribute("recentPosts", new BlogDAO().getPublishedBlogs().subList(0, 5));
        req.getRequestDispatcher("/jsp/blogDetail.jsp").forward(req, resp);
    }
}
