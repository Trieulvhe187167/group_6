package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.sql.Date;
import model.Reservation;

public class BookingDAO {
    public List<Reservation> getUpcomingBookings(int userId) {
    String sql = """
        SELECT r.*, room.RoomNumber, 
               rt.Name AS roomTypeName, rt.BasePrice,
               u.Phone AS UserPhone,
               u.Email AS CustomerEmail,
               u.FullName AS UserFullName
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

public List<Reservation> getPastBookings(int userId) {
    String sql = """
        SELECT r.*, room.RoomNumber, 
               rt.Name AS roomTypeName, rt.BasePrice,
               u.Phone AS UserPhone,
               u.Email AS CustomerEmail,
               u.FullName AS UserFullName
        FROM Reservations r
        JOIN Rooms room ON r.RoomId = room.Id
        JOIN RoomTypes rt ON room.RoomTypeId = rt.Id
        JOIN Users u ON r.UserId = u.Id
        WHERE r.UserId = ? 
          AND (r.Status IN ('COMPLETED', 'CANCELLED') 
               OR (r.Status = 'CHECKIN' AND r.CheckOut < CAST(GETDATE() AS DATE)))
    """;
    return executeBookingQuery(sql, userId);
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
            r.setCustomerPhone(rs.getString("UserPhone")); // <== Đọc alias vừa thêm
            r.setCustomerEmail(rs.getString("CustomerEmail"));
            r.setUserFullName(rs.getString("UserFullName"));

            list.add(r);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}

    
    /**
     * Get reservations with filtering and pagination
     */
    public List<Reservation> getReservations(String statusFilter, String fromDate, String toDate, 
                                           int offset, int limit) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder();
sql.append("SELECT r.Id, r.UserId, r.GroupBookingId, r.CreatedBy, r.RoomId, r.RoomTypeId, ");
sql.append("r.CheckIn, r.CheckOut, r.Status, r.TotalAmount, r.Notes, r.SpecialRequests, ");
sql.append("r.NumberOfCustomers, r.CreatedAt, r.UpdatedAt, ");
sql.append("u.FullName as UserFullName, u.Email as CustomerEmail, u.Phone as UserPhone, ");
sql.append("room.RoomNumber, rt.Name as RoomTypeName ");
sql.append("FROM reservations r ");
sql.append("LEFT JOIN Users u ON r.UserId = u.Id ");
sql.append("LEFT JOIN rooms room ON r.RoomId = room.Id ");
sql.append("LEFT JOIN roomtypes rt ON r.Id = rt.Id ");
sql.append("WHERE 1=1 ");
        List<Object> parameters = new ArrayList<>();
        
        // Add filters
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

// Order + pagination (SQL Server style)
sql.append("ORDER BY r.CreatedAt DESC ");
sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY ");
parameters.add(offset);          // OFFSET comes first
parameters.add(limit);           // THEN FETCH NEXT

try (Connection conn = DBContext.getConnection();
     PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

    for (int i = 0; i < parameters.size(); i++) {
        stmt.setObject(i + 1, parameters.get(i));
    }

    try (ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
            Reservation reservation = mapResultSetToReservation(rs);
            reservations.add(reservation);
        }
    }
        }
        
        return reservations;
    }

    /**
     * Get total count of reservations with filtering
     */
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

    /**
     * Get a single reservation by ID
     */
   public Reservation getReservationById(int reservationId) throws SQLException {
    String sql = """
    SELECT r.Id, r.UserId, r.GroupBookingId, r.CreatedBy, r.RoomId, r.RoomTypeId,
           r.CheckIn, r.CheckOut, r.Status, r.TotalAmount, r.Notes, r.SpecialRequests,
           r.NumberOfCustomers, r.CreatedAt, r.UpdatedAt,
           u.FullName AS UserFullName, u.Email AS CustomerEmail, u.Phone AS UserPhone,
           room.RoomNumber, rt.Name AS RoomTypeName,
           DATEDIFF(DAY, r.CheckIn, r.CheckOut) AS Nights,
           p.Status AS PaymentStatus
    FROM reservations r
    LEFT JOIN Users u ON r.UserId = u.Id
    LEFT JOIN rooms room ON r.RoomId = room.Id
    LEFT JOIN roomtypes rt ON r.Id = rt.Id
    LEFT JOIN payments p ON r.Id = p.ReservationId
    WHERE r.Id = ?
""";


    try (Connection conn = DBContext.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setInt(1, reservationId);

        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                Reservation res = new Reservation();
                res.setId(rs.getInt("Id"));
                res.setUserId(rs.getInt("UserId"));
                res.setGroupBookingId(rs.getObject("GroupBookingId") != null ? rs.getInt("GroupBookingId") : null);
                res.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
                res.setRoomId(rs.getObject("RoomId") != null ? rs.getInt("RoomId") : null);
                res.setRoomTypeId(rs.getObject("RoomTypeId") != null ? rs.getInt("RoomTypeId") : null);
                res.setCheckIn(rs.getDate("CheckIn"));
                res.setCheckOut(rs.getDate("CheckOut"));
                res.setStatus(rs.getString("Status"));
                res.setTotalAmount(rs.getDouble("TotalAmount"));
                res.setNotes(rs.getString("Notes"));
                res.setSpecialRequests(rs.getString("SpecialRequests"));
                res.setNumberOfCustomers(rs.getInt("NumberOfCustomers"));
                res.setCreatedAt(rs.getTimestamp("CreatedAt"));
                res.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                
                // Thêm thông tin cho popup
                res.setUserFullName(rs.getString("UserFullName"));
                res.setUserEmail(rs.getString("CustomerEmail"));
                res.setCustomerPhone(rs.getString("UserPhone"));

                res.setRoomNumber(rs.getString("RoomNumber"));
                res.setRoomTypeName(rs.getString("RoomTypeName"));
                res.setNights(rs.getInt("Nights"));
                res.setPaymentStatus(rs.getString("PaymentStatus"));
                
                return res;
            }
        }
    }

    return null;
}

    /**
     * Update reservation status
     */
    public boolean updateReservationStatus(int reservationId, String status) throws SQLException {
        String sql = "UPDATE reservations SET Status = ?, UpdatedAt = CURRENT_TIMESTAMP WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, reservationId);
            
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Get reservations by user ID
     */
    public List<Reservation> getReservationsByUserId(int userId) throws SQLException {
        List<Reservation> reservations = new ArrayList<>();
        
        String sql = 
    "SELECT r.Id, r.UserId, r.GroupBookingId, r.CreatedBy, r.RoomId, r.RoomTypeId, " +
    "r.CheckIn, r.CheckOut, r.Status, r.TotalAmount, r.Notes, r.SpecialRequests, " +
    "r.NumberOfCustomers, r.CreatedAt, r.UpdatedAt, " +
    "u.FullName AS UserFullName, u.Email AS CustomerEmail, " +
    "room.RoomNumber, rt.Name AS RoomTypeName " +
    "FROM reservations r " +
    "LEFT JOIN Users u ON r.UserId = u.Id " +
    "LEFT JOIN rooms room ON r.RoomId = room.Id " +
    "LEFT JOIN roomtypes rt ON r.Id = rt.Id " +
    "WHERE r.UserId = ? " +
    "ORDER BY r.CreatedAt DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        }
        
        return reservations;
    }

    /**
     * Create a new reservation
     */
    public int createReservation(Reservation reservation) throws SQLException {
        String sql = "INSERT INTO reservations (UserId, GroupBookingId, CreatedBy, RoomId, RoomTypeId, " +
                    "CheckIn, CheckOut, Status, TotalAmount, Notes, SpecialRequests, NumberOfCustomers, " +
                    "CreatedAt, UpdatedAt) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, reservation.getUserId());
            stmt.setObject(2, reservation.getGroupBookingId());
            stmt.setInt(3, reservation.getCreatedBy());
            stmt.setInt(4, reservation.getRoomId());
            stmt.setInt(5, reservation.getRoomTypeId());
            stmt.setDate(6, reservation.getCheckIn());
            stmt.setDate(7, reservation.getCheckOut());
            stmt.setString(8, reservation.getStatus());
            stmt.setDouble(9, reservation.getTotalAmount());
            stmt.setString(10, reservation.getNotes());
            stmt.setString(11, reservation.getSpecialRequests());
            stmt.setInt(12, reservation.getNumberOfCustomers());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        
        return -1;
    }

    /**
     * Update reservation
     */
    public boolean updateReservation(Reservation reservation) throws SQLException {
        String sql = "UPDATE reservations SET UserId = ?, GroupBookingId = ?, RoomId = ?, RoomTypeId = ?, " +
                    "CheckIn = ?, CheckOut = ?, Status = ?, TotalAmount = ?, Notes = ?, SpecialRequests = ?, " +
                    "NumberOfCustomers = ?, UpdatedAt = CURRENT_TIMESTAMP WHERE Id = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, reservation.getUserId());
            stmt.setObject(2, reservation.getGroupBookingId());
            stmt.setInt(3, reservation.getRoomId());
            stmt.setInt(4, reservation.getRoomTypeId());
            stmt.setDate(5, reservation.getCheckIn());
            stmt.setDate(6, reservation.getCheckOut());
            stmt.setString(7, reservation.getStatus());
            stmt.setDouble(8, reservation.getTotalAmount());
            stmt.setString(9, reservation.getNotes());
            stmt.setString(10, reservation.getSpecialRequests());
            stmt.setInt(11, reservation.getNumberOfCustomers());
            stmt.setInt(12, reservation.getId());
            
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Delete reservation
     */
    public boolean deleteReservation(int reservationId) throws SQLException {
        String sql = "DELETE FROM reservations WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, reservationId);
            
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Get reservations by status
     */
    public List<Reservation> getReservationsByStatus(String status) throws SQLException {
        return getReservations(status, null, null, 0, Integer.MAX_VALUE);
    }

    /**
     * Check if room is available for given dates
     */
    public boolean isRoomAvailable(int roomId, java.sql.Date checkIn, java.sql.Date checkOut, Integer excludeReservationId) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) FROM reservations WHERE RoomId = ? ");
        sql.append("AND Status NOT IN ('CANCELLED', 'REJECTED') ");
        sql.append("AND ((CheckIn <= ? AND CheckOut > ?) OR (CheckIn < ? AND CheckOut >= ?)) ");
        
        List<Object> parameters = new ArrayList<>();
        parameters.add(roomId);
        parameters.add(checkIn);
        parameters.add(checkIn);
        parameters.add(checkOut);
        parameters.add(checkOut);
        
        if (excludeReservationId != null) {
            sql.append("AND Id != ? ");
            parameters.add(excludeReservationId);
        }

        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                stmt.setObject(i + 1, parameters.get(i));
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }
        }
        
        return false;
    }

    /**
     * Helper method to map ResultSet to Reservation object
     */
    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation reservation = new Reservation();
        reservation.setId(rs.getInt("Id"));
        reservation.setUserId(rs.getInt("UserId"));
        reservation.setGroupBookingId(rs.getObject("GroupBookingId") != null ? 
                                    rs.getInt("GroupBookingId") : null);
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
        reservation.setCustomerPhone(rs.getString("UserPhone"));
        reservation.setCustomerEmail(rs.getString("CustomerEmail"));
        reservation.setRoomTypeName(rs.getString("RoomTypeName"));
        // Set additional fields for display
        reservation.setUserFullName(rs.getString("UserFullName"));
        reservation.setUserEmail(rs.getString("CustomerEmail"));
        reservation.setRoomNumber(rs.getString("RoomNumber"));
        reservation.setRoomName(rs.getString("RoomTypeName"));
        
        return reservation;
    }
    
}
