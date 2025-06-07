package dal;

import model.User;
import java.sql.*;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // Login method
    public User login(String username, String password) {
        String sql = "SELECT * FROM Users WHERE (Username = ? OR Email = ?) AND Status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("PasswordHash");
                String inputHash = hashPassword(password);
                
                // Debug (tạm thời): In ra để kiểm tra giá trị hash
                System.out.println("Stored Hash: " + storedHash);
                System.out.println("Input  Hash: " + inputHash);

                if (storedHash != null && storedHash.equalsIgnoreCase(inputHash)) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Lấy tất cả users theo role
    public List<User> getUsersByRole(String role) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Role = ? AND u.Status = 1 " +
                    "ORDER BY u.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    
    // Lấy tất cả users (mọi role)
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Status = 1 " +
                    "ORDER BY u.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    
    // Tìm kiếm users theo role
    public List<User> searchUsersByRole(String keyword, String role) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Role = ? AND u.Status = 1 AND " +
                    "(u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?) " +
                    "ORDER BY u.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, role);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setString(5, searchPattern);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    
    // Tìm kiếm users theo role với phân trang
    public List<User> searchUsersByRolePaginated(String keyword, String role, int page, int recordsPerPage) {
        List<User> users = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Role = ? AND u.Status = 1 AND " +
                    "(u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?) " +
                    "ORDER BY u.CreatedAt DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, role);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setString(5, searchPattern);
            ps.setInt(6, offset);
            ps.setInt(7, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    
    // Đếm tổng số users tìm kiếm theo role
    public int getTotalSearchUsersByRole(String keyword, String role) {
        String sql = "SELECT COUNT(*) FROM Users u WHERE u.Role = ? AND u.Status = 1 AND " +
                    "(u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, role);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setString(5, searchPattern);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Lấy user theo ID
    public User getUserById(int id) {
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Thêm user mới
    public boolean addUser(User user) {
        String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role, Status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, 1)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getUsername());
            ps.setString(2, hashPassword(user.getPassword()));
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Cập nhật thông tin user
    public boolean updateUser(User user) {
        String sql = "UPDATE Users SET FullName = ?, Email = ?, Phone = ?, Role = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getRole());
            ps.setInt(5, user.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Xóa user (soft delete - chuyển status = 0)
    public boolean deleteUser(int id) {
        String sql = "UPDATE Users SET Status = 0 WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Khôi phục user
    public boolean restoreUser(int id) {
        String sql = "UPDATE Users SET Status = 1 WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Lấy danh sách users đã xóa theo role
    public List<User> getDeletedUsersByRole(String role) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Role = ? AND u.Status = 0 " +
                    "ORDER BY u.UpdatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    
    // Lấy danh sách users đã xóa theo role với phân trang
    public List<User> getDeletedUsersByRolePaginated(String role, int page, int recordsPerPage) {
        List<User> users = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Role = ? AND u.Status = 0 " +
                    "ORDER BY u.UpdatedAt DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, role);
            ps.setInt(2, offset);
            ps.setInt(3, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    
    // Đếm tổng số users đã xóa theo role
    public int getTotalDeletedUsersByRole(String role) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Role = ? AND Status = 0";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Kiểm tra email tồn tại
    public boolean isEmailExists(String email, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Email = ? AND Status = 1";
        if (excludeId != null) {
            sql += " AND Id != ?";
        }
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return true;
    }
    
    // Kiểm tra username tồn tại
    public boolean isUsernameExists(String username, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Username = ? AND Status = 1";
        if (excludeId != null) {
            sql += " AND Id != ?";
        }
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return true;
    }
    
    // Phân trang users theo role
    public List<User> getUsersByRolePaginated(String role, int page, int recordsPerPage) {
        List<User> users = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u " +
                    "WHERE u.Role = ? AND u.Status = 1 " +
                    "ORDER BY u.CreatedAt DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, role);
            ps.setInt(2, offset);
            ps.setInt(3, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    
    // Đếm tổng số users theo role
    public int getTotalUsersByRole(String role) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Role = ? AND Status = 1";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Helper method để map ResultSet sang User object
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("Id"));
        user.setUsername(rs.getString("Username"));
        user.setFullName(rs.getString("FullName"));
        user.setEmail(rs.getString("Email"));
        user.setPhone(rs.getString("Phone"));
        user.setRole(rs.getString("Role"));
        user.setStatus(rs.getBoolean("Status"));
        user.setCreatedAt(rs.getTimestamp("CreatedAt"));
        user.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        
        // Check if TotalBookings column exists in result set
        try {
            user.setTotalBookings(rs.getInt("TotalBookings"));
        } catch (SQLException e) {
            // Column doesn't exist, set default value
            user.setTotalBookings(0);
        }
        
        return user;
    }
    
    // Hash password using SHA-256
    private String hashPassword(String password) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hashBytes = md.digest(password.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : hashBytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
}