package controller;

import dal.BlogDAO;
import model.Blog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "BlogListServlet", urlPatterns = {"/BlogListServlet"})
public class BlogListServlet extends HttpServlet {
    
    private BlogDAO blogDAO = new BlogDAO();
    private static final int BLOGS_PER_PAGE = 3;
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        int page = 1;
        
        try {
            String pageStr = req.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        // Get all published blogs
        List<Blog> allBlogs = blogDAO.getPublishedBlogs();
        
        // Pagination
        int totalBlogs = allBlogs.size();
        int totalPages = (int) Math.ceil((double) totalBlogs / BLOGS_PER_PAGE);
        
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;
        
        int start = (page - 1) * BLOGS_PER_PAGE;
        int end = Math.min(start + BLOGS_PER_PAGE, totalBlogs);
        
        List<Blog> blogs = allBlogs.subList(start, end);
        
        req.setAttribute("blogs", blogs);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        
        req.getRequestDispatcher("/jsp/blog.jsp").forward(req, resp);
    }
}