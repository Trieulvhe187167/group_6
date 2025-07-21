package dal;

import static dal.DBContext.getConnection;
import model.Reservation;
import model.ReservationDetail;
import model.ReservationSummary;
import java.sql.*;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {
    public boolean cancelBooking(int bookingId) {
    String getCheckInSql = "SELECT CheckIn FROM Reservations WHERE Id = ?";
   String sql = """
    UPDATE Reservations
    SET Status = 'CANCELLED',
        DepositStatus = ?,     -- LOST / REFUNDED
        UpdatedAt = GETDATE()
    WHERE Id = ?
""";


    try (Connection conn = DBContext.getConnection()) {
        // Lấy thời gian CheckIn
        LocalDateTime checkIn = null;
        try (PreparedStatement ps = conn.prepareStatement(getCheckInSql)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    checkIn = rs.getTimestamp("CheckIn").toLocalDateTime();
                }
            }
        }

        if (checkIn == null) return false;

        // Tính xem có huỷ trễ hay không
        LocalDateTime now = LocalDateTime.now();
        long hoursDiff = Duration.between(now, checkIn).toHours();
        String depositStatus = hoursDiff >= 24 ? "REFUNDED" : "LOST";

        // Thực hiện cập nhật huỷ
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, depositStatus);
            ps.setInt(2, bookingId);
            return ps.executeUpdate() > 0;
        }

    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}


    public List<Reservation> getUpcomingBookings(int userId) {
        String sql = """
            SELECT r.*, room.RoomNumber, 
                   rt.Name AS roomTypeName, rt.BasePrice,
                   u.Phone AS CustomerPhone,
                   u.Email AS CustomerEmail,
                   u.FullName AS CustomerName
            FROM Reservations r
            JOIN Rooms room ON r.RoomId = room.Id
            JOIN RoomTypes rt ON room.RoomTypeId = rt.Id
            JOIN Users u ON r.UserId = u.Id
           WHERE r.UserId = ?
                            AND r.Status IN ('PENDING', 'CONFIRMED', 'CHECKIN')
                            AND r.CheckOut >= CAST(GETDATE() AS DATE)
                      """;
                      return executeBookingQuery(sql, userId);
                  }
              
                  // Get reservations where the user is currently staying (today between check-in and check-out)
       public List<Reservation> getActiveStays(int userId) {
                      String sql = """
                          SELECT r.*, room.RoomNumber,
                                 rt.Name AS roomTypeName, rt.BasePrice,
                                 u.Phone AS CustomerPhone,
                                 u.Email AS CustomerEmail,
                                 u.FullName AS CustomerName
                          FROM Reservations r
                          JOIN Rooms room ON r.RoomId = room.Id
                          JOIN RoomTypes rt ON room.RoomTypeId = rt.Id
                          JOIN Users u ON r.UserId = u.Id
                          WHERE r.UserId = ?
                            AND r.Status = 'CONFIRMED'
                                     
        """;
//                         AND r.CheckIn <= CAST(GETDATE() AS DATE)
//                                        AND r.CheckOut >= CAST(GETDATE() AS DATE)
        return executeBookingQuery(sql, userId);
    }

    public List<Reservation> getPastBookings(int userId, String status, String fromDate, String toDate) {
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection()) {
            StringBuilder sql = new StringBuilder("""
                SELECT r.*, room.RoomNumber, 
                       rt.Name AS roomTypeName, rt.BasePrice,
                       u.Phone AS CustomerPhone,
                       u.Email AS CustomerEmail,
                       u.FullName AS CustomerName,
                       f.Id AS FeedbackId, f.Rating AS FeedbackRating, f.Comment AS FeedbackComment
                FROM Reservations r
                JOIN Rooms room ON r.RoomId = room.Id
                JOIN RoomTypes rt ON room.RoomTypeId = rt.Id
                JOIN Users u ON r.UserId = u.Id
                LEFT JOIN (
                    SELECT f1.*
                    FROM Feedback f1
                    INNER JOIN (
                        SELECT ReservationId, MAX(Id) AS MaxId
                        FROM Feedback
                        GROUP BY ReservationId
                    ) f2 ON f1.ReservationId = f2.ReservationId AND f1.Id = f2.MaxId
                ) f ON r.Id = f.ReservationId
                WHERE r.UserId = ?
                  AND (r.Status IN ('COMPLETED', 'CANCELLED') 
                       OR (r.Status = 'CHECKIN' AND r.CheckOut < CAST(GETDATE() AS DATE)))
            """);

            if (status != null && !status.isEmpty()) {
                sql.append(" AND r.Status = ?");
            }
            if (fromDate != null && !fromDate.isEmpty()) {
                sql.append(" AND r.CheckIn >= ?");
            }
            if (toDate != null && !toDate.isEmpty()) {
                sql.append(" AND r.CheckOut <= ?");
            }

            sql.append(" ORDER BY r.CheckOut DESC");
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            int index = 1;
            ps.setInt(index++, userId);

            if (status != null && !status.isEmpty()) {
                ps.setString(index++, status);
            }
            if (fromDate != null && !fromDate.isEmpty()) {
                ps.setDate(index++, Date.valueOf(fromDate));
            }
            if (toDate != null && !toDate.isEmpty()) {
                ps.setDate(index++, Date.valueOf(toDate));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Reservation booking = mapResultSetToReservation(rs);
                int rating = 0;
                String comment = "";
                try {
                    rating = rs.getInt("FeedbackRating");
                    if (rs.wasNull()) rating = 0;
                } catch (Exception ignore) {}
                try {
                    comment = rs.getString("FeedbackComment");
                    if (comment == null) comment = "";
                } catch (Exception ignore) {}
                booking.setRating(rating);
                booking.setComment(comment);
                list.add(booking);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private List<Reservation> executeBookingQuery(String sql, int userId) {
        List<Reservation> list = new ArrayList<>();
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Reservation r = mapResultSetToReservation(rs);
                r.setRoomName(rs.getString("roomNumber"));
                r.setRoomTypeName(rs.getString("roomTypeName"));
                r.setBasePrice(rs.getDouble("BasePrice"));
                r.setCustomerPhone(rs.getString("CustomerPhone"));
                r.setCustomerEmail(rs.getString("CustomerEmail"));
                r.setUserFullName(rs.getString("CustomerName"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

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
    String sql = """
    SELECT r.Id, r.UserId, r.RoomId, r.CheckIn, r.CheckOut, r.Status, r.TotalAmount,
           rt.Name AS RoomTypeName, room.RoomNumber,
           (SELECT TOP 1 f.Rating FROM Feedback f WHERE f.ReservationId = r.Id) AS Rating
    FROM Reservations r
    JOIN Rooms room ON r.RoomId = room.Id
    JOIN RoomTypes rt ON room.RoomTypeId = rt.Id
    WHERE r.UserId = ?
    ORDER BY r.CheckIn DESC
""";


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
            // Check null rating
           booking.setRating(rs.getInt("Rating")); // không cần rs.wasNull()

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
       String sql = """
    SELECT 
        r.Id, r.UserId, r.GroupBookingId, r.CreatedBy, r.RoomId, r.RoomTypeId,
        r.CheckIn, r.CheckOut, r.Status, r.TotalAmount, r.Notes, r.SpecialRequests,
        r.NumberOfCustomers, r.CreatedAt, r.UpdatedAt,
        u.FullName AS CustomerName,
        u.Email AS CustomerEmail,
        u.Phone AS CustomerPhone,
        room.RoomNumber,
        rt.Name AS RoomTypeName,
        DATEDIFF(DAY, r.CheckIn, r.CheckOut) AS Nights,
        p.Status AS PaymentStatus
    FROM Reservations r
    LEFT JOIN Users u ON r.UserId = u.Id
    LEFT JOIN Rooms room ON r.RoomId = room.Id
    LEFT JOIN RoomTypes rt ON room.RoomTypeId = rt.Id
    OUTER APPLY (
        SELECT TOP 1 Status
        FROM Payments
        WHERE ReservationId = r.Id
        ORDER BY CreatedAt DESC
    ) p
    WHERE r.Id = ?
""";

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
   public Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
    Reservation reservation = new Reservation();

    // Các trường chính
    reservation.setId(rs.getInt("Id"));
    reservation.setUserId(rs.getInt("UserId"));
    reservation.setGroupBookingId(rs.getObject("GroupBookingId") != null ? rs.getInt("GroupBookingId") : null);
    reservation.setCreatedBy(rs.getInt("CreatedBy"));
    reservation.setRoomId(rs.getInt("RoomId"));
    reservation.setRoomTypeId(rs.getInt("RoomTypeId"));
    reservation.setCheckIn(rs.getDate("CheckIn"));
    reservation.setCheckOut(rs.getDate("CheckOut"));
    reservation.setStatus(rs.getString("Status"));
    reservation.setTotalAmount(rs.getDouble("TotalAmount"));
    reservation.setNotes(rs.getString("Notes"));
    reservation.setSpecialRequests(rs.getString("SpecialRequests"));
    reservation.setNumberOfCustomers(rs.getInt("NumberOfCustomers"));
    reservation.setCreatedAt(rs.getTimestamp("CreatedAt"));
    reservation.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
    ResultSetMetaData metaData = rs.getMetaData();
int columnCount = metaData.getColumnCount();
for (int i = 1; i <= columnCount; i++) {
    System.out.println("Column " + i + ": " + metaData.getColumnLabel(i));
}
    // Các thông tin bổ sung từ bảng liên kết
    
    reservation.setCustomerPhone(rs.getString("CustomerPhone"));
    reservation.setCustomerEmail(rs.getString("CustomerEmail"));
    // Preserve both legacy customerName and new userFullName fields
    String custName = rs.getString("CustomerName");
    reservation.setUserFullName(custName);
    reservation.setCustomerName(custName);
    reservation.setRoomNumber(rs.getString("RoomNumber"));
    reservation.setRoomTypeName(rs.getString("RoomTypeName"));
 
    // Các thông tin thêm nếu có
    try {
        reservation.setNights(rs.getInt("Nights"));
    } catch (SQLException ignore) {}

    try {
        reservation.setPaymentStatus(rs.getString("PaymentStatus"));
    } catch (SQLException ignore) {}

    // Sau khi set các trường chính, thêm:
    try {
        int rating = 0;
        String comment = "";
        ResultSetMetaData meta = rs.getMetaData();
        int colCount = meta.getColumnCount();
        boolean hasRating = false, hasComment = false;
        for (int i = 1; i <= colCount; i++) {
            String col = meta.getColumnLabel(i);
            if ("Rating".equalsIgnoreCase(col)) hasRating = true;
            if ("Comment".equalsIgnoreCase(col)) hasComment = true;
        }
        if (hasRating) {
            rating = rs.getInt("Rating");
            if (rs.wasNull()) rating = 0;
        }
        if (hasComment) {
            comment = rs.getString("Comment");
            if (comment == null) comment = "";
        }
        reservation.setRating(rating);
        reservation.setComment(comment);
    } catch (Exception ignore) {}

    try {
        reservation.setFeedbackId(rs.getObject("FeedbackId") != null ? rs.getInt("FeedbackId") : null);
    } catch (Exception ignore) {}

    return reservation;
}
        public int getTotalReservationCount(String statusFilter, String fromDate, String toDate) 
            throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM reservations r WHERE 1=1 ");
        
        List<Object> parameters = new ArrayList<>();
        
        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append("AND r.Status = ? ");
            parameters.add(statusFilter);
        }
        
        if (fromDate != null && !fromDate.isEmpty()) {
            sql.append("AND r.CheckIn >= ? ");
            parameters.add(fromDate);
        }
        
        if (toDate != null && !toDate.isEmpty()) {
            sql.append("AND r.CheckOut <= ? ");
            parameters.add(toDate);
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        
        return 0;
    }
       public List<Reservation> getReservations(String status, String fromDate, String toDate, int offset, int limit) {
    List<Reservation> reservations = new ArrayList<>();
    
    StringBuilder sql = new StringBuilder("""
        SELECT 
            r.Id, r.UserId, r.GroupBookingId, r.CreatedBy, r.RoomId, r.RoomTypeId,
            r.CheckIn, r.CheckOut, r.Status, r.TotalAmount, r.Notes, r.SpecialRequests,
            r.NumberOfCustomers, r.CreatedAt, r.UpdatedAt,
            u.FullName AS CustomerName,
            u.Email AS CustomerEmail,
            u.Phone AS CustomerPhone,
            room.RoomNumber,
            rt.Name AS RoomTypeName,
            DATEDIFF(DAY, r.CheckIn, r.CheckOut) AS Nights,
            p.Status AS PaymentStatus
        FROM Reservations r
        LEFT JOIN Users u ON r.UserId = u.Id
        LEFT JOIN Rooms room ON r.RoomId = room.Id
        LEFT JOIN RoomTypes rt ON room.RoomTypeId = rt.Id
        LEFT JOIN Payments p ON r.Id = p.ReservationId
        WHERE 1=1
    """);

    if (status != null && !status.isEmpty()) {
        sql.append(" AND r.Status = ?");
    }
    if (fromDate != null && !fromDate.isEmpty()) {
        sql.append(" AND r.CheckIn >= ?");
    }
    if (toDate != null && !toDate.isEmpty()) {
        sql.append(" AND r.CheckOut <= ?");
    }

    sql.append(" ORDER BY r.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql.toString())) {

        int paramIndex = 1;
        if (status != null && !status.isEmpty()) {
            ps.setString(paramIndex++, status);
        }
        if (fromDate != null && !fromDate.isEmpty()) {
            ps.setString(paramIndex++, fromDate);
        }
        if (toDate != null && !toDate.isEmpty()) {
            ps.setString(paramIndex++, toDate);
        }
        ps.setInt(paramIndex++, offset);
        ps.setInt(paramIndex, limit);

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            reservations.add(mapResultSetToReservation(rs));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    return reservations;
}
public boolean isRoomAvailableForNewBooking(int roomId, Date checkIn, Date checkOut) {
    return isRoomAvailableForUpdate(roomId, checkIn, checkOut, -1); // -1 để đảm bảo không trùng Id nào
}

public boolean isRoomAvailableForUpdate(int roomId, Date checkIn, Date checkOut, int excludeReservationId) {
    String sql = "SELECT COUNT(*) FROM Reservations " +
                 "WHERE RoomId = ? AND Status IN ('CONFIRMED', 'PENDING') " +
                 "AND NOT (CheckOut <= ? OR CheckIn >= ?) " +
                 "AND Id != ?";

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, roomId);
        ps.setDate(2, checkIn);
        ps.setDate(3, checkOut);
        ps.setInt(4, excludeReservationId);

        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            int count = rs.getInt(1);
            System.out.println("Room check update - roomId: " + roomId + ", conflicts: " + count);
            return count == 0;
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
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

    /**
     * Get reservations by user ID with feedback information
     */
    public List<Reservation> getReservationsByUserIdWithFeedback(int userId) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = "SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, " +
                    "rm.RoomNumber, rt.Name as RoomTypeName, cb.FullName as CreatedByName, " +
                    "f.Rating, f.Comment " +
                    "FROM Reservations r " +
                    "INNER JOIN Users u ON r.UserId = u.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users cb ON r.CreatedBy = cb.Id " +
                    "LEFT JOIN Feedback f ON r.Id = f.ReservationId " +
                    "WHERE r.UserId = ? " +
                    "ORDER BY r.CheckIn DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Reservation reservation = mapResultSetToReservation(rs);
                // Set rating and comment from feedback table
                reservation.setRating(rs.getInt("Rating"));
                reservation.setComment(rs.getString("Comment"));
                reservations.add(reservation);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }

    /**
     * Get reservations by user ID with feedback information, with filter and sort
     */
    /**
 * Get reservations by user ID with feedback information, with filter and sort - FIXED VERSION
 */
public List<Reservation> getReservationsByUserIdWithFeedbackFiltered(int userId, String filter, String sort) {
    System.out.println("=== DAO: getReservationsByUserIdWithFeedbackFiltered called ===");
    System.out.println("=== DAO: userId=" + userId + ", filter=" + filter + ", sort=" + sort);
    
    List<Reservation> reservations = new ArrayList<>();
    StringBuilder sql = new StringBuilder("""
        SELECT r.*, u.FullName as CustomerName, u.Email as CustomerEmail, u.Phone as CustomerPhone, 
               rm.RoomNumber, rt.Name as RoomTypeName, cb.FullName as CreatedByName, 
               f.Rating AS FeedbackRating, f.Comment AS FeedbackComment 
        FROM Reservations r 
        INNER JOIN Users u ON r.UserId = u.Id 
        INNER JOIN Rooms rm ON r.RoomId = rm.Id 
        INNER JOIN RoomTypes rt ON rm.RoomTypeId = rt.Id 
        LEFT JOIN Users cb ON r.CreatedBy = cb.Id 
        LEFT JOIN (
            SELECT f1.*
            FROM Feedback f1
            INNER JOIN (
                SELECT ReservationId, MAX(Id) AS MaxId
                FROM Feedback
                GROUP BY ReservationId
            ) f2 ON f1.ReservationId = f2.ReservationId AND f1.Id = f2.MaxId
        ) f ON r.Id = f.ReservationId
        WHERE r.UserId = ? AND r.Status = 'COMPLETED'
    """);

    // Apply filter
    if ("rated".equals(filter)) {
        sql.append(" AND f.Rating IS NOT NULL AND f.Rating > 0");
    } else if ("unrated".equals(filter)) {
        sql.append(" AND (f.Rating IS NULL OR f.Rating = 0)");
    }
    // "all" filter doesn't add any condition

    // Apply sort - FIXED to handle all sort options
    switch (sort) {
        case "date_asc":
            sql.append(" ORDER BY r.CheckOut ASC, r.CheckIn ASC");
            break;
        case "date_desc":
        case "date": // backward compatibility
            sql.append(" ORDER BY r.CheckOut DESC, r.CheckIn DESC");
            break;
        case "rating_asc":
            sql.append(" ORDER BY COALESCE(f.Rating, 0) ASC, r.CheckOut DESC");
            break;
        case "rating_desc":
        case "rating": // backward compatibility
            sql.append(" ORDER BY COALESCE(f.Rating, 0) DESC, r.CheckOut DESC");
            break;
        case "room_asc":
            sql.append(" ORDER BY rm.RoomNumber ASC");
            break;
        case "room_desc":
            sql.append(" ORDER BY rm.RoomNumber DESC");
            break;
        case "checkin_asc":
            sql.append(" ORDER BY r.CheckIn ASC");
            break;
        case "checkin_desc":
            sql.append(" ORDER BY r.CheckIn DESC");
            break;
        case "checkout_asc":
            sql.append(" ORDER BY r.CheckOut ASC");
            break;
        case "checkout_desc":
            sql.append(" ORDER BY r.CheckOut DESC");
            break;
        default:
            // Default to checkout date descending
            sql.append(" ORDER BY r.CheckOut DESC, r.CheckIn DESC");
            break;
    }
    
    System.out.println("=== DAO: SQL Query: " + sql.toString());
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql.toString())) {
        
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Reservation reservation = mapResultSetToReservation(rs);
            int rating = 0;
            String comment = "";
            try {
                rating = rs.getInt("FeedbackRating");
                if (rs.wasNull()) rating = 0;
            } catch (Exception ignore) {}
            try {
                comment = rs.getString("FeedbackComment");
                if (comment == null) comment = "";
            } catch (Exception ignore) {}
            reservation.setRating(rating);
            reservation.setComment(comment);
            System.out.println("[DEBUG] ReservationId: " + reservation.getId() + ", Rating: " + reservation.getRating() + ", Comment: " + reservation.getComment());
            reservations.add(reservation);
        }
        
        System.out.println("=== DAO: Found " + reservations.size() + " reservations");
        
    } catch (SQLException e) {
        System.out.println("=== DAO: SQL Error: " + e.getMessage());
        e.printStackTrace();
    }
    return reservations;
}

  

   
}
