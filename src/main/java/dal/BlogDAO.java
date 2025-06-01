package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Blog;

/**
 * DAO cho bảng Blogs
 */
public class BlogDAO {
    
    /**
     * Lấy danh sách bài blog đã xuất bản (status = 'PUBLISHED') với comment count
     */
    public List<Blog> getPublishedBlogs() {
        List<Blog> list = new ArrayList<>();
        String sql = "SELECT b.Id, b.Title, b.Slug, b.Content, b.AuthorId, " +
                     "b.CreatedAt, b.UpdatedAt, b.ImageUrl, b.Status, u.FullName AS AuthorName, " +
                     "(SELECT COUNT(*) FROM dbo.Comments c WHERE c.BlogId = b.Id AND c.Status = 'APPROVED') AS CommentCount " +
                     "FROM dbo.Blogs b " +
                     "JOIN dbo.Users u ON b.AuthorId = u.Id " +
                     "WHERE b.Status = 'PUBLISHED' " +
                     "ORDER BY b.CreatedAt DESC";
                     
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Blog blog = new Blog();
                blog.setId(rs.getInt("Id"));
                blog.setTitle(rs.getString("Title"));
                blog.setSlug(rs.getString("Slug"));
                blog.setContent(rs.getString("Content"));
                blog.setAuthorId(rs.getInt("AuthorId"));
                blog.setAuthorName(rs.getString("AuthorName"));
                blog.setCreatedAt(rs.getTimestamp("CreatedAt"));
                blog.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                blog.setImageUrl(rs.getString("ImageUrl"));
                blog.setStatus(rs.getString("Status"));
                blog.setCommentCount(rs.getInt("CommentCount"));
                list.add(blog);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy chi tiết 1 bài blog theo slug (URL identifier)
     */
    public Blog getBlogBySlug(String slug) {
        String sql = "SELECT b.Id, b.Title, b.Slug, b.Content, b.AuthorId, " +
                     "b.CreatedAt, b.UpdatedAt, b.ImageUrl, b.Status, u.FullName AS AuthorName, " +
                     "(SELECT COUNT(*) FROM dbo.Comments c WHERE c.BlogId = b.Id AND c.Status = 'APPROVED') AS CommentCount " +
                     "FROM dbo.Blogs b " +
                     "JOIN dbo.Users u ON b.AuthorId = u.Id " +
                     "WHERE b.Slug = ? AND b.Status = 'PUBLISHED'";
                     
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, slug);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Blog blog = new Blog();
                    blog.setId(rs.getInt("Id"));
                    blog.setTitle(rs.getString("Title"));
                    blog.setSlug(rs.getString("Slug"));
                    blog.setContent(rs.getString("Content"));
                    blog.setAuthorId(rs.getInt("AuthorId"));
                    blog.setAuthorName(rs.getString("AuthorName"));
                    blog.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    blog.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    blog.setImageUrl(rs.getString("ImageUrl"));
                    blog.setStatus(rs.getString("Status"));
                    blog.setCommentCount(rs.getInt("CommentCount"));
                    return blog;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy chi tiết Blog theo ID
     */
    public Blog getBlogById(String id) {
        String sql = "SELECT b.Id, b.Title, b.Slug, b.Content, b.AuthorId, " +
                     "b.CreatedAt, b.UpdatedAt, b.ImageUrl, b.Status, u.FullName AS AuthorName, " +
                     "(SELECT COUNT(*) FROM dbo.Comments c WHERE c.BlogId = b.Id AND c.Status = 'APPROVED') AS CommentCount " +
                     "FROM dbo.Blogs b " +
                     "JOIN dbo.Users u ON b.AuthorId = u.Id " +
                     "WHERE b.Id = ?";
                     
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, Integer.parseInt(id));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Blog blog = new Blog();
                    blog.setId(rs.getInt("Id"));
                    blog.setTitle(rs.getString("Title"));
                    blog.setSlug(rs.getString("Slug"));
                    blog.setContent(rs.getString("Content"));
                    blog.setAuthorId(rs.getInt("AuthorId"));
                    blog.setAuthorName(rs.getString("AuthorName"));
                    blog.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    blog.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    blog.setImageUrl(rs.getString("ImageUrl"));
                    blog.setStatus(rs.getString("Status"));
                    blog.setCommentCount(rs.getInt("CommentCount"));
                    return blog;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Lấy n bài blog mới nhất đã xuất bản
     * @param limit số lượng blog muốn lấy
     * @return danh sách blog
     */
    public List<Blog> getRecentBlogs(int limit) {
        List<Blog> list = new ArrayList<>();
        String sql = "SELECT TOP (?) b.Id, b.Title, b.Slug, b.Content, b.AuthorId, " +
                     "b.CreatedAt, b.UpdatedAt, b.ImageUrl, b.Status, u.FullName AS AuthorName, " +
                     "(SELECT COUNT(*) FROM dbo.Comments c WHERE c.BlogId = b.Id AND c.Status = 'APPROVED') AS CommentCount " +
                     "FROM dbo.Blogs b " +
                     "JOIN dbo.Users u ON b.AuthorId = u.Id " +
                     "WHERE b.Status = 'PUBLISHED' " +
                     "ORDER BY b.CreatedAt DESC";
                     
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Blog blog = new Blog();
                    blog.setId(rs.getInt("Id"));
                    blog.setTitle(rs.getString("Title"));
                    blog.setSlug(rs.getString("Slug"));
                    blog.setContent(rs.getString("Content"));
                    blog.setAuthorId(rs.getInt("AuthorId"));
                    blog.setAuthorName(rs.getString("AuthorName"));
                    blog.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    blog.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    blog.setImageUrl(rs.getString("ImageUrl"));
                    blog.setStatus(rs.getString("Status"));
                    blog.setCommentCount(rs.getInt("CommentCount"));
                    list.add(blog);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Tìm kiếm blog theo từ khóa
     * @param keyword từ khóa tìm kiếm
     * @return danh sách blog
     */
    public List<Blog> searchBlogs(String keyword) {
        List<Blog> list = new ArrayList<>();
        String sql = "SELECT b.Id, b.Title, b.Slug, b.Content, b.AuthorId, " +
                     "b.CreatedAt, b.UpdatedAt, b.ImageUrl, b.Status, u.FullName AS AuthorName, " +
                     "(SELECT COUNT(*) FROM dbo.Comments c WHERE c.BlogId = b.Id AND c.Status = 'APPROVED') AS CommentCount " +
                     "FROM dbo.Blogs b " +
                     "JOIN dbo.Users u ON b.AuthorId = u.Id " +
                     "WHERE b.Status = 'PUBLISHED' " +
                     "AND (b.Title LIKE ? OR b.Content LIKE ?) " +
                     "ORDER BY b.CreatedAt DESC";
                     
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Blog blog = new Blog();
                    blog.setId(rs.getInt("Id"));
                    blog.setTitle(rs.getString("Title"));
                    blog.setSlug(rs.getString("Slug"));
                    blog.setContent(rs.getString("Content"));
                    blog.setAuthorId(rs.getInt("AuthorId"));
                    blog.setAuthorName(rs.getString("AuthorName"));
                    blog.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    blog.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    blog.setImageUrl(rs.getString("ImageUrl"));
                    blog.setStatus(rs.getString("Status"));
                    blog.setCommentCount(rs.getInt("CommentCount"));
                    list.add(blog);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /**
     * Thêm blog mới
     * @param blog đối tượng blog cần thêm
     * @return true nếu thêm thành công
     */
    public boolean insertBlog(Blog blog) {
        String sql = "INSERT INTO dbo.Blogs (Title, Slug, Content, AuthorId, Status, ImageUrl) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
                     
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, blog.getTitle());
            ps.setString(2, blog.getSlug());
            ps.setString(3, blog.getContent());
            ps.setInt(4, blog.getAuthorId());
            ps.setString(5, blog.getStatus());
            ps.setString(6, blog.getImageUrl());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Cập nhật blog
     * @param blog đối tượng blog cần cập nhật
     * @return true nếu cập nhật thành công
     */
    public boolean updateBlog(Blog blog) {
        String sql = "UPDATE dbo.Blogs SET Title = ?, Slug = ?, Content = ?, " +
                     "Status = ?, ImageUrl = ? WHERE Id = ?";
                     
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, blog.getTitle());
            ps.setString(2, blog.getSlug());
            ps.setString(3, blog.getContent());
            ps.setString(4, blog.getStatus());
            ps.setString(5, blog.getImageUrl());
            ps.setInt(6, blog.getId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Xóa blog (soft delete - chuyển status thành ARCHIVED)
     * @param id ID của blog cần xóa
     * @return true nếu xóa thành công
     */
    public boolean deleteBlog(int id) {
        String sql = "UPDATE dbo.Blogs SET Status = 'ARCHIVED' WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}