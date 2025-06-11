package controller;

import dal.BlogDAO;
import model.Blog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "BlogDetailServlet", urlPatterns = {"/BlogDetailServlet"})
public class BlogDetailServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        String blogId = req.getParameter("id");
        String slug = req.getParameter("slug");
        
        BlogDAO blogDAO = new BlogDAO();
        Blog blog = null;
        
        // Get blog by id or slug
        if (blogId != null && !blogId.isEmpty()) {
            blog = blogDAO.getBlogById(blogId);
        } else if (slug != null && !slug.isEmpty()) {
            blog = blogDAO.getBlogBySlug(slug);
        }
        
        if (blog != null) {
            // Get recent posts for sidebar
            List<Blog> recentPosts = blogDAO.getRecentBlogs(5);
            
            req.setAttribute("blog", blog);
            req.setAttribute("recentPosts", recentPosts);
            req.getRequestDispatcher("/jsp/blogDetail.jsp").forward(req, resp);
        } else {
            // Blog not found
            resp.sendRedirect(req.getContextPath() + "/BlogListServlet");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}