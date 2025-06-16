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
    public List<Blog> getAllBlogs(String search, String status, String authorId) {
    List<Blog> list = new ArrayList<>();
    StringBuilder sql = new StringBuilder(
        "SELECT b.Id, b.Title, b.Slug, b.Content, b.AuthorId, " +
        "b.CreatedAt, b.UpdatedAt, b.ImageUrl, b.Status, u.FullName AS AuthorName, " +
        "(SELECT COUNT(*) FROM dbo.Comments c WHERE c.BlogId = b.Id) AS CommentCount " +
        "FROM dbo.Blogs b " +
        "JOIN dbo.Users u ON b.AuthorId = u.Id " +
        "WHERE 1=1 "
    );
    
    List<Object> params = new ArrayList<>();
    
    // Add search condition
    if (search != null && !search.trim().isEmpty()) {
        sql.append("AND (b.Title LIKE ? OR b.Content LIKE ?) ");
        params.add("%" + search + "%");
        params.add("%" + search + "%");
    }
    
    // Add status condition
    if (status != null && !status.trim().isEmpty()) {
        sql.append("AND b.Status = ? ");
        params.add(status);
    }
    
    // Add author condition
    if (authorId != null && !authorId.trim().isEmpty()) {
        sql.append("AND b.AuthorId = ? ");
        params.add(Integer.parseInt(authorId));
    }
    
    sql.append("ORDER BY b.CreatedAt DESC");
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql.toString())) {
        
        // Set parameters
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
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
 * Check if slug exists (excluding a specific blog ID for update)
 */
public boolean isSlugExists(String slug, Integer excludeId) {
    String sql = "SELECT COUNT(*) FROM dbo.Blogs WHERE Slug = ?";
    if (excludeId != null) {
        sql += " AND Id != ?";
    }
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, slug);
        if (excludeId != null) {
            ps.setInt(2, excludeId);
        }
        
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return true; // Return true to be safe
}

/**
 * Get total number of blogs
 */
public int getTotalBlogs() {
    String sql = "SELECT COUNT(*) FROM dbo.Blogs WHERE Status != 'ARCHIVED'";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return 0;
}

/**
 * Get count of published blogs
 */
public int getPublishedCount() {
    String sql = "SELECT COUNT(*) FROM dbo.Blogs WHERE Status = 'PUBLISHED'";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return 0;
}

/**
 * Get count of draft blogs
 */
public int getDraftCount() {
    String sql = "SELECT COUNT(*) FROM dbo.Blogs WHERE Status = 'DRAFT'";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return 0;
}

/**
 * Get total comments count across all blogs
 */
public int getTotalComments() {
    String sql = "SELECT COUNT(*) FROM dbo.Comments";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        if (rs.next()) {
            return rs.getInt(1);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return 0;
}

public List<Blog> searchBlogs(String keyword) {
    List<Blog> list = new ArrayList<>();
    String sql = "SELECT b.Id, b.Title, b.Slug, b.Content, b.AuthorId, " +
                 "b.CreatedAt, b.UpdatedAt, b.ImageUrl, b.Status, u.FullName AS AuthorName, " +
                 "(SELECT COUNT(*) FROM dbo.Comments c WHERE c.BlogId = b.Id AND c.Status = 'APPROVED') AS CommentCount " +
                 "FROM dbo.Blogs b " +
                 "JOIN dbo.Users u ON b.AuthorId = u.Id " +
                 "WHERE b.Status = 'PUBLISHED' " +
                 "AND (LOWER(b.Title) LIKE LOWER(?) OR LOWER(b.Content) LIKE LOWER(?)) " +
                 "ORDER BY b.CreatedAt DESC";
                 
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        String searchPattern = "%" + keyword.trim() + "%";
        ps.setString(1, searchPattern);
        ps.setString(2, searchPattern);
        
        System.out.println("Search keyword: " + keyword);
        System.out.println("Search pattern: " + searchPattern);
        
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
        
        System.out.println("Found " + list.size() + " results");
        
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return list;
}

// Alternative method using COLLATE for better Unicode support
public List<Blog> searchBlogsWithCollation(String keyword) {
    List<Blog> list = new ArrayList<>();
    String sql = "SELECT b.Id, b.Title, b.Slug, b.Content, b.AuthorId, " +
                 "b.CreatedAt, b.UpdatedAt, b.ImageUrl, b.Status, u.FullName AS AuthorName, " +
                 "(SELECT COUNT(*) FROM dbo.Comments c WHERE c.BlogId = b.Id AND c.Status = 'APPROVED') AS CommentCount " +
                 "FROM dbo.Blogs b " +
                 "JOIN dbo.Users u ON b.AuthorId = u.Id " +
                 "WHERE b.Status = 'PUBLISHED' " +
                 "AND (b.Title COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI " +
                 "OR b.Content COLLATE Latin1_General_CI_AI LIKE ? COLLATE Latin1_General_CI_AI) " +
                 "ORDER BY b.CreatedAt DESC";
                 
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        String searchPattern = "%" + keyword.trim() + "%";
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
}