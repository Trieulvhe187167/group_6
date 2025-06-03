/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author dmx
 */
import model.Customer;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {
    
    // Lấy tất cả khách hàng
    public List<Customer> getAllCustomers() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Role = 'GUEST' ORDER BY u.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Customer customer = mapResultSetToCustomer(rs);
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }
    
    // Tìm kiếm khách hàng
    public List<Customer> searchCustomers(String keyword) {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Role = 'GUEST' AND " +
                    "(u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ? OR u.Username LIKE ?) " +
                    "ORDER BY u.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Customer customer = mapResultSetToCustomer(rs);
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }
    
    // Lấy khách hàng theo ID
    public Customer getCustomerById(int id) {
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Id = ? AND u.Role = 'GUEST'";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToCustomer(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Thêm khách hàng mới
    public boolean addCustomer(Customer customer) {
        String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role) " +
                    "VALUES (?, ?, ?, ?, ?, 'GUEST')";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, customer.getUsername());
            ps.setString(2, hashPassword(customer.getPassword()));
            ps.setString(3, customer.getFullName());
            ps.setString(4, customer.getEmail());
            ps.setString(5, customer.getPhone());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Cập nhật thông tin khách hàng
    public boolean updateCustomer(Customer customer) {
        String sql = "UPDATE Users SET FullName = ?, Email = ?, Phone = ? WHERE Id = ? AND Role = 'GUEST'";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, customer.getFullName());
            ps.setString(2, customer.getEmail());
            ps.setString(3, customer.getPhone());
            ps.setInt(4, customer.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Xóa khách hàng (soft delete - chuyển role thành INACTIVE)
    public boolean deleteCustomer(int id) {
        String sql = "UPDATE Users SET Role = 'INACTIVE' WHERE Id = ? AND Role = 'GUEST'";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Kiểm tra email đã tồn tại
    public boolean isEmailExists(String email, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Email = ? AND Role = 'GUEST'";
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
    
    // Phân trang
    public List<Customer> getCustomersPaginated(int page, int recordsPerPage) {
        List<Customer> customers = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;
        
        String sql = "SELECT u.*, " +
                    "(SELECT COUNT(*) FROM Reservations r WHERE r.UserId = u.Id) as TotalBookings " +
                    "FROM Users u WHERE u.Role = 'GUEST' " +
                    "ORDER BY u.CreatedAt DESC " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, offset);
            ps.setInt(2, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Customer customer = mapResultSetToCustomer(rs);
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }
    
    // Đếm tổng số khách hàng
    public int getTotalCustomers() {
        String sql = "SELECT COUNT(*) FROM Users WHERE Role = 'GUEST'";
        
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
    
    // Helper method để map ResultSet sang Customer object
    private Customer mapResultSetToCustomer(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setId(rs.getInt("Id"));
        customer.setUsername(rs.getString("Username"));
        customer.setFullName(rs.getString("FullName"));
        customer.setEmail(rs.getString("Email"));
        customer.setPhone(rs.getString("Phone"));
        customer.setCreatedAt(rs.getTimestamp("CreatedAt"));
        customer.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        customer.setTotalBookings(rs.getInt("TotalBookings"));
        return customer;
    }
    
    // Hash password using SHA-256
    private String hashPassword(String password) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                hexString.append(String.format("%02x", b));
            }
            return hexString.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}