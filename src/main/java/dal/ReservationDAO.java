package dal;

import static dal.DBContext.getConnection;
import model.Reservation;
import model.ReservationDetail;
import model.ReservationSummary;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {
    
    // Get today's check-ins count
    public int getTodayCheckInsCount() {
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
    
    // Get today's check-ins list
    public List<Reservation> getTodayCheckIns() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, cb.FullName as CreatedByName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users cb ON r.CreatedBy = cb.Id " +
                    "WHERE r.CheckIn = CAST(GETDATE() AS DATE) " +
                    "AND r.Status IN ('CONFIRMED', 'PENDING') " +
                    "ORDER BY r.CreatedAt";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
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
        String sql = "SELECT r.Id, u.FullName as CustomerName, r.UserId, u.Phone as CustomerPhone, u.Email as CustomerEmail, " +
                    "r.RoomId, rm.RoomNumber, r.CheckIn, r.CheckOut, r.Status, " +
                    "r.TotalAmount, r.CreatedAt, r.SpecialRequests, r.NumberOfCustomers " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE (r.CheckIn <= ? AND r.CheckOut >= ?) " + 
                    "AND r.Status IN ('CONFIRMED', 'PENDING') " +
                    "ORDER BY r.CheckIn";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, endDate);    // End date is less than or equal to check-in
            ps.setDate(2, startDate);  // Start date is greater than or equal to check-out
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ReservationSummary res = new ReservationSummary();
                res.setId(rs.getInt("Id"));
                res.setCustomerName(rs.getString("CustomerName"));
                res.setCustomerPhone(rs.getString("CustomerPhone"));
                res.setCustomerEmail(rs.getString("CustomerEmail"));
                res.setRoomId(rs.getInt("RoomId"));
                res.setRoomNumber(rs.getString("RoomNumber"));
                res.setCheckIn(rs.getDate("CheckIn"));
                res.setCheckOut(rs.getDate("CheckOut"));
                
                // Create timestamps from date for check-in and check-out times
                // Default check-in time to 14:00 (2 PM)
                Timestamp checkInTs = new Timestamp(rs.getDate("CheckIn").getTime());
                checkInTs.setHours(14);
                checkInTs.setMinutes(0);
                checkInTs.setSeconds(0);
                res.setCheckInTime(checkInTs);
                
                // Default check-out time to 12:00 (noon)
                Timestamp checkOutTs = new Timestamp(rs.getDate("CheckOut").getTime());
                checkOutTs.setHours(12);
                checkOutTs.setMinutes(0);
                checkOutTs.setSeconds(0);
                res.setCheckOutTime(checkOutTs);
                
                res.setStatus(rs.getString("Status"));
                res.setTotalAmount(rs.getDouble("TotalAmount"));
                res.setCreatedAt(rs.getTimestamp("CreatedAt"));
                res.setSpecialRequests(rs.getString("SpecialRequests"));
                res.setNumberOfCustomers(rs.getInt("NumberOfCustomers"));
                
                reservations.add(res);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
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
    
    // Get today's expected revenue
    public double getTodayExpectedRevenue(Date today) {
        String sql = "SELECT ISNULL(SUM(r.TotalAmount), 0) as TotalRevenue " +
                    "FROM Reservations r " +
                    "WHERE (r.CheckIn = ? OR r.CheckOut = ?) " +
                    "AND r.Status IN ('CONFIRMED', 'PENDING')";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, today);
            ps.setDate(2, today);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("TotalRevenue");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Get today's check-outs count
    public int getTodayCheckOutsCount() {
        String sql = "SELECT COUNT(*) FROM Reservations " +
                    "WHERE CheckOut = CAST(GETDATE() AS DATE) " +
                    "AND Status IN ('CONFIRMED', 'COMPLETED')";
        
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
    
    // Get today's check-outs list
    public List<Reservation> getTodayCheckOuts() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, cb.FullName as CreatedByName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users cb ON r.CreatedBy = cb.Id " +
                    "WHERE r.CheckOut = CAST(GETDATE() AS DATE) " +
                    "AND r.Status = 'CONFIRMED' " +
                    "ORDER BY r.CreatedAt";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Get reservations with filters (for ReservationSummary)
    public List<ReservationSummary> getReservationsWithFilters(String status, String checkInDate, String checkOutDate, String search) {
        List<ReservationSummary> reservations = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.Id, u.FullName as CustomerName, u.Phone as CustomerPhone, u.Email as CustomerEmail, ");
        sql.append("rm.RoomNumber, rt.Name as RoomTypeName, r.CheckIn, r.CheckOut, r.Status, ");
        sql.append("r.TotalAmount, r.CreatedAt, r.SpecialRequests, r.NumberOfCustomers ");
        sql.append("FROM Reservations r ");
        sql.append("INNER JOIN Users u ON r.UserId = u.Id ");
        sql.append("INNER JOIN Rooms rm ON r.RoomId = rm.Id ");
        sql.append("INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> parameters = new ArrayList<>();
        
        if (status != null && !status.isEmpty()) {
            sql.append("AND r.Status = ? ");
            parameters.add(status);
        }
        
        if (checkInDate != null && !checkInDate.isEmpty()) {
            sql.append("AND r.CheckIn >= ? ");
            parameters.add(Date.valueOf(checkInDate));
        }
        
        if (checkOutDate != null && !checkOutDate.isEmpty()) {
            sql.append("AND r.CheckOut <= ? ");
            parameters.add(Date.valueOf(checkOutDate));
        }
        
        if (search != null && !search.isEmpty()) {
            sql.append("AND (u.FullName LIKE ? OR rm.RoomNumber LIKE ? OR CAST(r.Id AS VARCHAR) LIKE ?) ");
            String searchPattern = "%" + search + "%";
            parameters.add(searchPattern);
            parameters.add(searchPattern);
            parameters.add(searchPattern);
        }
        
        sql.append("ORDER BY r.CreatedAt DESC");
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ReservationSummary res = new ReservationSummary();
                res.setId(rs.getInt("Id"));
                res.setCustomerName(rs.getString("CustomerName"));
                res.setCustomerPhone(rs.getString("CustomerPhone"));
                res.setCustomerEmail(rs.getString("CustomerEmail"));
                res.setRoomNumber(rs.getString("RoomNumber"));
                res.setRoomTypeName(rs.getString("RoomTypeName"));
                res.setCheckIn(rs.getDate("CheckIn"));
                res.setCheckOut(rs.getDate("CheckOut"));
                res.setStatus(rs.getString("Status"));
                res.setTotalAmount(rs.getDouble("TotalAmount"));
                res.setCreatedAt(rs.getTimestamp("CreatedAt"));
                res.setSpecialRequests(rs.getString("SpecialRequests"));
                res.setNumberOfCustomers(rs.getInt("NumberOfCustomers"));
                reservations.add(res);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Get reservations with filters (for Reservation objects)
    public List<Reservation> getReservationsWithFilters(String status, Date fromDate, Date toDate, String search) {
        List<Reservation> reservations = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, ");
        sql.append("rm.RoomNumber, rt.Name as RoomTypeName, cb.FullName as CreatedByName ");
        sql.append("FROM Reservations r ");
        sql.append("INNER JOIN Users u ON r.UserId = u.Id ");
        sql.append("INNER JOIN Rooms rm ON r.RoomId = rm.Id ");
        sql.append("INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id ");
        sql.append("LEFT JOIN Users cb ON r.CreatedBy = cb.Id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> params = new ArrayList<>();
        
        if (status != null && !status.isEmpty()) {
            sql.append("AND r.Status = ? ");
            params.add(status);
        }
        
        if (fromDate != null) {
            sql.append("AND r.CheckIn >= ? ");
            params.add(fromDate);
        }
        
        if (toDate != null) {
            sql.append("AND r.CheckOut <= ? ");
            params.add(toDate);
        }
        
        if (search != null && !search.isEmpty()) {
            sql.append("AND (u.FullName LIKE ? OR u.Phone LIKE ? OR rm.RoomNumber LIKE ? OR CAST(r.Id AS VARCHAR) LIKE ?) ");
            String searchPattern = "%" + search + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        sql.append("ORDER BY r.CreatedAt DESC");
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
  
    
    // Get reservation detail
    public ReservationDetail getReservationDetail(int id) {
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Phone as CustomerPhone, u.Email as CustomerEmail, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "WHERE r.Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                ReservationDetail detail = new ReservationDetail();
                detail.setId(rs.getInt("Id"));
                detail.setCustomerName(rs.getString("CustomerName"));
                detail.setCustomerPhone(rs.getString("CustomerPhone"));
                detail.setCustomerEmail(rs.getString("CustomerEmail"));
                detail.setRoomNumber(rs.getString("RoomNumber"));
                detail.setRoomTypeName(rs.getString("RoomTypeName"));
                detail.setCheckIn(rs.getDate("CheckIn"));
                detail.setCheckOut(rs.getDate("CheckOut"));
                detail.setStatus(rs.getString("Status"));
                detail.setTotalAmount(rs.getDouble("TotalAmount"));
                detail.setSpecialRequests(rs.getString("SpecialRequests"));
                detail.setNumberOfCustomers(rs.getInt("NumberOfCustomers"));
                detail.setCreatedAt(rs.getTimestamp("CreatedAt"));
                
                // Calculate nights
                long nights = (detail.getCheckOut().getTime() - detail.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
                detail.setNights((int) nights);
                
                return detail;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get reservations by user ID
    public List<Reservation> getReservationsByUserId(int userId) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, cb.FullName as CreatedByName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users cb ON r.CreatedBy = cb.Id " +
                    "WHERE r.UserId = ? " +
                    "ORDER BY r.CheckIn DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Get active reservation by room number
    public Reservation getActiveReservationByRoom(String roomNumber) {
        String sql = "SELECT r.*, u.FullName as CustomerName FROM Reservations r " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "WHERE rm.RoomNumber = ? AND r.Status = 'CONFIRMED' " +
                    "AND r.CheckIn <= CAST(GETDATE() AS DATE) " +
                    "AND r.CheckOut > CAST(GETDATE() AS DATE)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, roomNumber);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Reservation reservation = new Reservation();
                reservation.setId(rs.getInt("Id"));
                reservation.setUserId(rs.getInt("UserId"));
                reservation.setRoomId(rs.getInt("RoomId"));
                reservation.setCheckIn(rs.getDate("CheckIn"));
                reservation.setCheckOut(rs.getDate("CheckOut"));
                reservation.setStatus(rs.getString("Status"));
                reservation.setTotalAmount(rs.getDouble("TotalAmount"));
                reservation.setCustomerName(rs.getString("CustomerName"));
                return reservation;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get current reservation by room ID
    public Reservation getCurrentReservationByRoom(int roomId) {
        String sql = "SELECT r.*, u.FullName as CustomerName FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "WHERE r.RoomId = ? AND r.Status = 'CONFIRMED' " +
                    "AND r.CheckIn <= CAST(GETDATE() AS DATE) " +
                    "AND r.CheckOut > CAST(GETDATE() AS DATE)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Reservation reservation = new Reservation();
                reservation.setId(rs.getInt("Id"));
                reservation.setUserId(rs.getInt("UserId"));
                reservation.setRoomId(rs.getInt("RoomId"));
                reservation.setCheckIn(rs.getDate("CheckIn"));
                reservation.setCheckOut(rs.getDate("CheckOut"));
                reservation.setStatus(rs.getString("Status"));
                reservation.setTotalAmount(rs.getDouble("TotalAmount"));
                reservation.setCustomerName(rs.getString("CustomerName"));
                return reservation;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Create reservation (comprehensive version)
    public boolean createReservation(Reservation reservation) {
        String sql = "INSERT INTO Reservations (UserId, GroupBookingId, CreatedBy, RoomId, CheckIn, CheckOut, " +
                    "Status, TotalAmount, SpecialRequests, NumberOfCustomers, Notes, CreatedAt) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, reservation.getUserId());
            
            if (reservation.getGroupBookingId() != null) {
                ps.setInt(2, reservation.getGroupBookingId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            
            if (reservation.getCreatedBy() != null) {
                ps.setInt(3, reservation.getCreatedBy());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            
            ps.setInt(4, reservation.getRoomId());
            ps.setDate(5, reservation.getCheckIn());
            ps.setDate(6, reservation.getCheckOut());
            ps.setString(7, reservation.getStatus());
            ps.setDouble(8, reservation.getTotalAmount());
            ps.setString(9, reservation.getSpecialRequests());
            ps.setInt(10, reservation.getNumberOfCustomers());
            ps.setString(11, reservation.getNotes());
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                // Get the generated ID
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    reservation.setId(rs.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update reservation
    public boolean updateReservation(Reservation reservation) {
        String sql = "UPDATE Reservations SET UserId = ?, RoomId = ?, CheckIn = ?, CheckOut = ?, " +
                    "Status = ?, TotalAmount = ?, SpecialRequests = ?, NumberOfCustomers = ?, " +
                    "Notes = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservation.getUserId());
            ps.setInt(2, reservation.getRoomId());
            ps.setDate(3, reservation.getCheckIn());
            ps.setDate(4, reservation.getCheckOut());
            ps.setString(5, reservation.getStatus());
            ps.setDouble(6, reservation.getTotalAmount());
            ps.setString(7, reservation.getSpecialRequests());
            ps.setInt(8, reservation.getNumberOfCustomers());
            ps.setString(9, reservation.getNotes());
            ps.setInt(10, reservation.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    

    // Search reservations (returns ReservationSummary)
    public List<ReservationSummary> searchReservations(String query) {
        List<ReservationSummary> reservations = new ArrayList<>();
        String sql = "SELECT r.Id, u.FullName as CustomerName, u.Phone as CustomerPhone, u.Email as CustomerEmail, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, r.CheckIn, r.CheckOut, r.Status, " +
                    "r.TotalAmount, r.CreatedAt, r.SpecialRequests, r.NumberOfCustomers " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "WHERE u.FullName LIKE ? OR rm.RoomNumber LIKE ? OR CAST(r.Id AS VARCHAR) LIKE ? " +
                    "ORDER BY r.CheckIn DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + query + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ReservationSummary res = new ReservationSummary();
                res.setId(rs.getInt("Id"));
                res.setCustomerName(rs.getString("CustomerName"));
                res.setCustomerPhone(rs.getString("CustomerPhone"));
                res.setCustomerEmail(rs.getString("CustomerEmail"));
                res.setRoomNumber(rs.getString("RoomNumber"));
                res.setRoomTypeName(rs.getString("RoomTypeName"));
                res.setCheckIn(rs.getDate("CheckIn"));
                res.setCheckOut(rs.getDate("CheckOut"));
                res.setStatus(rs.getString("Status"));
                res.setTotalAmount(rs.getDouble("TotalAmount"));
                res.setCreatedAt(rs.getTimestamp("CreatedAt"));
                res.setSpecialRequests(rs.getString("SpecialRequests"));
                res.setNumberOfCustomers(rs.getInt("NumberOfCustomers"));
                reservations.add(res);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Search reservations (returns Reservation objects)
    public List<Reservation> searchReservationsFull(String keyword) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, cb.FullName as CreatedByName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users cb ON r.CreatedBy = cb.Id " +
                    "WHERE (u.FullName LIKE ? OR u.Phone LIKE ? OR rm.RoomNumber LIKE ? OR CAST(r.Id AS VARCHAR) LIKE ?) " +
                    "ORDER BY r.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Get customer booking history
    public List<ReservationSummary> getCustomerBookingHistory(int customerId) {
        List<ReservationSummary> bookings = new ArrayList<>();
        String sql = "SELECT r.Id, u.FullName as CustomerName, u.Phone as CustomerPhone, u.Email as CustomerEmail, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, r.CheckIn, r.CheckOut, r.Status, " +
                    "r.TotalAmount, r.CreatedAt, r.SpecialRequests, r.NumberOfCustomers " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "WHERE r.UserId = ? " +
                    "ORDER BY r.CheckIn DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                ReservationSummary booking = new ReservationSummary();
                booking.setId(rs.getInt("Id"));
                booking.setCustomerName(rs.getString("CustomerName"));
                booking.setCustomerPhone(rs.getString("CustomerPhone"));
                booking.setCustomerEmail(rs.getString("CustomerEmail"));
                booking.setRoomNumber(rs.getString("RoomNumber"));
                booking.setRoomTypeName(rs.getString("RoomTypeName"));
                booking.setCheckIn(rs.getDate("CheckIn"));
                booking.setCheckOut(rs.getDate("CheckOut"));
                booking.setStatus(rs.getString("Status"));
                booking.setTotalAmount(rs.getDouble("TotalAmount"));
                booking.setCreatedAt(rs.getTimestamp("CreatedAt"));
                booking.setSpecialRequests(rs.getString("SpecialRequests"));
                booking.setNumberOfCustomers(rs.getInt("NumberOfCustomers"));
                bookings.add(booking);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }
    
    /**
     * Get reservation count for a customer
     * @param customerId Customer user ID
     * @return Number of reservations
     */
    public int getCustomerReservationCount(int customerId) {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE UserId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error getting customer reservation count: " + e.getMessage());
        }
        return 0;
    }
    
    /**
     * Get total amount spent by a customer
     * @param customerId Customer user ID
     * @return Total amount spent
     */
    public double getCustomerTotalSpent(int customerId) {
        String sql = "SELECT COALESCE(SUM(TotalAmount), 0) FROM Reservations WHERE UserId = ? AND Status IN ('CONFIRMED', 'COMPLETED')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error getting customer total spent: " + e.getMessage());
        }
        return 0.0;
    }
    
    /**
     * Get last visit date for a customer
     * @param customerId Customer user ID
     * @return Last check-out date
     */
    public Date getCustomerLastVisit(int customerId) {
        String sql = "SELECT MAX(CheckOut) FROM Reservations WHERE UserId = ? AND Status = 'COMPLETED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDate(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error getting customer last visit: " + e.getMessage());
        }
        return null;
    }
    
    // Delete reservation
    public boolean deleteReservation(int reservationId) {
        String sql = "DELETE FROM Reservations WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
       
    // Create reservation and return the generated ID (without room assignment)
    public int createReservationAndGetId(Reservation reservation) {
        String sql = "INSERT INTO Reservations (UserId, GroupBookingId, CreatedBy, RoomId, RoomTypeId, " +
                    "CheckIn, CheckOut, Status, TotalAmount, Notes, DepositAmount, DepositStatus, CreatedAt) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            System.out.println("Executing reservation insert...");
            
            ps.setInt(1, reservation.getUserId());
            
            // Handle nullable GroupBookingId
            if (reservation.getGroupBookingId() != null) {
                ps.setInt(2, reservation.getGroupBookingId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            
            // Handle nullable CreatedBy
            if (reservation.getCreatedBy() != null) {
                ps.setInt(3, reservation.getCreatedBy());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            
            // Handle RoomId - if null or 0, set NULL (room not assigned yet)
            if (reservation.getRoomId() != null && reservation.getRoomId() > 0) {
                ps.setInt(4, reservation.getRoomId());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            
            // Handle RoomTypeId
            if (reservation.getRoomTypeId() != null) {
                ps.setInt(5, reservation.getRoomTypeId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            
            ps.setDate(6, reservation.getCheckIn());
            ps.setDate(7, reservation.getCheckOut());
            ps.setString(8, reservation.getStatus());
            ps.setDouble(9, reservation.getTotalAmount());

            // Handle nullable Notes
            if (reservation.getNotes() != null) {
                ps.setString(10, reservation.getNotes());
            } else {
                ps.setString(10, "");
            }

            // Deposit info
            if (reservation.getDepositAmount() != null) {
                ps.setDouble(11, reservation.getDepositAmount());
            } else {
                ps.setNull(11, Types.DOUBLE);
            }
            ps.setString(12, reservation.getDepositStatus());
            
            System.out.println("SQL: " + ps.toString());
            
            int affectedRows = ps.executeUpdate();
            System.out.println("Affected rows: " + affectedRows);
            
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int generatedId = rs.getInt(1);
                        System.out.println("Generated reservation ID: " + generatedId);
                        return generatedId;
                    }
                }
            }
            
        } catch (SQLException e) {
            System.err.println("SQL Error creating reservation: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // Check if room is available for date range
    public boolean isRoomAvailable(int roomId, Date checkIn, Date checkOut, Integer excludeReservationId) {
        String sql = "SELECT COUNT(*) FROM Reservations " +
                    "WHERE RoomId = ? AND Status IN ('CONFIRMED', 'PENDING') " +
                    "AND NOT (CheckOut <= ? OR CheckIn >= ?)";
        
        if (excludeReservationId != null) {
            sql += " AND Id != ?";
        }
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roomId);
            ps.setDate(2, checkIn);
            ps.setDate(3, checkOut);
            
            if (excludeReservationId != null) {
                ps.setInt(4, excludeReservationId);
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("Room availability check - Room ID: " + roomId + 
                                 ", CheckIn: " + checkIn + ", CheckOut: " + checkOut + 
                                 ", Conflicting reservations: " + count);
                return count == 0; // Return true if no conflicting reservations
            }
        } catch (SQLException e) {
            System.err.println("Error checking room availability: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Check if room type has availability for date range
    public boolean isRoomTypeAvailable(int roomTypeId, Date checkIn, Date checkOut) {
        String sql = "SELECT COUNT(*) as AvailableCount FROM Rooms r " +
                    "WHERE r.RoomTypeId = ? AND r.Status = 'AVAILABLE' " +
                    "AND r.Id NOT IN ( " +
                    "  SELECT DISTINCT res.RoomId FROM Reservations res " +
                    "  WHERE res.RoomId IS NOT NULL " +
                    "  AND res.Status IN ('CONFIRMED', 'PENDING') " +
                    "  AND NOT (res.CheckOut <= ? OR res.CheckIn >= ?) " +
                    ")";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roomTypeId);
            ps.setDate(2, checkIn);
            ps.setDate(3, checkOut);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int availableCount = rs.getInt("AvailableCount");
                System.out.println("Room type " + roomTypeId + " has " + availableCount + 
                                 " available rooms for dates " + checkIn + " to " + checkOut);
                return availableCount > 0;
            }
        } catch (SQLException e) {
            System.err.println("Error checking room type availability: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Get reservation by ID
    public Reservation getReservationById(int reservationId) {
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, " +
                    "u.Phone as CustomerPhone, " +
                    "CASE WHEN r.RoomId IS NOT NULL THEN rm.RoomNumber ELSE 'Not Assigned' END as RoomNumber, " +
                    "COALESCE(rt.Name, rt2.Name) as RoomTypeName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "LEFT JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "LEFT JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN RoomTypes rt2 ON r.RoomTypeId = rt2.Id " +
                    "WHERE r.Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToReservation(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Assign room to reservation (used during check-in)
    public boolean assignRoomToReservation(int reservationId, int roomId) {
        String sql = "UPDATE Reservations SET RoomId = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roomId);
            ps.setInt(2, reservationId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            System.err.println("Error assigning room to reservation: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Update reservation status
    public boolean updateReservationStatus(int reservationId, String newStatus) {
        String sql = "UPDATE Reservations SET Status = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, newStatus);
            ps.setInt(2, reservationId);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating reservation status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    // Get all reservations
    public List<Reservation> getAllReservations() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, " +
                    "u.Phone as CustomerPhone, " +
                    "CASE WHEN r.RoomId IS NOT NULL THEN rm.RoomNumber ELSE 'Not Assigned' END as RoomNumber, " +
                    "COALESCE(rt.Name, rt2.Name) as RoomTypeName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "LEFT JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "LEFT JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN RoomTypes rt2 ON r.RoomTypeId = rt2.Id " +
                    "ORDER BY r.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Get reservations by status
    public List<Reservation> getReservationsByStatus(String status) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, " +
                    "u.Phone as CustomerPhone, " +
                    "CASE WHEN r.RoomId IS NOT NULL THEN rm.RoomNumber ELSE 'Not Assigned' END as RoomNumber, " +
                    "COALESCE(rt.Name, rt2.Name) as RoomTypeName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "LEFT JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "LEFT JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN RoomTypes rt2 ON r.RoomTypeId = rt2.Id " +
                    "WHERE r.Status = ? " +
                    "ORDER BY r.CheckIn";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
    
    // Get today's check-ins (reservations without room assignments)
    public List<Reservation> getTodayCheckInsWithoutRoom() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, " +
                    "u.Phone as CustomerPhone, " +
                    "'Not Assigned' as RoomNumber, " +
                    "rt.Name as RoomTypeName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "LEFT JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "WHERE r.RoomId IS NULL " +
                    "AND r.Status IN ('PENDING', 'CONFIRMED') " +
                    "AND r.CheckIn = CAST(GETDATE() AS DATE) " +
                    "ORDER BY r.CreatedAt";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
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
    
    // Helper method to map ResultSet to Reservation
    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        reservation.setId(rs.getInt("Id"));
        reservation.setUserId(rs.getInt("UserId"));
        reservation.setGroupBookingId(rs.getObject("GroupBookingId") != null ? rs.getInt("GroupBookingId") : null);
        reservation.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
        reservation.setRoomId(rs.getObject("RoomId") != null ? rs.getInt("RoomId") : null);
        
        // Try to get RoomTypeId if it exists
        try {
            reservation.setRoomTypeId(rs.getObject("RoomTypeId") != null ? rs.getInt("RoomTypeId") : null);
        } catch (SQLException e) {
            // Column might not exist in older tables
        }
        
        reservation.setCheckIn(rs.getDate("CheckIn"));
        reservation.setCheckOut(rs.getDate("CheckOut"));
        reservation.setStatus(rs.getString("Status"));
        reservation.setTotalAmount(rs.getDouble("TotalAmount"));
        reservation.setNotes(rs.getString("Notes"));
        reservation.setCreatedAt(rs.getTimestamp("CreatedAt"));

        // Deposit fields (may not exist in some queries)
        try {
            reservation.setDepositAmount(rs.getObject("DepositAmount") != null ? rs.getDouble("DepositAmount") : null);
            reservation.setDepositPaidDate(rs.getDate("DepositPaidDate"));
            reservation.setDepositStatus(rs.getString("DepositStatus"));
        } catch (SQLException e) {
            // ignore if columns not present
        }
        
        // Additional fields if available
        try {
            reservation.setCustomerName(rs.getString("CustomerName"));
            reservation.setCustomerEmail(rs.getString("CustomerEmail"));
            reservation.setCustomerPhone(rs.getString("CustomerPhone"));
            reservation.setRoomNumber(rs.getString("RoomNumber"));
            reservation.setRoomTypeName(rs.getString("RoomTypeName"));
        } catch (SQLException e) {
            // These fields might not be in all queries
        }
        
        // Calculate nights
        if (reservation.getCheckIn() != null && reservation.getCheckOut() != null) {
            reservation.calculateNights();
        }
        
        return reservation;
    }
   public boolean updateDepositStatus(int reservationId, String depositStatus) {
    String sql = "UPDATE Reservations SET DepositStatus = ?, UpdatedAt = GETDATE() WHERE Id = ?";
    
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        
        stmt.setString(1, depositStatus);
        stmt.setInt(2, reservationId);
        
        return stmt.executeUpdate() > 0;
        
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}

    // Get current reservation for a room (used for occupied rooms)
    public ReservationSummary getCurrentRoomReservationSummary(int roomId) {
        String sql = "SELECT r.Id, u.FullName as CustomerName, r.UserId, u.Phone as CustomerPhone, u.Email as CustomerEmail, " +
                    "r.RoomId, rm.RoomNumber, r.CheckIn, r.CheckOut, r.Status, " +
                    "r.TotalAmount, r.CreatedAt, r.SpecialRequests, r.NumberOfCustomers " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE r.RoomId = ? " +
                    "AND r.Status = 'CONFIRMED' " +
                    "AND r.CheckIn <= CAST(GETDATE() AS DATE) " +
                    "AND r.CheckOut >= CAST(GETDATE() AS DATE)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                ReservationSummary res = new ReservationSummary();
                res.setId(rs.getInt("Id"));
                res.setCustomerName(rs.getString("CustomerName"));
                res.setCustomerPhone(rs.getString("CustomerPhone"));
                res.setCustomerEmail(rs.getString("CustomerEmail"));
                res.setRoomId(rs.getInt("RoomId"));
                res.setRoomNumber(rs.getString("RoomNumber"));
                res.setCheckIn(rs.getDate("CheckIn"));
                res.setCheckOut(rs.getDate("CheckOut"));
                
                // Create timestamps from date for check-in and check-out times
                // For current occupancies, set check-in to 00:00 and check-out to 24:00
                Timestamp checkInTs = new Timestamp(rs.getDate("CheckIn").getTime());
                checkInTs.setHours(0);
                checkInTs.setMinutes(0);
                checkInTs.setSeconds(0);
                res.setCheckInTime(checkInTs);
                
                Timestamp checkOutTs = new Timestamp(rs.getDate("CheckOut").getTime());
                checkOutTs.setHours(23);
                checkOutTs.setMinutes(59);
                checkOutTs.setSeconds(59);
                res.setCheckOutTime(checkOutTs);
                
                res.setStatus(rs.getString("Status"));
                res.setTotalAmount(rs.getDouble("TotalAmount"));
                res.setCreatedAt(rs.getTimestamp("CreatedAt"));
                res.setSpecialRequests(rs.getString("SpecialRequests"));
                res.setNumberOfCustomers(rs.getInt("NumberOfCustomers"));
                
                return res;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}

