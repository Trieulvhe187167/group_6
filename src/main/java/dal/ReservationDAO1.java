package dal;

import model.Reservation;
import model.ReservationDetail;
import model.ReservationSummary;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO1 {
    
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
    
    // Get all reservations with customer and room details
    public List<Reservation> getAllReservations() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, cb.FullName as CreatedByName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users cb ON r.CreatedBy = cb.Id " +
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
        sql.append("r.TotalAmount, r.CreatedAt, r.SpecialRequests, r.NumberOfGuests ");
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
                res.setNumberOfGuests(rs.getInt("NumberOfGuests"));
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
    
    // Get reservation by ID
    public Reservation getReservationById(int id) {
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, cb.FullName as CreatedByName " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users cb ON r.CreatedBy = cb.Id " +
                    "WHERE r.Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToReservation(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
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
                detail.setNumberOfGuests(rs.getInt("NumberOfGuests"));
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
        String sql = "SELECT r.*, u.FullName as GuestName FROM Reservations r " +
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
                reservation.setGuestName(rs.getString("GuestName"));
                return reservation;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get current reservation by room ID
    public Reservation getCurrentReservationByRoom(int roomId) {
        String sql = "SELECT r.*, u.FullName as GuestName FROM Reservations r " +
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
                reservation.setGuestName(rs.getString("GuestName"));
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
                    "Status, TotalAmount, SpecialRequests, NumberOfGuests, Notes, CreatedAt) " +
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
            ps.setInt(10, reservation.getNumberOfGuests());
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
                    "Status = ?, TotalAmount = ?, SpecialRequests = ?, NumberOfGuests = ?, " +
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
            ps.setInt(8, reservation.getNumberOfGuests());
            ps.setString(9, reservation.getNotes());
            ps.setInt(10, reservation.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update reservation status
    public boolean updateReservationStatus(int reservationId, String status) {
        String sql = "UPDATE Reservations SET Status = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, reservationId);
            
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
                    "r.TotalAmount, r.CreatedAt, r.SpecialRequests, r.NumberOfGuests " +
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
                res.setNumberOfGuests(rs.getInt("NumberOfGuests"));
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
    
    // Get guest booking history
    public List<ReservationSummary> getGuestBookingHistory(int guestId) {
        List<ReservationSummary> bookings = new ArrayList<>();
        String sql = "SELECT r.Id, u.FullName as CustomerName, u.Phone as CustomerPhone, u.Email as CustomerEmail, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, r.CheckIn, r.CheckOut, r.Status, " +
                    "r.TotalAmount, r.CreatedAt, r.SpecialRequests, r.NumberOfGuests " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "WHERE r.UserId = ? " +
                    "ORDER BY r.CheckIn DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, guestId);
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
                booking.setNumberOfGuests(rs.getInt("NumberOfGuests"));
                bookings.add(booking);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }
    
    /**
     * Get reservation count for a guest
     * @param guestId Guest user ID
     * @return Number of reservations
     */
    public int getGuestReservationCount(int guestId) {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE UserId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, guestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error getting guest reservation count: " + e.getMessage());
        }
        return 0;
    }
    
    /**
     * Get total amount spent by a guest
     * @param guestId Guest user ID
     * @return Total amount spent
     */
    public double getGuestTotalSpent(int guestId) {
        String sql = "SELECT COALESCE(SUM(TotalAmount), 0) FROM Reservations WHERE UserId = ? AND Status IN ('CONFIRMED', 'COMPLETED')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, guestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error getting guest total spent: " + e.getMessage());
        }
        return 0.0;
    }
    
    /**
     * Get last visit date for a guest
     * @param guestId Guest user ID
     * @return Last check-out date
     */
    public Date getGuestLastVisit(int guestId) {
        String sql = "SELECT MAX(CheckOut) FROM Reservations WHERE UserId = ? AND Status = 'COMPLETED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, guestId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDate(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error getting guest last visit: " + e.getMessage());
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
    
    // Helper method to map ResultSet to Reservation
    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        reservation.setId(rs.getInt("Id"));
        reservation.setUserId(rs.getInt("UserId"));
        
        // Handle nullable fields
        int groupBookingId = rs.getInt("GroupBookingId");
        if (!rs.wasNull()) {
            reservation.setGroupBookingId(groupBookingId);
        }
        
        int createdBy = rs.getInt("CreatedBy");
        if (!rs.wasNull()) {
            reservation.setCreatedBy(createdBy);
        }
        
        reservation.setRoomId(rs.getInt("RoomId"));
        reservation.setCheckIn(rs.getDate("CheckIn"));
        reservation.setCheckOut(rs.getDate("CheckOut"));
        reservation.setStatus(rs.getString("Status"));
        reservation.setTotalAmount(rs.getDouble("TotalAmount"));
        
        // Handle SpecialRequests and Notes - check which column exists
        try {
            reservation.setSpecialRequests(rs.getString("SpecialRequests"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        try {
            reservation.setNotes(rs.getString("Notes"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        try {
            reservation.setNumberOfGuests(rs.getInt("NumberOfGuests"));
        } catch (SQLException e) {
            // Column might not exist
        }
        
        reservation.setCreatedAt(rs.getTimestamp("CreatedAt"));
        
        // Additional display fields
        reservation.setCustomerName(rs.getString("CustomerName"));
        reservation.setCustomerEmail(rs.getString("CustomerEmail"));
        reservation.setCustomerPhone(rs.getString("CustomerPhone"));
        reservation.setRoomNumber(rs.getString("RoomNumber"));
        reservation.setRoomTypeName(rs.getString("RoomTypeName"));
        
        try {
            reservation.setCreatedByName(rs.getString("CreatedByName"));
        } catch (SQLException e) {
            // Column might not exist in some queries
        }
        
        // Calculate nights
        if (reservation.getCheckIn() != null && reservation.getCheckOut() != null) {
            long diffInMillies = reservation.getCheckOut().getTime() - reservation.getCheckIn().getTime();
            reservation.setNights((int) (diffInMillies / (1000 * 60 * 60 * 24)));
        }
        
        return reservation;
    }
}