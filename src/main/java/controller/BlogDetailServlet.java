// Updated BlogDetailServlet.java with debugging and UTF-8 support
package controller;

import dal.BlogDAO;
import dal.CommentDAO;
import model.Blog;
import model.Comment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "BlogDetailServlet", urlPatterns = {"/BlogDetailServlet"})
public class BlogDetailServlet extends HttpServlet {
    
    private BlogDAO blogDAO = new BlogDAO();
    private CommentDAO commentDAO = new CommentDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Set encoding
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        
        String blogId = req.getParameter("id");
        String slug = req.getParameter("slug");
        String searchQuery = req.getParameter("q");
        String searchMode = req.getParameter("searchMode");
        
        // Debug logging
        System.out.println("BlogDetailServlet - Search Query: " + searchQuery);
        System.out.println("BlogDetailServlet - Search Mode: " + searchMode);
        
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
            
            // Get approved comments for this blog
            List<Comment> approvedComments = commentDAO.getApprovedComments(blog.getId());
            
            // Handle search if search mode is active
            if ("true".equals(searchMode) && searchQuery != null && !searchQuery.trim().isEmpty()) {
                System.out.println("Executing search for: " + searchQuery);
                
                List<Blog> searchResults = blogDAO.searchBlogs(searchQuery.trim());
                
                System.out.println("Search returned " + searchResults.size() + " results");
                
                // Limit to top 5 results for sidebar
                if (searchResults.size() > 5) {
                    searchResults = searchResults.subList(0, 5);
                }
                req.setAttribute("searchResults", searchResults);
            }
            
            req.setAttribute("blog", blog);
            req.setAttribute("recentPosts", recentPosts);
            req.setAttribute("approvedComments", approvedComments);
            
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