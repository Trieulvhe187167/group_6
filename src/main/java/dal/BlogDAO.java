package dal;


import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Blog;

/**
 * DAO cho b?ng Blogs
 */
public class BlogDAO {
    /**
     * L?y danh s�ch b�i blog ?� xu?t b?n (status = 'PUBLISHED')
     */
    public List<Blog> getPublishedBlogs() {
        List<Blog> list = new ArrayList<>();
        String sql = "SELECT b.Id, b.Title, b.Slug, b.Content, b.AuthorId, b.CreatedAt, b.UpdatedAt, u.FullName AS AuthorName"
                   + " FROM dbo.Blogs b"
                   + " JOIN dbo.Users u ON b.AuthorId = u.Id"
                   + " WHERE b.Status = 'PUBLISHED'"
                   + " ORDER BY b.CreatedAt DESC";
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
                // N?u c� tr??ng imageUrl trong Blog model, c� th? set ? ?�y
                list.add(blog);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * L?y chi ti?t 1 b�i blog theo slug (URL identifier)
     */
    public Blog getBlogBySlug(String slug) {
        String sql = "SELECT b.Id, b.Title, b.Slug, b.Content, b.AuthorId, b.CreatedAt, b.UpdatedAt, u.FullName AS AuthorName"
                   + " FROM dbo.Blogs b"
                   + " JOIN dbo.Users u ON b.AuthorId = u.Id"
                   + " WHERE b.Slug = ? AND b.Status = 'PUBLISHED'";
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
                    return blog;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
} 