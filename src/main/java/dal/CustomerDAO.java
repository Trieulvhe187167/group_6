package dal;

import model.Customer;
import model.Reservation;
import model.Feedback;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {
    
    // Get customers with pagination
    public List<Customer> getCustomersPaginated(int page, int recordsPerPage) {
        List<Customer> customers = new ArrayList<>();
        int start = (page - 1) * recordsPerPage;
        
        String sql = "WITH CustomerStats AS (\n" +
                    "    SELECT u.Id, COUNT(r.Id) as TotalBookings, \n" +
                    "           COALESCE(SUM(r.TotalAmount), 0) as TotalSpent\n" +
                    "    FROM Users u\n" +
                    "    LEFT JOIN Reservations r ON u.Id = r.UserId\n" +
                    "    WHERE u.Role = 'GUEST'\n" +
                    "    GROUP BY u.Id\n" +
                    ")\n" +
                    "SELECT u.*, cs.TotalBookings, cs.TotalSpent\n" +
                    "FROM Users u\n" +
                    "INNER JOIN CustomerStats cs ON u.Id = cs.Id\n" +
                    "WHERE u.Role = 'GUEST'\n" +
                    "ORDER BY u.Id DESC\n" +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, start);
            ps.setInt(2, recordsPerPage);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Customer customer = mapResultSetToCustomer(rs);
                customer.setTotalBookings(rs.getInt("TotalBookings"));
                customer.setTotalSpent(rs.getDouble("TotalSpent"));
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return customers;
    }
    
    // Get total number of customers
    public int getTotalCustomers() {
        String sql = "SELECT COUNT(*) FROM Users WHERE Role = 'GUEST'";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // Search customers
    public List<Customer> searchCustomers(String keyword) {
        List<Customer> customers = new ArrayList<>();
        String sql = "WITH CustomerStats AS (\n" +
                    "    SELECT u.Id, COUNT(r.Id) as TotalBookings, \n" +
                    "           COALESCE(SUM(r.TotalAmount), 0) as TotalSpent\n" +
                    "    FROM Users u\n" +
                    "    LEFT JOIN Reservations r ON u.Id = r.UserId\n" +
                    "    WHERE u.Role = 'GUEST'\n" +
                    "    GROUP BY u.Id\n" +
                    ")\n" +
                    "SELECT u.*, cs.TotalBookings, cs.TotalSpent\n" +
                    "FROM Users u\n" +
                    "INNER JOIN CustomerStats cs ON u.Id = cs.Id\n" +
                    "WHERE u.Role = 'GUEST' AND \n" +
                    "(u.Username LIKE ? OR u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ?)\n" +
                    "ORDER BY u.Id DESC";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Customer customer = mapResultSetToCustomer(rs);
                customer.setTotalBookings(rs.getInt("TotalBookings"));
                customer.setTotalSpent(rs.getDouble("TotalSpent"));
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return customers;
    }
    
    // Get all customers (without pagination)
    public List<Customer> getAllCustomers() {
        List<Customer> customers = new ArrayList<>();
        
        String sql = "WITH CustomerStats AS (\n" +
                    "    SELECT u.Id, COUNT(r.Id) as TotalBookings, \n" +
                    "           COALESCE(SUM(r.TotalAmount), 0) as TotalSpent\n" +
                    "    FROM Users u\n" +
                    "    LEFT JOIN Reservations r ON u.Id = r.UserId\n" +
                    "    WHERE u.Role = 'GUEST'\n" +
                    "    GROUP BY u.Id\n" +
                    ")\n" +
                    "SELECT u.*, cs.TotalBookings, cs.TotalSpent\n" +
                    "FROM Users u\n" +
                    "INNER JOIN CustomerStats cs ON u.Id = cs.Id\n" +
                    "WHERE u.Role = 'GUEST'\n" +
                    "ORDER BY u.Id DESC";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Customer customer = mapResultSetToCustomer(rs);
                customer.setTotalBookings(rs.getInt("TotalBookings"));
                customer.setTotalSpent(rs.getDouble("TotalSpent"));
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return customers;
    }
    
    // Get customer by ID
    public Customer getCustomerById(int id) {
        // First check if customer exists with simpler query
        String checkSql = "SELECT * FROM Users WHERE Id = ?";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(checkSql)) {
            ps.setInt(1, id);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Customer customer = mapResultSetToCustomer(rs);
                
                // Get statistics separately
                String statsSql = "SELECT COUNT(r.Id) as TotalBookings, \n" +
                            "       COALESCE(SUM(r.TotalAmount), 0) as TotalSpent\n" +
                            "FROM Reservations r\n" +
                            "WHERE r.UserId = ?";
                
                try (PreparedStatement psStats = connection.prepareStatement(statsSql)) {
                    psStats.setInt(1, id);
                    ResultSet rsStats = psStats.executeQuery();
                    if (rsStats.next()) {
                        customer.setTotalBookings(rsStats.getInt("TotalBookings"));
                        customer.setTotalSpent(rsStats.getDouble("TotalSpent"));
                    }
                }
                
                return customer;
            }
        } catch (SQLException e) {
            System.err.println("Error getting customer by ID: " + id);
            e.printStackTrace();
        }
        
        return null;
    }
    
    // Check if email exists
    public boolean isEmailExists(String email, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Email = ?";
        if (excludeId != null) {
            sql += " AND Id != ?";
        }
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
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
        
        return false;
    }
    
    // Check if username exists
    public boolean isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM Users WHERE Username = ?";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Add new customer
    public boolean addCustomer(Customer customer) {
        String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, customer.getUsername());
            ps.setString(2, customer.getPasswordHash());
            ps.setString(3, customer.getFullName());
            ps.setString(4, customer.getEmail());
            ps.setString(5, customer.getPhone());
            ps.setString(6, customer.getRole());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Update customer
    public boolean updateCustomer(Customer customer) {
        String sql = "UPDATE Users SET FullName = ?, Email = ?, Phone = ? WHERE Id = ?";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
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
    
    // Delete customer (soft delete by changing role to INACTIVE)
    public boolean deleteCustomer(int id) {
        String sql = "UPDATE Users SET Role = 'INACTIVE' WHERE Id = ?";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Get customer statistics
    public CustomerStats getCustomerStats(int customerId) {
        CustomerStats stats = new CustomerStats();
        
        String sql = "SELECT \n" +
                    "    COUNT(DISTINCT r.Id) as TotalBookings,\n" +
                    "    COUNT(DISTINCT CASE WHEN r.Status = 'COMPLETED' THEN r.Id END) as CompletedBookings,\n" +
                    "    COALESCE(SUM(r.TotalAmount), 0) as TotalSpent,\n" +
                    "    COALESCE(AVG(CAST(f.Rating as FLOAT)), 0) as AverageRating\n" +
                    "FROM Users u\n" +
                    "LEFT JOIN Reservations r ON u.Id = r.UserId\n" +
                    "LEFT JOIN Feedback f ON r.Id = f.ReservationId\n" +
                    "WHERE u.Id = ?\n" +
                    "GROUP BY u.Id";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                stats.totalBookings = rs.getInt("TotalBookings");
                stats.completedBookings = rs.getInt("CompletedBookings");
                stats.totalSpent = rs.getDouble("TotalSpent");
                stats.averageRating = rs.getDouble("AverageRating");
            }
        } catch (SQLException e) {
            System.err.println("Error getting customer stats for ID: " + customerId);
            e.printStackTrace();
        }
        
        return stats;
    }
    
    // Get customers by role
    public List<Customer> getCustomersByRole(String role) {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Users WHERE Role = ? ORDER BY Id DESC";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, role);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                customers.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return customers;
    }
    
    // Get active customers (not INACTIVE)
    public List<Customer> getActiveCustomers() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Users WHERE Role != 'INACTIVE' ORDER BY Id DESC";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                customers.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return customers;
    }
    
    // Check if customer can login
    public Customer login(String username, String password) {
        String sql = "SELECT * FROM Users WHERE Username = ? AND PasswordHash = ? AND Role != 'INACTIVE'";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashPassword(password));
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSetToCustomer(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    // Update customer password
    public boolean updatePassword(int customerId, String newPassword) {
        String sql = "UPDATE Users SET PasswordHash = ? WHERE Id = ?";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, hashPassword(newPassword));
            ps.setInt(2, customerId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    // Get booking history for a customer
    public List<Reservation> getCustomerBookingHistory(int customerId) {
        List<Reservation> bookings = new ArrayList<>();
        String sql = "SELECT r.*, rm.RoomNumber \n" +
                    "FROM Reservations r \n" +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id \n" +
                    "WHERE r.UserId = ? \n" +
                    "ORDER BY r.CreatedAt DESC";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Reservation booking = new Reservation();
                booking.setId(rs.getInt("Id"));
                booking.setUserId(rs.getInt("UserId"));
                booking.setRoomId(rs.getInt("RoomId"));
                booking.setCheckIn(rs.getDate("CheckIn"));
                booking.setCheckOut(rs.getDate("CheckOut"));
                booking.setStatus(rs.getString("Status"));
                booking.setTotalAmount(rs.getBigDecimal("TotalAmount"));
                booking.setCreatedAt(rs.getTimestamp("CreatedAt"));
                booking.setRoomNumber(rs.getString("RoomNumber"));
                bookings.add(booking);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return bookings;
    }
    
    // Get feedback history for a customer
    public List<Feedback> getCustomerFeedback(int customerId) {
        List<Feedback> feedbacks = new ArrayList<>();
        String sql = "SELECT * FROM Feedback WHERE UserId = ? ORDER BY CreatedAt DESC";
        
        try (Connection connection = DBContext.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("Id"));
                feedback.setReservationId(rs.getInt("ReservationId"));
                feedback.setUserId(rs.getInt("UserId"));
                feedback.setRating(rs.getInt("Rating"));
                feedback.setComment(rs.getString("Comment"));
                feedback.setCreatedAt(rs.getTimestamp("CreatedAt"));
                feedbacks.add(feedback);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return feedbacks;
    }
    
    // Helper method to hash password
    private String hashPassword(String password) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    
    // Helper method to map ResultSet to Customer object
    private Customer mapResultSetToCustomer(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setId(rs.getInt("Id"));
        customer.setUsername(rs.getString("Username"));
        customer.setPasswordHash(rs.getString("PasswordHash"));
        customer.setFullName(rs.getString("FullName"));
        customer.setEmail(rs.getString("Email"));
        customer.setPhone(rs.getString("Phone"));
        customer.setRole(rs.getString("Role"));
        customer.setCreatedAt(rs.getTimestamp("CreatedAt"));
        customer.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return customer;
    }
    
    // Inner class for customer statistics
    public static class CustomerStats {
        public int totalBookings;
        public int completedBookings;
        public double totalSpent;
        public double averageRating;
    }
}