package dal;


import model.*;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class CheckInOutDAO {
    
    // Get today's check-ins count
    public int getTodayCheckIns(Date today) {
        String sql = "SELECT COUNT(*) FROM Reservations " +
                    "WHERE CheckIn = ? AND Status IN ('CONFIRMED', 'PENDING')";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, today);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Get today's check-outs count
    public int getTodayCheckOuts(Date today) {
        String sql = "SELECT COUNT(*) FROM Reservations " +
                    "WHERE CheckOut = ? AND Status = 'CONFIRMED'";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, today);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    // Get number of check-outs completed today
    public int getCompletedCheckOuts(Date today) {
        String sql = "SELECT COUNT(*) FROM CheckOutDetails WHERE CAST(CheckOutTime AS DATE) = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, today);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    // Get upcoming check-ins for next N hours
    public List<ReservationSummary> getUpcomingCheckIns(int hours) {
        List<ReservationSummary> checkIns = new ArrayList<>();
        String sql = "SELECT r.Id, u.FullName as CustomerName, rm.RoomNumber, " +
                    "r.CheckIn, r.CheckOut, r.Status, r.TotalAmount, r.CreatedAt " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE r.CheckIn = CAST(GETDATE() AS DATE) " +
                    "AND r.Status IN ('CONFIRMED', 'PENDING') " +
                    "AND NOT EXISTS (SELECT 1 FROM CheckInDetails WHERE ReservationId = r.Id) " +
                    "ORDER BY r.CheckIn";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
                checkIns.add(res);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return checkIns;
    }
    
    // Get upcoming check-outs for next N hours
    public List<ReservationSummary> getUpcomingCheckOuts(int hours) {
        List<ReservationSummary> checkOuts = new ArrayList<>();
        String sql = "SELECT r.Id, u.FullName as CustomerName, rm.RoomNumber, " +
                    "r.CheckIn, r.CheckOut, r.Status, r.TotalAmount, r.CreatedAt " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE r.CheckOut = CAST(GETDATE() AS DATE) " +
                    "AND r.Status = 'CONFIRMED' " +
                    "AND EXISTS (SELECT 1 FROM CheckInDetails WHERE ReservationId = r.Id) " +
                    "AND NOT EXISTS (SELECT 1 FROM CheckOutDetails WHERE ReservationId = r.Id) " +
                    "ORDER BY r.CheckOut";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ReservationSummary res = new ReservationSummary();
                res.setId(rs.getInt("Id"));
                res.setCustomerName(rs.getString("CustomerName"));
                res.setRoomNumber(rs.getString("RoomNumber"));
                res.setCheckIn(rs.getDate("CheckIn"));
                res.setCheckOut(rs.getDate("CheckOut"));
                
                      // Default check-in/out times
                LocalDate checkInDate = res.getCheckIn().toLocalDate();
                LocalDate checkOutDate = res.getCheckOut().toLocalDate();
                res.setCheckInTime(Timestamp.valueOf(LocalDateTime.of(checkInDate, LocalTime.of(14, 0))));
                res.setCheckOutTime(Timestamp.valueOf(LocalDateTime.of(checkOutDate, LocalTime.of(13, 0))));
                
                res.setStatus(rs.getString("Status"));
                res.setTotalAmount(rs.getDouble("TotalAmount"));
                res.setCreatedAt(rs.getTimestamp("CreatedAt"));
                checkOuts.add(res);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return checkOuts;
    }
    
    // Create check-in record
    public boolean createCheckIn(CheckInDetail checkIn) {
        String sql = "INSERT INTO CheckInDetails (ReservationId, IdType, IdNumber, " +
                    "AdditionalGuests, SpecialRequests, SecurityDeposit, KeyCards, " +
                    "KeyCardNumbers, CheckInNotes, CheckInTime, CheckInBy) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, checkIn.getReservationId());
            ps.setString(2, checkIn.getIdType());
            ps.setString(3, checkIn.getIdNumber());
            ps.setInt(4, checkIn.getAdditionalGuests());
            ps.setString(5, checkIn.getSpecialRequests());
            ps.setDouble(6, checkIn.getSecurityDeposit());
            ps.setInt(7, checkIn.getKeyCards());
            ps.setString(8, checkIn.getKeyCardNumbers());
            ps.setString(9, checkIn.getCheckInNotes());
            ps.setInt(10, checkIn.getCheckInBy());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Create check-out record
    public boolean createCheckOut(CheckOutDetail checkOut) {
        String sql = "INSERT INTO CheckOutDetails (ReservationId, RoomCondition, " +
                    "DamageDescription, DamageCharges, AmenityCharges, ServiceCharges, " +
                    "FinalAmount, RefundAmount, PaymentMethod, CheckOutNotes, " +
                    "CheckOutTime, CheckOutBy) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, checkOut.getReservationId());
            ps.setString(2, checkOut.getRoomCondition());
            ps.setString(3, checkOut.getDamageDescription());
            ps.setDouble(4, checkOut.getDamageCharges());
            ps.setDouble(5, checkOut.getAmenityCharges());
            ps.setDouble(6, checkOut.getServiceCharges());
            ps.setDouble(7, checkOut.getFinalAmount());
            ps.setDouble(8, checkOut.getRefundAmount());
            ps.setString(9, checkOut.getPaymentMethod());
            ps.setString(10, checkOut.getCheckOutNotes());
            ps.setInt(11, checkOut.getCheckOutBy());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get check-in details
    public CheckInDetail getCheckInDetails(int reservationId) {
        String sql = "SELECT c.*, u.FullName as CheckInByName " +
                    "FROM CheckInDetails c " +
                    "INNER JOIN Users u ON c.CheckInBy = u.Id " +
                    "WHERE c.ReservationId = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                CheckInDetail checkIn = new CheckInDetail();
                checkIn.setId(rs.getInt("Id"));
                checkIn.setReservationId(rs.getInt("ReservationId"));
                checkIn.setIdType(rs.getString("IdType"));
                checkIn.setIdNumber(rs.getString("IdNumber"));
                checkIn.setAdditionalGuests(rs.getInt("AdditionalGuests"));
                checkIn.setSpecialRequests(rs.getString("SpecialRequests"));
                checkIn.setSecurityDeposit(rs.getDouble("SecurityDeposit"));
                checkIn.setKeyCards(rs.getInt("KeyCards"));
                checkIn.setKeyCardNumbers(rs.getString("KeyCardNumbers"));
                checkIn.setCheckInNotes(rs.getString("CheckInNotes"));
                checkIn.setCheckInTime(rs.getTimestamp("CheckInTime"));
                checkIn.setCheckInBy(rs.getInt("CheckInBy"));
                checkIn.setCheckInByName(rs.getString("CheckInByName"));
                return checkIn;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Check if reservation is already checked in
    public boolean isCheckedIn(int reservationId) {
        String sql = "SELECT COUNT(*) FROM CheckInDetails WHERE ReservationId = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Check if reservation is already checked out
    public boolean isCheckedOut(int reservationId) {
        String sql = "SELECT COUNT(*) FROM CheckOutDetails WHERE ReservationId = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}