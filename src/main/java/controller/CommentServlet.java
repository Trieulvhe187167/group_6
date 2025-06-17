package controller;

import dal.CommentDAO;
import model.Comment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

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
        
        String blogIdStr = request.getParameter("blogId");
        String authorName = request.getParameter("authorName");
        String email = request.getParameter("email");
        String content = request.getParameter("content");
        
        // Validate input
        if (blogIdStr == null || authorName == null || email == null || content == null ||
            authorName.trim().isEmpty() || email.trim().isEmpty() || content.trim().isEmpty()) {
            
            response.sendRedirect(request.getContextPath() + "/BlogDetailServlet?id=" + blogIdStr + "&error=1");
            return;
        }
        
        try {
            int blogId = Integer.parseInt(blogIdStr);
            
            Comment comment = new Comment();
            comment.setBlogId(blogId);
            comment.setAuthorName(authorName.trim());
            comment.setEmail(email.trim());
            comment.setContent(content.trim());
            comment.setStatus("PENDING"); // Comments need approval
            
            if (commentDAO.addComment(comment)) {
                response.sendRedirect(request.getContextPath() + "/BlogDetailServlet?id=" + blogId + "&success=1#comments");
            } else {
                response.sendRedirect(request.getContextPath() + "/BlogDetailServlet?id=" + blogId + "&error=1");
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
}