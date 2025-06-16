package dal;


import model.Comment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {
    
    /**
     * Get all comments for a specific blog
     */
    public List<Comment> getCommentsByBlogId(int blogId) {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT * FROM dbo.Comments WHERE BlogId = ? ORDER BY CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, blogId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Comment comment = new Comment();
                    comment.setId(rs.getInt("Id"));
                    comment.setBlogId(rs.getInt("BlogId"));
                    comment.setAuthorName(rs.getString("AuthorName"));
                    comment.setEmail(rs.getString("Email"));
                    comment.setContent(rs.getString("Content"));
                    comment.setStatus(rs.getString("Status"));
                    comment.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    comments.add(comment);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }
    
    /**
     * Get approved comments for a blog
     */
    public List<Comment> getApprovedComments(int blogId) {
        List<Comment> comments = new ArrayList<>();
        String sql = "SELECT * FROM dbo.Comments WHERE BlogId = ? AND Status = 'APPROVED' ORDER BY CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, blogId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Comment comment = new Comment();
                    comment.setId(rs.getInt("Id"));
                    comment.setBlogId(rs.getInt("BlogId"));
                    comment.setAuthorName(rs.getString("AuthorName"));
                    comment.setEmail(rs.getString("Email"));
                    comment.setContent(rs.getString("Content"));
                    comment.setStatus(rs.getString("Status"));
                    comment.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    comments.add(comment);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return comments;
    }
    
    /**
     * Add new comment
     */
    public boolean addComment(Comment comment) {
        String sql = "INSERT INTO dbo.Comments (BlogId, AuthorName, Email, Content, Status) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, comment.getBlogId());
            ps.setString(2, comment.getAuthorName());
            ps.setString(3, comment.getEmail());
            ps.setString(4, comment.getContent());
            ps.setString(5, comment.getStatus());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update comment status
     */
    public boolean updateCommentStatus(int commentId, String status) {
        String sql = "UPDATE dbo.Comments SET Status = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, commentId);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete comment
     */
    public boolean deleteComment(int commentId) {
        String sql = "DELETE FROM dbo.Comments WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, commentId);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}

