package dal;


import model.ReservationSummary;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {
    
    // Get today's check-ins count
    public int getTodayCheckIns() {
        String sql = "SELECT COUNT(*) FROM Reservations " +
                    "WHERE CheckIn = CAST(GETDATE() AS DATE) " +
                    "AND Status IN ('CONFIRMED', 'PENDING')";
        
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
    
    // Get recent reservations
    public List<ReservationSummary> getRecentReservations(int limit) {
        List<ReservationSummary> reservations = new ArrayList<>();
        String sql = "SELECT TOP (?) r.Id, u.FullName as CustomerName, " +
                    "rm.RoomNumber, r.CheckIn, r.CheckOut, r.Status, " +
                    "r.TotalAmount, r.CreatedAt " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "ORDER BY r.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ReservationSummary res = new ReservationSummary();
                res.setId(rs.getInt("Id"));
                res.setCustomerName(rs.getString("CustomerName"));
                res.setRoomNumber(rs.getString("RoomNumber"));
                res.setCheckIn(rs.getDate("CheckIn"));
                res.setCheckOut(rs.getDate("CheckOut"));
                res.setStatus(rs.getString("Status"));
                res.setTotalAmount(rs.getDouble("TotalAmount"));
                res.setCreatedAt(rs.getTimestamp("CreatedAt"));
                reservations.add(res);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Get reservations by date range
    public List<ReservationSummary> getReservationsByDateRange(Date startDate, Date endDate) {
        List<ReservationSummary> reservations = new ArrayList<>();
        String sql = "SELECT r.Id, u.FullName as CustomerName, " +
                    "rm.RoomNumber, r.CheckIn, r.CheckOut, r.Status, " +
                    "r.TotalAmount, r.CreatedAt " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE r.CheckIn >= ? AND r.CheckOut <= ? " +
                    "ORDER BY r.CheckIn";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, startDate);
            ps.setDate(2, endDate);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ReservationSummary res = new ReservationSummary();
                res.setId(rs.getInt("Id"));
                res.setCustomerName(rs.getString("CustomerName"));
                res.setRoomNumber(rs.getString("RoomNumber"));
                res.setCheckIn(rs.getDate("CheckIn"));
                res.setCheckOut(rs.getDate("CheckOut"));
                res.setStatus(rs.getString("Status"));
                res.setTotalAmount(rs.getDouble("TotalAmount"));
                res.setCreatedAt(rs.getTimestamp("CreatedAt"));
                reservations.add(res);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Get reservation count by status
    public int getReservationCountByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE Status = ?";
        
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
    
    // Get total reservations count
    public int getTotalReservations() {
        String sql = "SELECT COUNT(*) FROM Reservations";
        
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
}