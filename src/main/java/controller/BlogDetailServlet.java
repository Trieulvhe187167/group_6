package controller;

import dal.BlogDAO;
import dal.CommentDAO;
import model.Blog;
import model.Comment;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
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
        
        try {
            String blogId = req.getParameter("id");
            String slug = req.getParameter("slug");
            String searchQuery = req.getParameter("q");
            String searchMode = req.getParameter("searchMode");
            
            // Debug logging
            System.out.println("BlogDetailServlet - Blog ID: " + blogId);
            System.out.println("BlogDetailServlet - Slug: " + slug);
            System.out.println("BlogDetailServlet - Search Query: " + searchQuery);
            System.out.println("BlogDetailServlet - Search Mode: " + searchMode);
            
            Blog blog = null;
            
            // Get blog by id or slug
            if (blogId != null && !blogId.isEmpty()) {
                try {
                    blog = blogDAO.getBlogById(blogId);
                    System.out.println("Blog found by ID: " + (blog != null ? blog.getTitle() : "null"));
                } catch (Exception e) {
                    System.err.println("Error getting blog by ID: " + e.getMessage());
                    e.printStackTrace();
                }
            } else if (slug != null && !slug.isEmpty()) {
                try {
                    blog = blogDAO.getBlogBySlug(slug);
                    System.out.println("Blog found by slug: " + (blog != null ? blog.getTitle() : "null"));
                } catch (Exception e) {
                    System.err.println("Error getting blog by slug: " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            if (blog != null) {
                // Get recent posts for sidebar
                List<Blog> recentPosts = new ArrayList<>();
                try {
                    recentPosts = blogDAO.getRecentBlogs(5);
                    System.out.println("Found " + recentPosts.size() + " recent posts");
                } catch (Exception e) {
                    System.err.println("Error getting recent posts: " + e.getMessage());
                    e.printStackTrace();
                }
                
                // Get approved comments for this blog
                List<Comment> approvedComments = new ArrayList<>();
                try {
                    approvedComments = commentDAO.getApprovedComments(blog.getId());
                    System.out.println("Found " + approvedComments.size() + " approved comments for blog " + blog.getId());
                } catch (Exception e) {
                    System.err.println("Error getting comments: " + e.getMessage());
                    e.printStackTrace();
                }
                
                // Handle search if search mode is active
                if ("true".equals(searchMode) && searchQuery != null && !searchQuery.trim().isEmpty()) {
                    try {
                        System.out.println("Executing search for: " + searchQuery);
                        
                        List<Blog> searchResults = blogDAO.searchBlogs(searchQuery.trim());
                        
                        System.out.println("Search returned " + searchResults.size() + " results");
                        
                        // Limit to top 5 results for sidebar
                        if (searchResults.size() > 5) {
                            searchResults = searchResults.subList(0, 5);
                        }
                        req.setAttribute("searchResults", searchResults);
                    } catch (Exception e) {
                        System.err.println("Error searching blogs: " + e.getMessage());
                        e.printStackTrace();
                    }
                }
                
                // Check if user is logged in
                HttpSession session = req.getSession();
                User loggedInUser = (User) session.getAttribute("user");
                
                req.setAttribute("blog", blog);
                req.setAttribute("recentPosts", recentPosts);
                req.setAttribute("approvedComments", approvedComments);
                req.setAttribute("isLoggedIn", loggedInUser != null);
                
                req.getRequestDispatcher("/jsp/blogDetail.jsp").forward(req, resp);
            } else {
                // Blog not found
                System.out.println("Blog not found - redirecting to blog list");
                resp.sendRedirect(req.getContextPath() + "/BlogListServlet");
            }
        } catch (Exception e) {
            System.err.println("Fatal error in BlogDetailServlet: " + e.getMessage());
            e.printStackTrace();
            
            // Try to show error page
            req.setAttribute("errorMessage", "An error occurred while loading the blog: " + e.getMessage());
            req.getRequestDispatcher("/jsp/error.jsp").forward(req, resp);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}