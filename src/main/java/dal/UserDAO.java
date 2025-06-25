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
    
    // Phân trang cho tất cả users (không phân biệt role hoặc theo role cụ thể)
    public List<User> getUsersByRolePaginated(String role, int page, int recordsPerPage) {
        List<User> users = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u " +
                    "WHERE u.Status = 1 ";
        
        // Nếu role là ALL hoặc null, không thêm điều kiện WHERE role
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += "AND u.Role = ? ";
        }
        
        sql += "ORDER BY u.CreatedAt DESC " +
               "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            
            // Chỉ set role parameter nếu không phải ALL
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(paramIndex++, role);
            }
            
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getUsersByRolePaginated: " + e.getMessage());
        }
        return users;
    }
    
    // Đếm tổng số users (có thể theo role hoặc tất cả)
    public int getTotalUsersByRole(String role) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Status = 1";
        
        // Nếu role là ALL hoặc null, không thêm điều kiện WHERE role
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += " AND Role = ?";
        }
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            // Chỉ set role parameter nếu không phải ALL
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(1, role);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getTotalUsersByRole: " + e.getMessage());
        }
        return 0;
    }
    
    // Tìm kiếm users với phân trang (có thể theo role hoặc tất cả)
    public List<User> searchUsersByRolePaginated(String keyword, String role, int page, int recordsPerPage) {
        List<User> users = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Status = 1 AND " +
                    "(u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?) ";
        
        // Nếu role là ALL hoặc null, không thêm điều kiện WHERE role
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += "AND u.Role = ? ";
        }
        
        sql += "ORDER BY u.CreatedAt DESC " +
               "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            int paramIndex = 5;
            
            // Chỉ set role parameter nếu không phải ALL
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(paramIndex++, role);
            }
            
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User user = mapResultSetToUser(rs);
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in searchUsersByRolePaginated: " + e.getMessage());
        }
        return users;
    }
    
    // Đếm tổng số users tìm kiếm (có thể theo role hoặc tất cả)
    public int getTotalSearchUsersByRole(String keyword, String role) {
        String sql = "SELECT COUNT(*) FROM Users u WHERE u.Status = 1 AND " +
                    "(u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?)";
        
        // Nếu role là ALL hoặc null, không thêm điều kiện WHERE role
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += " AND u.Role = ?";
        }
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            // Chỉ set role parameter nếu không phải ALL
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(5, role);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getTotalSearchUsersByRole: " + e.getMessage());
        }
        return 0;
    }
    
    // Lấy danh sách users đã xóa với phân trang (có thể theo role hoặc tất cả)
    public List<User> getDeletedUsersByRolePaginated(String role, int page, int recordsPerPage) {
        List<User> users = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Status = 0 ";
        
        // Nếu role là ALL hoặc null, không thêm điều kiện WHERE role
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += "AND u.Role = ? ";
        }
        
        sql += "ORDER BY u.UpdatedAt DESC " +
               "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            
            // Chỉ set role parameter nếu không phải ALL
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(paramIndex++, role);
            }
            
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, recordsPerPage);
            
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
    
    // Đếm tổng số users đã xóa (có thể theo role hoặc tất cả)
    public int getTotalDeletedUsersByRole(String role) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Status = 0";
        
        // Nếu role là ALL hoặc null, không thêm điều kiện WHERE role
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += " AND Role = ?";
        }
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            // Chỉ set role parameter nếu không phải ALL
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(1, role);
            }
            
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
    
    // Cập nhật thông tin user (không thay đổi password)
    public boolean updateUser(User user) {
        String sql = "UPDATE Users SET FullName = ?, Email = ?, Phone = ?, Role = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
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
    
    // Cập nhật thông tin user kèm password mới
    public boolean updateUserWithPassword(User user) {
        String sql = "UPDATE Users SET FullName = ?, Email = ?, Phone = ?, Role = ?, PasswordHash = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getRole());
            ps.setString(5, user.getPassword()); // Password đã được hash trong servlet
            ps.setInt(6, user.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Đổi password cho user cụ thể (dùng khi user tự đổi password)
    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        // Kiểm tra password cũ
        String checkSql = "SELECT PasswordHash FROM Users WHERE Id = ? AND Status = 1";
        String updateSql = "UPDATE Users SET PasswordHash = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection()) {
            // Kiểm tra password cũ
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, userId);
                ResultSet rs = checkPs.executeQuery();
                
                if (rs.next()) {
                    String storedHash = rs.getString("PasswordHash");
                    String oldPasswordHash = hashPassword(oldPassword);
                    
                    if (!storedHash.equalsIgnoreCase(oldPasswordHash)) {
                        return false; // Password cũ không đúng
                    }
                } else {
                    return false; // User không tồn tại
                }
            }
            
            // Cập nhật password mới
            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                updatePs.setString(1, hashPassword(newPassword));
                updatePs.setInt(2, userId);
                
                return updatePs.executeUpdate() > 0;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Reset password cho user (dùng khi admin reset password)
    public boolean resetPassword(int userId, String newPassword) {
        String sql = "UPDATE Users SET PasswordHash = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, hashPassword(newPassword));
            ps.setInt(2, userId);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Lấy thống kê về users (có thể mở rộng thêm các metrics khác)
    public int getTotalActiveUsers() {
        String sql = "SELECT COUNT(*) FROM Users WHERE Status = 1";
        
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
    
    // Xóa user (soft delete - chuyển status = 0)
    public boolean deleteUser(int id) {
        String sql = "UPDATE Users SET Status = 0, UpdatedAt = GETDATE() WHERE Id = ?";
        
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
        String sql = "UPDATE Users SET Status = 1, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
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
    
    // Lấy thống kê về users theo role
    public int getUserCountByRole(String role) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Status = 1 AND Role = ?";
        
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

 
    public int getGuestCount() {
        String sql = "SELECT COUNT(*) as Total FROM Users WHERE Role = 'CUSTOMER' AND Status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getGuestCount: " + e.getMessage());
        }
        return 0;
    }
    
    public int getActiveGuestCount() {
        String sql = "SELECT COUNT(*) as Total FROM Users WHERE Role = 'CUSTOMER' AND Status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getActiveGuestCount: " + e.getMessage());
        }
        return 0;
    }
    
    public int getVIPGuestCount() {
        String sql = "SELECT COUNT(*) as Total FROM (" +
                    "SELECT u.Id " +
                    "FROM Users u " +
                    "LEFT JOIN Reservations r ON u.Id = r.UserId " +
                    "WHERE u.Role = 'CUSTOMER' AND u.Status = 1 " +
                    "GROUP BY u.Id " +
                    "HAVING COALESCE(SUM(r.TotalAmount), 0) > 50000000 OR COUNT(r.Id) >= 10" +
                    ") as VIPGuests";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getVIPGuestCount: " + e.getMessage());
        }
        return 0;
    }
    
    public int getNewGuestsThisMonth() {
        String sql = "SELECT COUNT(*) as Total FROM Users " +
                    "WHERE Role = 'CUSTOMER' AND Status = 1 " +
                    "AND MONTH(CreatedAt) = MONTH(GETDATE()) " +
                    "AND YEAR(CreatedAt) = YEAR(GETDATE())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getNewGuestsThisMonth: " + e.getMessage());
        }
        return 0;
    }
    
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) as Total FROM Users WHERE Email = ? AND Status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in emailExists: " + e.getMessage());
        }
        return false;
    }
    
    public boolean phoneExists(String phone) {
        String sql = "SELECT COUNT(*) as Total FROM Users WHERE Phone = ? AND Status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, phone);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in phoneExists: " + e.getMessage());
        }
        return false;
    }
    
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) as Total FROM Users WHERE Username = ? AND Status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in usernameExists: " + e.getMessage());
        }
        return false;
    }
    
    public boolean createUser(User user) {
        String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role, Status, CreatedAt) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword()); // Already hashed in servlet
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole());
            ps.setBoolean(7, user.isStatus());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in createUser: " + e.getMessage());
        }
        return false;
    }

    public int createUserAndGetId(User user) {
        String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role, Status, CreatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword()); // Already hashed in servlet
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole());
            ps.setBoolean(7, user.isStatus());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
            
            return 0;
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in createUserAndGetId: " + e.getMessage());
            return 0;
        }
    }
    
// Get user by email
public User getUserByEmail(String email) {
    String sql = "SELECT u.*, " +
                "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                "FROM Users u WHERE u.Email = ? AND u.Status = 1";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, email);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return mapResultSetToUser(rs);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

// Get user by username or email (for login purposes)
public User getUserByUsernameOrEmail(String usernameOrEmail) {
    String sql = "SELECT u.*, " +
                "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                "FROM Users u WHERE (u.Username = ? OR u.Email = ?) AND u.Status = 1";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, usernameOrEmail);
        ps.setString(2, usernameOrEmail);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return mapResultSetToUser(rs);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

// Get guests with their booking statistics
public List<User> getGuestsWithStats() {
    List<User> guests = new ArrayList<>();
    String sql = "SELECT u.*, " +
                "COALESCE((SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id), 0) as TotalBookings, " +
                "COALESCE((SELECT SUM(r.TotalAmount) FROM Reservations r WHERE r.UserId = u.Id AND r.Status = 'COMPLETED'), 0) as TotalSpent, " +
                "COALESCE((SELECT MAX(r.CheckOut) FROM Reservations r WHERE r.UserId = u.Id AND r.Status = 'COMPLETED'), NULL) as LastVisit " +
                "FROM Users u WHERE u.Role = 'CUSTOMER' AND u.Status = 1 " +
                "ORDER BY TotalBookings DESC, u.CreatedAt DESC";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        while (rs.next()) {
            User guest = mapResultSetToUser(rs);
            // You can add additional fields here if needed
            guests.add(guest);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return guests;
}

// Check if user has any active reservations
public boolean hasActiveReservations(int userId) {
    String sql = "SELECT COUNT(*) FROM Reservations " +
                "WHERE UserId = ? AND Status IN ('CONFIRMED', 'PENDING') " +
                "AND CheckOut >= CAST(GETDATE() as DATE)";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

// Get staff users (receptionist, housekeeper, admin)
public List<User> getStaffUsers() {
    List<User> staff = new ArrayList<>();
    String sql = "SELECT u.*, " +
                "(SELECT COUNT(*) FROM Reservations r WHERE r.CreatedBy = u.Id) as TotalBookings " +
                "FROM Users u WHERE u.Role IN ('ADMIN', 'RECEPTIONIST', 'HOUSEKEEPER') AND u.Status = 1 " +
                "ORDER BY u.Role, u.FullName";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        while (rs.next()) {
            staff.add(mapResultSetToUser(rs));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return staff;
}

public List<User> getAuthors() {
    List<User> authors = new ArrayList<>();
    String sql = "SELECT * FROM Users WHERE Role IN ('ADMIN', 'RECEPTIONIST') AND Status = 1 ORDER BY FullName";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        while (rs.next()) {
            authors.add(mapResultSetToUser(rs));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return authors;
}

// Get all room inspectors
public List<User> getRoomInspectors() {
    List<User> inspectors = new ArrayList<>();
    String sql = "SELECT u.*, " +
                "(SELECT COUNT(*) FROM RoomInspections ri WHERE ri.InspectorId = u.Id) as TotalInspections " +
                "FROM Users u WHERE u.Role = 'ROOM_INSPECTOR' AND u.Status = 1 " +
                "ORDER BY u.FullName";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        while (rs.next()) {
            User inspector = mapResultSetToUser(rs);
            // TotalInspections will be mapped to TotalBookings field
            inspectors.add(inspector);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return inspectors;
}

// Get active room inspectors count
public int getActiveRoomInspectorCount() {
    String sql = "SELECT COUNT(*) FROM Users WHERE Role = 'ROOM_INSPECTOR' AND Status = 1";
    
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

// Get room inspector by ID with inspection statistics
public User getRoomInspectorWithStats(int inspectorId) {
    String sql = "SELECT u.*, " +
                "(SELECT COUNT(*) FROM RoomInspections ri WHERE ri.InspectorId = u.Id) as TotalInspections, " +
                "(SELECT COUNT(*) FROM RoomInspections ri WHERE ri.InspectorId = u.Id AND ri.Status = 'COMPLETED') as CompletedInspections, " +
                "(SELECT COUNT(*) FROM RoomInspections ri WHERE ri.InspectorId = u.Id AND CAST(ri.InspectionTime AS DATE) = CAST(GETDATE() AS DATE)) as TodayInspections " +
                "FROM Users u WHERE u.Id = ? AND u.Role = 'ROOM_INSPECTOR'";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, inspectorId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            User inspector = mapResultSetToUser(rs);
            // Additional stats can be stored in custom fields or a separate object
            return inspector;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return null;
}

// Check if user is room inspector
public boolean isRoomInspector(int userId) {
    String sql = "SELECT COUNT(*) FROM Users WHERE Id = ? AND Role = 'ROOM_INSPECTOR' AND Status = 1";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

    // Get customers with their detailed information including CustomerDetails
    public List<User> getCustomersWithDetails() {
        List<User> customers = new ArrayList<>();
        String sql = "SELECT u.*, cd.*, " +
                    "COUNT(r.Id) as TotalBookings, " +
                    "COUNT(CASE WHEN r.Status = 'COMPLETED' THEN 1 END) as CompletedBookings, " +
                    "COALESCE(SUM(CASE WHEN r.Status = 'COMPLETED' THEN r.TotalAmount ELSE 0 END), 0) as TotalSpent, " +
                    "MAX(CASE WHEN r.Status = 'COMPLETED' THEN r.CheckOut END) as LastVisit " +
                    "FROM Users u " +
                    "LEFT JOIN CustomerDetails cd ON u.Id = cd.UserId " +
                    "LEFT JOIN Reservations r ON u.Id = r.UserId " +
                    "WHERE u.Role = 'CUSTOMER' AND u.Status = 1 " +
                    "GROUP BY u.Id, u.Username, u.PasswordHash, u.FullName, u.Email, u.Phone, u.Role, u.Status, u.CreatedAt, u.UpdatedAt, " +
                    "cd.Id, cd.UserId, cd.IdType, cd.IdNumber, cd.DateOfBirth, cd.Gender, cd.Address, cd.City, cd.Country, " +
                    "cd.LoyaltyPoints, cd.MembershipLevel, cd.IsVIP, cd.CreatedAt, cd.UpdatedAt " +
                    "ORDER BY u.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User customer = mapResultSetToUserWithCustomerDetails(rs);
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getCustomersWithDetails: " + e.getMessage());
        }
        return customers;
    }
    
    // Get customers with pagination and detailed information
    public List<User> getCustomersPaginated(int page, int recordsPerPage) {
        List<User> customers = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, cd.*, " +
                    "COUNT(r.Id) as TotalBookings, " +
                    "COUNT(CASE WHEN r.Status = 'COMPLETED' THEN 1 END) as CompletedBookings, " +
                    "COALESCE(SUM(CASE WHEN r.Status = 'COMPLETED' THEN r.TotalAmount ELSE 0 END), 0) as TotalSpent, " +
                    "MAX(CASE WHEN r.Status = 'COMPLETED' THEN r.CheckOut END) as LastVisit " +
                    "FROM Users u " +
                    "LEFT JOIN CustomerDetails cd ON u.Id = cd.UserId " +
                    "LEFT JOIN Reservations r ON u.Id = r.UserId " +
                    "WHERE u.Role = 'CUSTOMER' AND u.Status = 1 " +
                    "GROUP BY u.Id, u.Username, u.PasswordHash, u.FullName, u.Email, u.Phone, u.Role, u.Status, u.CreatedAt, u.UpdatedAt, " +
                    "cd.Id, cd.UserId, cd.IdType, cd.IdNumber, cd.DateOfBirth, cd.Gender, cd.Address, cd.City, cd.Country, " +
                    "cd.LoyaltyPoints, cd.MembershipLevel, cd.IsVIP, cd.CreatedAt, cd.UpdatedAt " +
                    "ORDER BY u.CreatedAt DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, offset);
            ps.setInt(2, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User customer = mapResultSetToUserWithCustomerDetails(rs);
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getCustomersPaginated: " + e.getMessage());
        }
        return customers;
    }
    
    // Get employees with their detailed information including EmployeeDetails
    public List<User> getEmployeesWithDetails() {
        List<User> employees = new ArrayList<>();
        String sql = "SELECT u.*, ed.*, " +
                    "COUNT(r.Id) as TotalBookingsCreated " +
                    "FROM Users u " +
                    "LEFT JOIN EmployeeDetails ed ON u.Id = ed.UserId " +
                    "LEFT JOIN Reservations r ON u.Id = r.CreatedBy " +
                    "WHERE u.Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR') AND u.Status = 1 " +
                    "GROUP BY u.Id, u.Username, u.PasswordHash, u.FullName, u.Email, u.Phone, u.Role, u.Status, u.CreatedAt, u.UpdatedAt, " +
                    "ed.Id, ed.UserId, ed.Department, ed.HireDate, ed.Salary, ed.CreatedAt, ed.UpdatedAt " +
                    "ORDER BY u.Role, u.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User employee = mapResultSetToUserWithEmployeeDetails(rs);
                employees.add(employee);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getEmployeesWithDetails: " + e.getMessage());
        }
        return employees;
    }
    
    // Get employees with pagination and detailed information
    public List<User> getEmployeesPaginated(int page, int recordsPerPage) {
        List<User> employees = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, ed.*, " +
                    "COUNT(r.Id) as TotalBookingsCreated " +
                    "FROM Users u " +
                    "LEFT JOIN EmployeeDetails ed ON u.Id = ed.UserId " +
                    "LEFT JOIN Reservations r ON u.Id = r.CreatedBy " +
                    "WHERE u.Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR') AND u.Status = 1 " +
                    "GROUP BY u.Id, u.Username, u.PasswordHash, u.FullName, u.Email, u.Phone, u.Role, u.Status, u.CreatedAt, u.UpdatedAt, " +
                    "ed.Id, ed.UserId, ed.Department, ed.HireDate, ed.Salary, ed.CreatedAt, ed.UpdatedAt " +
                    "ORDER BY u.Role, u.CreatedAt DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, offset);
            ps.setInt(2, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User employee = mapResultSetToUserWithEmployeeDetails(rs);
                employees.add(employee);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getEmployeesPaginated: " + e.getMessage());
        }
        return employees;
    }
    
    // Get employees by role with pagination
    public List<User> getEmployeesByRolePaginated(String role, int page, int recordsPerPage) {
        List<User> employees = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, ed.*, " +
                    "COUNT(r.Id) as TotalBookingsCreated " +
                    "FROM Users u " +
                    "LEFT JOIN EmployeeDetails ed ON u.Id = ed.UserId " +
                    "LEFT JOIN Reservations r ON u.Id = r.CreatedBy " +
                    "WHERE u.Status = 1 ";
        
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += "AND u.Role = ? ";
        } else {
            sql += "AND u.Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR') ";
        }
        
        sql += "GROUP BY u.Id, u.Username, u.PasswordHash, u.FullName, u.Email, u.Phone, u.Role, u.Status, u.CreatedAt, u.UpdatedAt, " +
               "ed.Id, ed.UserId, ed.Department, ed.HireDate, ed.Salary, ed.CreatedAt, ed.UpdatedAt " +
               "ORDER BY u.Role, u.CreatedAt DESC " +
               "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(paramIndex++, role);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User employee = mapResultSetToUserWithEmployeeDetails(rs);
                employees.add(employee);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getEmployeesByRolePaginated: " + e.getMessage());
        }
        return employees;
    }
    
    // Search customers with pagination
    public List<User> searchCustomersPaginated(String keyword, int page, int recordsPerPage) {
        List<User> customers = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, cd.*, " +
                    "COUNT(r.Id) as TotalBookings, " +
                    "COUNT(CASE WHEN r.Status = 'COMPLETED' THEN 1 END) as CompletedBookings, " +
                    "COALESCE(SUM(CASE WHEN r.Status = 'COMPLETED' THEN r.TotalAmount ELSE 0 END), 0) as TotalSpent, " +
                    "MAX(CASE WHEN r.Status = 'COMPLETED' THEN r.CheckOut END) as LastVisit " +
                    "FROM Users u " +
                    "LEFT JOIN CustomerDetails cd ON u.Id = cd.UserId " +
                    "LEFT JOIN Reservations r ON u.Id = r.UserId " +
                    "WHERE u.Role = 'CUSTOMER' AND u.Status = 1 " +
                    "AND (u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?) " +
                    "GROUP BY u.Id, u.Username, u.PasswordHash, u.FullName, u.Email, u.Phone, u.Role, u.Status, u.CreatedAt, u.UpdatedAt, " +
                    "cd.Id, cd.UserId, cd.IdType, cd.IdNumber, cd.DateOfBirth, cd.Gender, cd.Address, cd.City, cd.Country, " +
                    "cd.LoyaltyPoints, cd.MembershipLevel, cd.IsVIP, cd.CreatedAt, cd.UpdatedAt " +
                    "ORDER BY u.CreatedAt DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            ps.setInt(5, offset);
            ps.setInt(6, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User customer = mapResultSetToUserWithCustomerDetails(rs);
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in searchCustomersPaginated: " + e.getMessage());
        }
        return customers;
    }
    
    // Search employees with pagination
    public List<User> searchEmployeesPaginated(String keyword, String role, int page, int recordsPerPage) {
        List<User> employees = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, ed.*, " +
                    "COUNT(r.Id) as TotalBookingsCreated " +
                    "FROM Users u " +
                    "LEFT JOIN EmployeeDetails ed ON u.Id = ed.UserId " +
                    "LEFT JOIN Reservations r ON u.Id = r.CreatedBy " +
                    "WHERE u.Status = 1 " +
                    "AND (u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?) ";
        
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += "AND u.Role = ? ";
        } else {
            sql += "AND u.Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR') ";
        }
        
        sql += "GROUP BY u.Id, u.Username, u.PasswordHash, u.FullName, u.Email, u.Phone, u.Role, u.Status, u.CreatedAt, u.UpdatedAt, " +
               "ed.Id, ed.UserId, ed.Department, ed.HireDate, ed.Salary, ed.CreatedAt, ed.UpdatedAt " +
               "ORDER BY u.Role, u.CreatedAt DESC " +
               "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            int paramIndex = 5;
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(paramIndex++, role);
            }
            ps.setInt(paramIndex++, offset);
            ps.setInt(paramIndex, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User employee = mapResultSetToUserWithEmployeeDetails(rs);
                employees.add(employee);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in searchEmployeesPaginated: " + e.getMessage());
        }
        return employees;
    }
    
    // Get customer by ID with detailed information
    public User getCustomerByIdWithDetails(int id) {
        String sql = "SELECT u.*, cd.*, " +
                    "COUNT(r.Id) as TotalBookings, " +
                    "COUNT(CASE WHEN r.Status = 'COMPLETED' THEN 1 END) as CompletedBookings, " +
                    "COALESCE(SUM(CASE WHEN r.Status = 'COMPLETED' THEN r.TotalAmount ELSE 0 END), 0) as TotalSpent, " +
                    "MAX(CASE WHEN r.Status = 'COMPLETED' THEN r.CheckOut END) as LastVisit " +
                    "FROM Users u " +
                    "LEFT JOIN CustomerDetails cd ON u.Id = cd.UserId " +
                    "LEFT JOIN Reservations r ON u.Id = r.UserId " +
                    "WHERE u.Id = ? AND u.Role = 'CUSTOMER' " +
                    "GROUP BY u.Id, u.Username, u.PasswordHash, u.FullName, u.Email, u.Phone, u.Role, u.Status, u.CreatedAt, u.UpdatedAt, " +
                    "cd.Id, cd.UserId, cd.IdType, cd.IdNumber, cd.DateOfBirth, cd.Gender, cd.Address, cd.City, cd.Country, " +
                    "cd.LoyaltyPoints, cd.MembershipLevel, cd.IsVIP, cd.CreatedAt, cd.UpdatedAt";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUserWithCustomerDetails(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get employee by ID with detailed information
    public User getEmployeeByIdWithDetails(int id) {
        String sql = "SELECT u.*, ed.*, " +
                    "COUNT(r.Id) as TotalBookingsCreated " +
                    "FROM Users u " +
                    "LEFT JOIN EmployeeDetails ed ON u.Id = ed.UserId " +
                    "LEFT JOIN Reservations r ON u.Id = r.CreatedBy " +
                    "WHERE u.Id = ? AND u.Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR') " +
                    "GROUP BY u.Id, u.Username, u.PasswordHash, u.FullName, u.Email, u.Phone, u.Role, u.Status, u.CreatedAt, u.UpdatedAt, " +
                    "ed.Id, ed.UserId, ed.Department, ed.HireDate, ed.Salary, ed.CreatedAt, ed.UpdatedAt";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUserWithEmployeeDetails(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Create customer with CustomerDetails
    public boolean createCustomer(User customer) {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            
            // Insert into Users table
            String userSql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role, Status, CreatedAt) " +
                           "VALUES (?, ?, ?, ?, ?, 'CUSTOMER', 1, GETDATE())";
            
            int userId;
            try (PreparedStatement ps = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, customer.getUsername());
                ps.setString(2, customer.getPassword()); // Already hashed
                ps.setString(3, customer.getFullName());
                ps.setString(4, customer.getEmail());
                ps.setString(5, customer.getPhone());
                
                ps.executeUpdate();
                
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        userId = rs.getInt(1);
                    } else {
                        throw new SQLException("Failed to get generated user ID");
                    }
                }
            }
            
            // Insert into CustomerDetails table with default values
            String detailsSql = "INSERT INTO CustomerDetails (UserId, LoyaltyPoints, MembershipLevel, IsVIP, CreatedAt) " +
                               "VALUES (?, 0, 'BRONZE', 0, GETDATE())";
            
            try (PreparedStatement ps = conn.prepareStatement(detailsSql)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    // Create employee with EmployeeDetails
    public boolean createEmployee(User employee) {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            
            // Insert into Users table
            String userSql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role, Status, CreatedAt) " +
                           "VALUES (?, ?, ?, ?, ?, ?, 1, GETDATE())";
            
            int userId;
            try (PreparedStatement ps = conn.prepareStatement(userSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, employee.getUsername());
                ps.setString(2, employee.getPassword()); // Already hashed
                ps.setString(3, employee.getFullName());
                ps.setString(4, employee.getEmail());
                ps.setString(5, employee.getPhone());
                ps.setString(6, employee.getRole());
                
                ps.executeUpdate();
                
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        userId = rs.getInt(1);
                    } else {
                        throw new SQLException("Failed to get generated user ID");
                    }
                }
            }
            
            // Insert into EmployeeDetails table with default values
            String detailsSql = "INSERT INTO EmployeeDetails (UserId, Department, HireDate, CreatedAt) " +
                               "VALUES (?, ?, GETDATE(), GETDATE())";
            
            try (PreparedStatement ps = conn.prepareStatement(detailsSql)) {
                ps.setInt(1, userId);
                ps.setString(2, getDepartmentByRole(employee.getRole()));
                ps.executeUpdate();
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    // Helper method to get department by role
    private String getDepartmentByRole(String role) {
        switch (role) {
            case "ADMIN": return "Management";
            case "RECEPTIONIST": return "Front Office";
            case "HOUSEKEEPER": return "Housekeeping";
            case "ROOM_INSPECTOR": return "Quality Control";
            default: return "General";
        }
    }
    
    // Count total customers
    public int getTotalCustomersCount() {
        String sql = "SELECT COUNT(*) FROM Users WHERE Role = 'CUSTOMER' AND Status = 1";
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
    
    // Count total employees
    public int getTotalEmployeesCount() {
        String sql = "SELECT COUNT(*) FROM Users WHERE Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR') AND Status = 1";
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
    
    // Count employees by role
    public int getTotalEmployeesByRole(String role) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Status = 1 ";
        
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += "AND Role = ?";
        } else {
            sql += "AND Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR')";
        }
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(1, role);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Count search results for customers
    public int getTotalSearchCustomersCount(String keyword) {
        String sql = "SELECT COUNT(*) FROM Users u WHERE u.Role = 'CUSTOMER' AND u.Status = 1 " +
                    "AND (u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Count search results for employees
    public int getTotalSearchEmployeesCount(String keyword, String role) {
        String sql = "SELECT COUNT(*) FROM Users u WHERE u.Status = 1 " +
                    "AND (u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?) ";
        
        if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
            sql += "AND u.Role = ?";
        } else {
            sql += "AND u.Role IN ('ADMIN','RECEPTIONIST','HOUSEKEEPER','ROOM_INSPECTOR')";
        }
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            if (role != null && !role.isEmpty() && !"ALL".equals(role)) {
                ps.setString(5, role);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Map ResultSet to User with CustomerDetails
    private User mapResultSetToUserWithCustomerDetails(ResultSet rs) throws SQLException {
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
        
        // Customer details
        try {
            user.setIdType(rs.getString("IdType"));
            user.setIdNumber(rs.getString("IdNumber"));
            user.setDateOfBirth(rs.getDate("DateOfBirth"));
            user.setGender(rs.getString("Gender"));
            user.setAddress(rs.getString("Address"));
            user.setCity(rs.getString("City"));
            user.setCountry(rs.getString("Country"));
            user.setLoyaltyPoints(rs.getInt("LoyaltyPoints"));
            user.setMembershipLevel(rs.getString("MembershipLevel"));
            user.setIsVIP(rs.getBoolean("IsVIP"));
        } catch (SQLException e) {
            // CustomerDetails might not exist for some users
        }
        
        // Statistics
        try {
            user.setTotalBookings(rs.getInt("TotalBookings"));
            user.setCompletedBookings(rs.getInt("CompletedBookings"));
            user.setTotalSpent(rs.getDouble("TotalSpent"));
            user.setLastVisit(rs.getDate("LastVisit"));
        } catch (SQLException e) {
            // Statistics columns might not be in all queries
        }
        
        return user;
    }
    
    // Map ResultSet to User with EmployeeDetails
    private User mapResultSetToUserWithEmployeeDetails(ResultSet rs) throws SQLException {
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
        
        // Employee details
        try {
            user.setDepartment(rs.getString("Department"));
            user.setHireDate(rs.getDate("HireDate"));
            user.setSalary(rs.getDouble("Salary"));
        } catch (SQLException e) {
            // EmployeeDetails might not exist for some users
        }
        
        // Statistics
        try {
            user.setTotalBookings(rs.getInt("TotalBookingsCreated"));
        } catch (SQLException e) {
            // Statistics columns might not be in all queries
        }
        
        return user;
    }
   
  
}