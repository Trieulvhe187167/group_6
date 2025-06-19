package dal;


import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Payment;

public class PaymentDAO {
    
    // Get monthly revenue
    public double getMonthlyRevenue(int month, int year) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND MONTH(p.CreatedAt) = ? " +
                    "AND YEAR(p.CreatedAt) = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, month);
            ps.setInt(2, year);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get yearly revenue
    public double getYearlyRevenue(int year) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND YEAR(p.CreatedAt) = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, year);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get daily revenue
    public double getDailyRevenue(Date date) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND CAST(p.CreatedAt AS DATE) = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, date);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get revenue by payment method
    public double getRevenueByMethod(String method, int month, int year) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND p.Method = ? " +
                    "AND MONTH(p.CreatedAt) = ? " +
                    "AND YEAR(p.CreatedAt) = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, method);
            ps.setInt(2, month);
            ps.setInt(3, year);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get revenue by date range
    public double getRevenueByDateRange(Date startDate, Date endDate) {
        String sql = "SELECT ISNULL(SUM(p.Amount), 0) as TotalRevenue " +
                    "FROM Payments p " +
                    "WHERE p.Status = 'SUCCESS' " +
                    "AND CAST(p.CreatedAt AS DATE) BETWEEN ? AND ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, startDate);
            ps.setDate(2, endDate);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get payment count by status
    public int getPaymentCountByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Payments WHERE Status = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
     // Get payments by reservation
    public List<Payment> getPaymentsByReservation(int reservationId) {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT * FROM Payments WHERE ReservationId = ? ORDER BY CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Payment payment = new Payment();
                payment.setId(rs.getInt("Id"));
                payment.setReservationId(rs.getInt("ReservationId"));
                payment.setAmount(rs.getDouble("Amount"));
                payment.setMethod(rs.getString("Method"));
                payment.setStatus(rs.getString("Status"));
                payment.setTransactionId(rs.getString("TransactionId"));
                payment.setCreatedAt(rs.getTimestamp("CreatedAt"));
                payments.add(payment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return payments;
    }
    
    // Create new payment
    public boolean createPayment(Payment payment) {
        String sql = "INSERT INTO Payments (ReservationId, Amount, Method, Status, TransactionId, CreatedAt) " +
                    "VALUES (?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, payment.getReservationId());
            ps.setDouble(2, payment.getAmount());
            ps.setString(3, payment.getMethod());
            ps.setString(4, payment.getStatus());
            ps.setString(5, payment.getTransactionId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update payment status
    public boolean updatePaymentStatus(int paymentId, String newStatus, String transactionId) {
        String sql = "UPDATE Payments SET Status = ?, TransactionId = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, newStatus);
            ps.setString(2, transactionId);
            ps.setInt(3, paymentId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get pending payments
    public List<Payment> getPendingPayments() {
        List<Payment> payments = new ArrayList<>();
        String sql = "SELECT p.*, r.UserId, u.FullName, rm.RoomNumber " +
                    "FROM Payments p " +
                    "INNER JOIN Reservations r ON p.ReservationId = r.Id " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE p.Status = 'PENDING' " +
                    "ORDER BY p.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Payment payment = new Payment();
                payment.setId(rs.getInt("Id"));
                payment.setReservationId(rs.getInt("ReservationId"));
                payment.setAmount(rs.getDouble("Amount"));
                payment.setMethod(rs.getString("Method"));
                payment.setStatus(rs.getString("Status"));
                payment.setTransactionId(rs.getString("TransactionId"));
                payment.setCreatedAt(rs.getTimestamp("CreatedAt"));
                payment.setCustomerName(rs.getString("FullName"));
                payment.setRoomNumber(rs.getString("RoomNumber"));
                payments.add(payment);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return payments;
    }
    
    // Get total revenue for a date range
    public double getTotalRevenue(Date startDate, Date endDate) {
        String sql = "SELECT ISNULL(SUM(Amount), 0) as TotalRevenue " +
                    "FROM Payments " +
                    "WHERE Status = 'SUCCESS' " +
                    "AND CAST(CreatedAt AS DATE) BETWEEN ? AND ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, startDate);
            ps.setDate(2, endDate);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    public String getReservationPaymentStatus(int reservationId) {
        String sql = "SELECT Status FROM Payments WHERE ReservationId = ? ORDER BY CreatedAt DESC LIMIT 1";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("Status");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "PENDING";
    }
    
    public double getReservationPaidAmount(int reservationId) {
        String sql = "SELECT COALESCE(SUM(Amount), 0) as TotalPaid FROM Payments WHERE ReservationId = ? AND Status = 'SUCCESS'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalPaid");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
}