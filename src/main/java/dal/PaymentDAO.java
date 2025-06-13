package dal;


import java.sql.*;

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
}