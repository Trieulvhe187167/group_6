package controller;

import dal.BlogDAO;
import model.Blog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "BlogSearchServlet", urlPatterns = {"/BlogSearchServlet"})
public class BlogSearchServlet extends HttpServlet {
    
    private BlogDAO blogDAO = new BlogDAO();
    private static final int BLOGS_PER_PAGE = 3;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String query = request.getParameter("q");
        int page = 1;
        
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        List<Blog> allBlogs;
        
        if (query != null && !query.trim().isEmpty()) {
            // Search blogs
            allBlogs = blogDAO.searchBlogs(query.trim());
        } else {
            // Get all published blogs
            allBlogs = blogDAO.getPublishedBlogs();
        }
        
        // Pagination
        int totalBlogs = allBlogs.size();
        int totalPages = (int) Math.ceil((double) totalBlogs / BLOGS_PER_PAGE);
        
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;
        
        int start = (page - 1) * BLOGS_PER_PAGE;
        int end = Math.min(start + BLOGS_PER_PAGE, totalBlogs);
        
        List<Blog> blogs = allBlogs.subList(start, end);
        
        request.setAttribute("blogs", blogs);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("query", query);
        
        request.getRequestDispatcher("/jsp/blog.jsp").forward(request, response);
    }
}