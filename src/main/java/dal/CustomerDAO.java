package dal;

import model.Customer;
import model.Reservation;
import java.sql.*;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for Customer management
 * Handles all database operations related to customers
 */
public class CustomerDAO {
    
    /**
     * Get all customers with their statistics
     */
    public List<Customer> getCustomersWithStats() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT u.Id, u.Username, u.FullName, u.Email, u.Phone, u.Status, u.CreatedAt, u.UpdatedAt, " +
                    "COUNT(r.Id) as TotalBookings, " +
                    "COUNT(CASE WHEN r.Status = 'COMPLETED' THEN 1 END) as CompletedBookings, " +
                    "COALESCE(SUM(r.TotalAmount), 0) as TotalSpent, " +
                    "MAX(r.CheckOut) as LastVisit, " +
                    "AVG(CASE WHEN r.Status = 'COMPLETED' THEN DATEDIFF(day, r.CheckIn, r.CheckOut) END) as AvgNights " +
                    "FROM Users u " +
                    "LEFT JOIN Reservations r ON u.Id = r.UserId " +
                    "WHERE u.Role = 'CUSTOMER' AND u.Status = 1 " +
                    "GROUP BY u.Id, u.Username, u.FullName, u.Email, u.Phone, u.Status, u.CreatedAt, u.UpdatedAt " +
                    "ORDER BY u.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Customer customer = mapResultSetToCustomer(rs);
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error in getCustomersWithStats: " + e.getMessage());
        }
        return customers;
    }
    
    /**
     * Get customer details by ID
     */
    public Customer getCustomerById(int id) {
      // Aggregate reservation statistics in a subquery to avoid GROUP BY issues
        String sql = "SELECT u.Id, u.Username, u.FullName, u.Email, u.Phone, u.Status, " +
                     "u.CreatedAt, u.UpdatedAt, stats.TotalBookings, stats.CompletedBookings, " +
                     "stats.TotalSpent, stats.LastVisit, stats.AvgNights " +
                     "FROM Users u " +
                     "LEFT JOIN (" +
                     "  SELECT UserId, COUNT(Id) AS TotalBookings, " +
                     "         COUNT(CASE WHEN Status = 'COMPLETED' THEN 1 END) AS CompletedBookings, " +
                     "         COALESCE(SUM(TotalAmount), 0) AS TotalSpent, " +
                     "         MAX(CheckOut) AS LastVisit, " +
                     "         AVG(CASE WHEN Status = 'COMPLETED' THEN DATEDIFF(day, CheckIn, CheckOut) END) AS AvgNights " +
                     "  FROM Reservations " +
                     "  GROUP BY UserId" +
                     ") stats ON u.Id = stats.UserId " +
                     "WHERE u.Id = ? AND u.Role = 'CUSTOMER'";
        
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
    
    /**
     * Get customer's booking history
     */
    public List<Reservation> getCustomerBookingHistory(int customerId) {
        String sql = "SELECT r.*, rm.RoomNumber, rt.Name as RoomTypeName " +
                    "FROM Reservations r " +
                    "JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "WHERE r.UserId = ? " +
                    "ORDER BY r.CheckIn DESC";
        
        List<Reservation> bookings = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Reservation booking = new Reservation();
                booking.setId(rs.getInt("Id"));
                booking.setUserId(rs.getInt("UserId"));
                booking.setRoomId(rs.getInt("RoomId"));
                booking.setCheckIn(rs.getDate("CheckIn"));
                booking.setCheckOut(rs.getDate("CheckOut"));
                booking.setTotalAmount(rs.getDouble("TotalAmount"));
                booking.setStatus(rs.getString("Status"));
                booking.setCreatedAt(rs.getTimestamp("CreatedAt"));
                // Additional fields from joins
                booking.setRoomNumber(rs.getString("RoomNumber"));
                booking.setRoomTypeName(rs.getString("RoomTypeName"));
                bookings.add(booking);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }
    
    /**
     * Create new customer
     */
    public int createCustomer(Customer customer, String password) {
        String sql = "INSERT INTO Users (Username, PasswordHash, FullName, Email, Phone, Role, Status, CreatedAt) " +
                    "VALUES (?, ?, ?, ?, ?, 'CUSTOMER', 1, GETDATE())";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, customer.getUsername());
            ps.setString(2, hashPassword(password));
            ps.setString(3, customer.getFullName());
            ps.setString(4, customer.getEmail());
            ps.setString(5, customer.getPhone());
            
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
            System.out.println("Error in createCustomer: " + e.getMessage());
            return 0;
        }
    }
    
    /**
     * Update customer information
     */
    public boolean updateCustomer(Customer customer) {
        String sql = "UPDATE Users SET FullName = ?, Email = ?, Phone = ?, UpdatedAt = GETDATE() WHERE Id = ? AND Role = 'CUSTOMER'";
        
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
    
    /**
     * Get total customer count
     */
    public int getCustomerCount() {
        String sql = "SELECT COUNT(*) as Total FROM Users WHERE Role = 'CUSTOMER' AND Status = 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Get active customer count (same as total for now, but can be modified later)
     */
    public int getActiveCustomerCount() {
        return getCustomerCount();
    }
    
    /**
     * Get VIP customer count
     */
    public int getVIPCustomerCount() {
        String sql = "SELECT COUNT(*) as Total FROM (" +
                    "SELECT u.Id " +
                    "FROM Users u " +
                    "LEFT JOIN Reservations r ON u.Id = r.UserId " +
                    "WHERE u.Role = 'CUSTOMER' AND u.Status = 1 " +
                    "GROUP BY u.Id " +
                    "HAVING COALESCE(SUM(r.TotalAmount), 0) > 50000000 OR COUNT(r.Id) >= 10" +
                    ") as VIPCustomers";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Get new customers this month
     */
    public int getNewCustomersThisMonth() {
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
        }
        return 0;
    }
    
    /**
     * Check if email exists for a customer
     */
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
        }
        return false;
    }
    
    /**
     * Check if phone exists for a customer
     */
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
        }
        return false;
    }
    
    /**
     * Check if username exists
     */
    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) as Total FROM Users WHERE Username = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("Total") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Search customers by keyword
     */
    public List<Customer> searchCustomers(String keyword) {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT u.*, " +
                    "COUNT(r.Id) as TotalBookings, " +
                    "COUNT(CASE WHEN r.Status = 'COMPLETED' THEN 1 END) as CompletedBookings, " +
                    "COALESCE(SUM(r.TotalAmount), 0) as TotalSpent, " +
                    "MAX(r.CheckOut) as LastVisit " +
                    "FROM Users u " +
                    "LEFT JOIN Reservations r ON u.Id = r.UserId " +
                    "WHERE u.Role = 'CUSTOMER' AND u.Status = 1 " +
                    "AND (u.FullName LIKE ? OR u.Email LIKE ? OR u.Phone LIKE ?) " +
                    "GROUP BY u.Id, u.Username, u.FullName, u.Email, u.Phone, u.Status, u.CreatedAt, u.UpdatedAt";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                customers.add(mapResultSetToCustomer(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }
    
    /**
     * Map ResultSet to Customer object
     */
    private Customer mapResultSetToCustomer(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        customer.setId(rs.getInt("Id"));
        customer.setUsername(rs.getString("Username"));
        customer.setFullName(rs.getString("FullName"));
        customer.setEmail(rs.getString("Email"));
        customer.setPhone(rs.getString("Phone"));
        customer.setStatus(rs.getBoolean("Status"));
        customer.setCreatedAt(rs.getTimestamp("CreatedAt"));
        customer.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        
        // Get statistics if available
        try {
            customer.setTotalBookings(rs.getInt("TotalBookings"));
            customer.setCompletedBookings(rs.getInt("CompletedBookings"));
            customer.setTotalSpent(rs.getDouble("TotalSpent"));
            customer.setLastVisit(rs.getDate("LastVisit"));
            customer.setAvgNights(rs.getDouble("AvgNights"));
            
            // Set loyalty status based on total spent and bookings
            if (customer.getTotalSpent() > 50000000 || customer.getTotalBookings() >= 10) {
                customer.setLoyaltyStatus("VIP");
            } else if (customer.getTotalSpent() > 30000000 || customer.getTotalBookings() >= 7) {
                customer.setLoyaltyStatus("Gold");
            } else if (customer.getTotalSpent() > 15000000 || customer.getTotalBookings() >= 4) {
                customer.setLoyaltyStatus("Silver");
            } else {
                customer.setLoyaltyStatus("Bronze");
            }
        } catch (SQLException e) {
            // Ignore if statistics columns are not in result set
        }
        
        return customer;
    }
    
    /**
     * Hash password using SHA-256
     */
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Get all customers (for export)
     */
    public List<Customer> getAllCustomers() {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM Users WHERE Role = 'CUSTOMER' ORDER BY CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Customer customer = new Customer();
                customer.setId(rs.getInt("Id"));
                customer.setUsername(rs.getString("Username"));
                customer.setFullName(rs.getString("FullName"));
                customer.setEmail(rs.getString("Email"));
                customer.setPhone(rs.getString("Phone"));
                customer.setStatus(rs.getBoolean("Status"));
                customer.setCreatedAt(rs.getTimestamp("CreatedAt"));
                customer.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                customers.add(customer);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return customers;
    }
    
    
/**
 * Update customer details including guest status
 */
public boolean updateCustomerDetails(Customer customer) {
    String sql = "UPDATE CustomerDetails SET IsGuest = ?, UpdatedAt = GETDATE() WHERE UserId = ?";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setBoolean(1, customer.isGuest());
        ps.setInt(2, customer.getId());
        
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

/**
 * Get guest customers who are eligible for upgrade
 */
public List<Customer> getEligibleGuestCustomers() {
    List<Customer> guests = new ArrayList<>();
    String sql = "SELECT u.*, cd.IsGuest, " +
                "COUNT(r.Id) as BookingCount, " +
                "COALESCE(SUM(r.TotalAmount), 0) as TotalSpent " +
                "FROM Users u " +
                "INNER JOIN CustomerDetails cd ON u.Id = cd.UserId " +
                "LEFT JOIN Reservations r ON u.Id = r.UserId " +
                "WHERE u.Role = 'CUSTOMER' AND cd.IsGuest = 1 " +
                "GROUP BY u.Id, u.Username, u.FullName, u.Email, u.Phone, u.Status, " +
                "u.CreatedAt, u.UpdatedAt, cd.IsGuest " +
                "HAVING COUNT(r.Id) >= 2 OR COALESCE(SUM(r.TotalAmount), 0) > 10000000 " +
                "ORDER BY TotalSpent DESC";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Customer customer = mapResultSetToCustomer(rs);
            customer.setIsGuest(rs.getBoolean("IsGuest"));
            customer.setBookingCount(rs.getInt("BookingCount"));
            guests.add(customer);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return guests;
}

/**
 * Convert guest to member
 */
public boolean convertGuestToMember(int userId, String newPassword) {
    Connection conn = null;
    try {
        conn = DBContext.getConnection();
        conn.setAutoCommit(false);
        
        // Update password
        String updateUserSql = "UPDATE Users SET PasswordHash = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateUserSql)) {
            ps.setString(1, hashPassword(newPassword));
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
        
        // Update guest status
        String updateDetailsSql = "UPDATE CustomerDetails SET IsGuest = 0, UpdatedAt = GETDATE() WHERE UserId = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateDetailsSql)) {
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

/**
 * Get guest statistics for dashboard
 */
public Map<String, Object> getGuestStatistics() {
    Map<String, Object> stats = new HashMap<>();
    
    String sql = "SELECT " +
                "COUNT(CASE WHEN cd.IsGuest = 1 THEN 1 END) as TotalGuests, " +
                "COUNT(CASE WHEN cd.IsGuest = 1 AND MONTH(u.CreatedAt) = MONTH(GETDATE()) " +
                "    AND YEAR(u.CreatedAt) = YEAR(GETDATE()) THEN 1 END) as NewGuestsThisMonth, " +
                "COUNT(CASE WHEN cd.IsGuest = 0 THEN 1 END) as TotalMembers " +
                "FROM Users u " +
                "INNER JOIN CustomerDetails cd ON u.Id = cd.UserId " +
                "WHERE u.Role = 'CUSTOMER' AND u.Status = 1";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            stats.put("totalGuests", rs.getInt("TotalGuests"));
            stats.put("newGuestsThisMonth", rs.getInt("NewGuestsThisMonth"));
            stats.put("totalMembers", rs.getInt("TotalMembers"));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    return stats;
}
}