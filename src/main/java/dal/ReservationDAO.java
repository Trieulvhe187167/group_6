package dal;


import model.Reservation;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;

public class ReservationDAO extends DBContext {
    
    // Get pending reservations count
    public int getPendingReservationsCount() {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE Status = 'PENDING'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Get confirmed reservations count
    public int getConfirmedReservationsCount() {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE Status = 'CONFIRMED'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Get today check-ins count
    public int getTodayCheckInsCount() {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE CheckIn = CAST(GETDATE() AS DATE) AND Status IN ('PENDING', 'CONFIRMED')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Get today check-outs count
    public int getTodayCheckOutsCount() {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE CheckOut = CAST(GETDATE() AS DATE) AND Status = 'CONFIRMED'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Get monthly revenue
    public double getMonthlyRevenue() {
        String sql = "SELECT SUM(TotalAmount) FROM Reservations " +
                     "WHERE MONTH(CheckIn) = MONTH(GETDATE()) " +
                     "AND YEAR(CheckIn) = YEAR(GETDATE()) " +
                     "AND Status IN ('CONFIRMED', 'COMPLETED')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get yearly revenue
    public double getYearlyRevenue() {
        String sql = "SELECT SUM(TotalAmount) FROM Reservations " +
                     "WHERE YEAR(CheckIn) = YEAR(GETDATE()) " +
                     "AND Status IN ('CONFIRMED', 'COMPLETED')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get recent reservations
    public List<Reservation> getRecentReservations(int limit) {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT TOP " + limit + " r.*, u.FullName as CustomerName, rm.RoomNumber " +
                     "FROM Reservations r " +
                     "JOIN Users u ON r.UserId = u.Id " +
                     "JOIN Rooms rm ON r.RoomId = rm.Id " +
                     "ORDER BY r.CreatedAt DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Reservation r = new Reservation();
                r.setId(rs.getInt("Id"));
                r.setUserId(rs.getInt("UserId"));
                r.setRoomId(rs.getInt("RoomId"));
                r.setCheckIn(rs.getDate("CheckIn"));
                r.setCheckOut(rs.getDate("CheckOut"));
                r.setStatus(rs.getString("Status"));
                r.setTotalAmount(rs.getBigDecimal("TotalAmount"));
                r.setCustomerName(rs.getString("CustomerName"));
                r.setRoomNumber(rs.getString("RoomNumber"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Get pending check-ins for today
    public int getPendingCheckInsToday() {
        String sql = "SELECT COUNT(*) FROM Reservations " +
                     "WHERE CheckIn = CAST(GETDATE() AS DATE) " +
                     "AND Status = 'PENDING'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Get pending check-outs for today
    public int getPendingCheckOutsToday() {
        String sql = "SELECT COUNT(*) FROM Reservations " +
                     "WHERE CheckOut = CAST(GETDATE() AS DATE) " +
                     "AND Status = 'CONFIRMED'";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Get today's check-ins list
    public List<Reservation> getTodayCheckInsList() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as GuestName, rm.RoomNumber " +
                     "FROM Reservations r " +
                     "JOIN Users u ON r.UserId = u.Id " +
                     "JOIN Rooms rm ON r.RoomId = rm.Id " +
                     "WHERE r.CheckIn = CAST(GETDATE() AS DATE) " +
                     "AND r.Status IN ('PENDING', 'CONFIRMED') " +
                     "ORDER BY r.CheckIn";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Reservation r = new Reservation();
                r.setId(rs.getInt("Id"));
                r.setGuestName(rs.getString("GuestName"));
                r.setRoomNumber(rs.getString("RoomNumber"));
                r.setCheckIn(rs.getTimestamp("CheckIn"));
                r.setStatus(rs.getString("Status"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Get today's check-outs list
    public List<Reservation> getTodayCheckOutsList() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as GuestName, rm.RoomNumber " +
                     "FROM Reservations r " +
                     "JOIN Users u ON r.UserId = u.Id " +
                     "JOIN Rooms rm ON r.RoomId = rm.Id " +
                     "WHERE r.CheckOut = CAST(GETDATE() AS DATE) " +
                     "AND r.Status = 'CONFIRMED' " +
                     "ORDER BY r.CheckOut";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Reservation r = new Reservation();
                r.setId(rs.getInt("Id"));
                r.setGuestName(rs.getString("GuestName"));
                r.setRoomNumber(rs.getString("RoomNumber"));
                r.setCheckOut(rs.getTimestamp("CheckOut"));
                r.setStatus(rs.getString("Status"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Thêm vào ReservationDAO.java
public List<Reservation> getAllReservations() {
    List<Reservation> list = new ArrayList<>();
    String sql = "SELECT r.*, u.FullName as CustomerName, rm.RoomNumber " +
                 "FROM Reservations r " +
                 "JOIN Users u ON r.UserId = u.Id " +
                 "JOIN Rooms rm ON r.RoomId = rm.Id " +
                 "ORDER BY r.CreatedAt DESC";
    
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        
        while (rs.next()) {
            Reservation r = new Reservation();
            r.setId(rs.getInt("Id"));
            r.setUserId(rs.getInt("UserId"));
            r.setRoomId(rs.getInt("RoomId"));
            r.setCheckIn(rs.getDate("CheckIn"));
            r.setCheckOut(rs.getDate("CheckOut"));
            r.setStatus(rs.getString("Status"));
            r.setTotalAmount(rs.getBigDecimal("TotalAmount"));
            r.setCustomerName(rs.getString("CustomerName"));
            r.setRoomNumber(rs.getString("RoomNumber"));
            r.setCreatedAt(rs.getTimestamp("CreatedAt"));
            list.add(r);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}
}