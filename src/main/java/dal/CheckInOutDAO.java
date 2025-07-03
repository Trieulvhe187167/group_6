package dal;


import model.*;
import java.sql.*;
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
    
    // Get upcoming check-ins for next N hours
    public List<ReservationSummary> getUpcomingCheckIns(int hours) {
        List<ReservationSummary> checkIns = new ArrayList<>();
        String sql = "SELECT r.Id, u.FullName as CustomerName, rm.RoomNumber, " +
                    "r.CheckIn, r.CheckOut, r.Status, r.TotalAmount, r.CreatedAt " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE r.CheckIn = CAST(GETDATE() AS DATE) " +
                    "AND r.Status = 'CONFIRMED' " +
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
    
    /**
     * Create a new check-in record
     * @param checkIn The check-in details
     * @return true if successful, false otherwise
     */
    public boolean createCheckIn(CheckInDetail checkIn) {
        Connection conn = null;
        try {
            // Start transaction
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);
            
            // Create check-in record
            String sql = "INSERT INTO CheckInDetails (ReservationId, IdType, IdNumber, AdditionalGuests, " +
                         "SpecialRequests, SecurityDeposit, KeyCards, KeyCardNumbers, CheckInNotes, " +
                         "CheckInTime, EstimatedCheckOutTime, CheckInBy) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, checkIn.getReservationId());
            ps.setString(2, checkIn.getIdType());
            ps.setString(3, checkIn.getIdNumber());
            ps.setInt(4, checkIn.getAdditionalGuests());
            ps.setString(5, checkIn.getSpecialRequests());
            ps.setDouble(6, checkIn.getSecurityDeposit());
            ps.setInt(7, checkIn.getKeyCards());
            ps.setString(8, checkIn.getKeyCardNumbers());
            ps.setString(9, checkIn.getCheckInNotes());
            
            // Use timestamp for estimated check-out time
            if (checkIn.getEstimatedCheckOutTime() != null) {
                ps.setTimestamp(10, new java.sql.Timestamp(checkIn.getEstimatedCheckOutTime().getTime()));
            } else {
                ps.setNull(10, java.sql.Types.TIMESTAMP);
            }
            
            ps.setInt(11, checkIn.getCheckInBy());
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows == 0) {
                conn.rollback();
                return false;
            }
            
            // Update reservation status to CHECKED_IN
            sql = "UPDATE Reservations SET Status = 'CHECKED_IN' WHERE Id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, checkIn.getReservationId());
            ps.executeUpdate();
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
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
    
    /**
     * Get check-in details for a reservation
     * @param reservationId The ID of the reservation
     * @return CheckInDetail object if found, null otherwise
     */
    public CheckInDetail getCheckInDetails(int reservationId) {
        CheckInDetail checkInDetail = null;
        try {
            String sql = "SELECT * FROM CheckInDetails WHERE ReservationId = ?";
            PreparedStatement ps = DBContext.getConnection().prepareStatement(sql);
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                checkInDetail = new CheckInDetail();
                checkInDetail.setId(rs.getInt("Id"));
                checkInDetail.setReservationId(rs.getInt("ReservationId"));
                checkInDetail.setIdType(rs.getString("IdType"));
                checkInDetail.setIdNumber(rs.getString("IdNumber"));
                checkInDetail.setAdditionalGuests(rs.getInt("AdditionalGuests"));
                checkInDetail.setSecurityDeposit(rs.getDouble("SecurityDeposit"));
                checkInDetail.setKeyCards(rs.getInt("KeyCards"));
                checkInDetail.setKeyCardNumbers(rs.getString("KeyCardNumbers"));
                checkInDetail.setCheckInNotes(rs.getString("CheckInNotes"));
                checkInDetail.setCheckInTime(rs.getTimestamp("CheckInTime"));
                
                // Check if EstimatedCheckOutTime column exists and is not null
                try {
                    Timestamp estimatedCheckOut = rs.getTimestamp("EstimatedCheckOutTime");
                    if (!rs.wasNull()) {
                        checkInDetail.setEstimatedCheckOutTime(estimatedCheckOut);
                    }
                } catch (SQLException e) {
                    // Column might not exist in older schema versions
                    // Just continue without setting this field
                }
                
                checkInDetail.setCheckInBy(rs.getInt("CheckInBy"));
            }
            
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return checkInDetail;
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

    /**
     * Get active check-ins for calendar display
     * @return List of check-in details for currently occupied rooms
     */
    public List<CheckInCalendarDTO> getActiveCheckIns(Date startDate, Date endDate) {
        List<CheckInCalendarDTO> result = new ArrayList<>();
        
        try {
            String sql = "SELECT c.Id, c.ReservationId, c.CheckInTime, c.EstimatedCheckOutTime, " +
                         "c.IdType, c.IdNumber, r.RoomId, rm.RoomNumber, u.FullName AS CustomerName " +
                         "FROM CheckInDetails c " +
                         "INNER JOIN Reservations r ON c.ReservationId = r.Id " +
                         "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                         "INNER JOIN Users u ON r.UserId = u.Id " +
                         "WHERE (c.CheckInTime <= ? AND (c.EstimatedCheckOutTime >= ? OR c.EstimatedCheckOutTime IS NULL)) " +
                         "AND rm.Status = 'OCCUPIED'";
            
            PreparedStatement ps = DBContext.getConnection().prepareStatement(sql);
            ps.setDate(1, new java.sql.Date(endDate.getTime()));
            ps.setDate(2, new java.sql.Date(startDate.getTime()));
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                CheckInCalendarDTO dto = new CheckInCalendarDTO();
                dto.setId(rs.getInt("Id"));
                dto.setReservationId(rs.getInt("ReservationId"));
                dto.setRoomId(rs.getInt("RoomId"));
                dto.setRoomNumber(rs.getString("RoomNumber"));
                dto.setCustomerName(rs.getString("CustomerName"));
                dto.setIdType(rs.getString("IdType"));
                dto.setIdNumber(rs.getString("IdNumber"));
                dto.setCheckInTime(rs.getTimestamp("CheckInTime"));
                dto.setEstimatedCheckOutTime(rs.getTimestamp("EstimatedCheckOutTime"));
                
                result.add(dto);
            }
            
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return result;
    }
}