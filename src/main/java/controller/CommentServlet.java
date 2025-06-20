package controller;

import dal.CommentDAO;
import model.Comment;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "CommentServlet", urlPatterns = {"/CommentServlet"})
public class CommentServlet extends HttpServlet {
    
    private CommentDAO commentDAO = new CommentDAO();
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            addComment(request, response);
        } else if ("updateStatus".equals(action)) {
            updateCommentStatus(request, response);
        }
    }
    
    private void addComment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("user");
        
        String blogIdStr = request.getParameter("blogId");
        String content = request.getParameter("content");
        
        // Variables for non-logged in users
        String authorName = null;
        String email = null;
        
        // Check if user is logged in
        if (loggedInUser != null) {
            // User is logged in - use their info
            authorName = loggedInUser.getFullName();
            email = loggedInUser.getEmail();
        } else {
            // User is not logged in - get from form
            authorName = request.getParameter("authorName");
            email = request.getParameter("email");
        }
        
        // Validate input
        if (blogIdStr == null || content == null || content.trim().isEmpty() ||
            (loggedInUser == null && (authorName == null || authorName.trim().isEmpty() || 
             email == null || email.trim().isEmpty()))) {
            
            response.sendRedirect(request.getContextPath() + "/BlogDetailServlet?id=" + blogIdStr + "&error=1#respond");
            return;
        }
        
        // Validate email format for non-logged in users
        if (loggedInUser == null && !isValidEmail(email)) {
            response.sendRedirect(request.getContextPath() + "/BlogDetailServlet?id=" + blogIdStr + "&error=email#respond");
            return;
        }
        
        try {
            int blogId = Integer.parseInt(blogIdStr);
            
            Comment comment = new Comment();
            comment.setBlogId(blogId);
            comment.setAuthorName(authorName.trim());
            comment.setEmail(email.trim());
            comment.setContent(content.trim());
            
            // Set status based on login status
            if (loggedInUser != null) {
                comment.setStatus("APPROVED"); // Auto-approve for logged in users
            } else {
                comment.setStatus("PENDING"); // Require approval for non-logged in users
            }
            
            if (commentDAO.addComment(comment)) {
                if (loggedInUser != null) {
                    response.sendRedirect(request.getContextPath() + "/BlogDetailServlet?id=" + blogId + "&success=1#comments");
                } else {
                    response.sendRedirect(request.getContextPath() + "/BlogDetailServlet?id=" + blogId + "&success=2#comments");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/BlogDetailServlet?id=" + blogId + "&error=1#respond");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/BlogListServlet");
        }
    }
    
    private void updateCommentStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // This is for admin use
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || (!"ADMIN".equals(user.getRole()) && !"RECEPTIONIST".equals(user.getRole()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String commentIdStr = request.getParameter("commentId");
        String status = request.getParameter("status");
        String blogIdStr = request.getParameter("blogId");
        
        try {
            int commentId = Integer.parseInt(commentIdStr);
            
            if (commentDAO.updateCommentStatus(commentId, status)) {
                request.getSession().setAttribute("success", "Comment status updated successfully");
            } else {
                request.getSession().setAttribute("error", "Failed to update comment status");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/blogs?action=view&id=" + blogIdStr);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/blogs");
        }
    }
    
    // Helper method to validate email format
    private boolean isValidEmail(String email) {
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
        return email != null && email.matches(emailRegex);
    }
}