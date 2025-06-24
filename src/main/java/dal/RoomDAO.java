package dal;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import model.Room;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import jakarta.persistence.criteria.Predicate;

public class RoomDAO {

    // Get all rooms with room type details
    public List<Room> getAllRooms() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // Get rooms by status
    public List<Room> getRoomsByStatus(String status) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.Status = ? "
                + "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // Get available rooms
    public List<Room> getAvailableRooms() {
        return getRoomsByStatus("AVAILABLE");
    }

    // Get rooms by room type
    public List<Room> getRoomsByType(int roomTypeId) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.RoomTypeId = ? "
                + "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomTypeId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // Get room by ID
    public Room getRoomById(int id) {
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.Id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToRoom(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Get room by room number
    public Room getRoomByNumber(String roomNumber) {
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.RoomNumber = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, roomNumber);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToRoom(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Search rooms
    public List<Room> searchRooms(String keyword, String status) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE (r.RoomNumber LIKE ? OR rt.Name LIKE ?) ";

        if (status != null && !status.equals("ALL")) {
            sql += "AND r.Status = ? ";
        }

        sql += "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            if (status != null && !status.equals("ALL")) {
                ps.setString(3, status);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // Create new room
    public boolean createRoom(Room room) {
        String sql = "INSERT INTO Rooms (RoomNumber, RoomTypeId, Status) VALUES (?, ?, ?)";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, room.getRoomNumber());
            ps.setInt(2, room.getRoomTypeId());
            ps.setString(3, room.getStatus());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update room
    public boolean updateRoom(Room room) {
        String sql = "UPDATE Rooms SET RoomNumber = ?, RoomTypeId = ?, Status = ? WHERE Id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, room.getRoomNumber());
            ps.setInt(2, room.getRoomTypeId());
            ps.setString(3, room.getStatus());
            ps.setInt(4, room.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Update room status
    public boolean updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE Rooms SET Status = ? WHERE Id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, roomId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Delete room
    public boolean deleteRoom(int roomId) {
        // Check if room has any reservations
        if (hasReservations(roomId)) {
            return false;
        }

        String sql = "DELETE FROM Rooms WHERE Id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Check if room exists
    public boolean isRoomNumberExists(String roomNumber, Integer excludeId) {
        String sql = "SELECT COUNT(*) FROM Rooms WHERE RoomNumber = ?";
        if (excludeId != null) {
            sql += " AND Id != ?";
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, roomNumber);
            if (excludeId != null) {
                ps.setInt(2, excludeId);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return true;
    }

    // Check if room has reservations
    public boolean hasReservations(int roomId) {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE RoomId = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get room statistics
    public int[] getRoomStatistics() {
        int[] stats = new int[4]; // [available, occupied, maintenance, dirty]
        String sql = "SELECT Status, COUNT(*) as Count FROM Rooms GROUP BY Status";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String status = rs.getString("Status");
                int count = rs.getInt("Count");

                switch (status) {
                    case "AVAILABLE":
                        stats[0] = count;
                        break;
                    case "OCCUPIED":
                        stats[1] = count;
                        break;
                    case "MAINTENANCE":
                        stats[2] = count;
                        break;
                    case "DIRTY":
                        stats[3] = count;
                        break;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }

    // Get total room count
    public int getTotalRoomCount() {
        String sql = "SELECT COUNT(*) FROM Rooms";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Get available rooms for date range
    public List<Room> getAvailableRoomsForDateRange(Date checkIn, Date checkOut) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.Status = 'AVAILABLE' "
                + "AND r.Id NOT IN ( "
                + "  SELECT res.RoomId FROM Reservations res "
                + "  WHERE res.Status IN ('CONFIRMED', 'PENDING') "
                + "  AND ((res.CheckIn <= ? AND res.CheckOut > ?) "
                + "  OR (res.CheckIn < ? AND res.CheckOut >= ?) "
                + "  OR (res.CheckIn >= ? AND res.CheckOut <= ?)) "
                + ") "
                + "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, checkOut);
            ps.setDate(2, checkIn);
            ps.setDate(3, checkOut);
            ps.setDate(4, checkOut);
            ps.setDate(5, checkIn);
            ps.setDate(6, checkOut);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // Get rooms with pagination
    public List<Room> getRoomsPaginated(int page, int recordsPerPage) {
        List<Room> rooms = new ArrayList<>();
        int offset = (page - 1) * recordsPerPage;

        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "ORDER BY r.RoomNumber "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, offset);
            ps.setInt(2, recordsPerPage);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // Helper method to map ResultSet to Room
    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setId(rs.getInt("Id"));
        room.setRoomNumber(rs.getString("RoomNumber"));
        room.setRoomTypeId(rs.getInt("RoomTypeId"));
        room.setStatus(rs.getString("Status"));

        // Additional fields
        room.setRoomTypeName(rs.getString("RoomTypeName"));
        room.setBasePrice(rs.getDouble("BasePrice"));
        room.setCapacity(rs.getInt("Capacity"));

        // Handle nullable fields
        String description = rs.getString("Description");
        room.setRoomTypeDescription(description != null ? description : "");

        String imageUrl = rs.getString("imageUrl");
        room.setImageUrl(imageUrl != null ? imageUrl : "");

        return room;
    }

    // Get available rooms by room type
    public List<Room> getAvailableRoomsByType(int roomTypeId) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.RoomTypeId = ? AND r.Status = 'AVAILABLE' "
                + "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomTypeId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    // Get available rooms with details
    public List<Room> getAvailableRoomsWithDetails() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description as RoomTypeDescription, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.Status = 'AVAILABLE' "
                + "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("Id"));
                room.setRoomNumber(rs.getString("RoomNumber"));
                room.setRoomTypeId(rs.getInt("RoomTypeId"));
                room.setStatus(rs.getString("Status"));
                room.setRoomTypeName(rs.getString("RoomTypeName"));
                room.setBasePrice(rs.getDouble("BasePrice"));
                room.setCapacity(rs.getInt("Capacity"));
                room.setRoomTypeDescription(rs.getString("RoomTypeDescription"));
                room.setImageUrl(rs.getString("imageUrl"));
                rooms.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

// Get room with full details by ID
    public Room getRoomWithFullDetails(int roomId) {
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description as RoomTypeDescription, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.Id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapResultSetToRoom(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

// Check if room is available for specific date range
    public boolean isRoomAvailableForDateRange(int roomId, Date checkIn, Date checkOut) {
        String sql = "SELECT COUNT(*) FROM Reservations "
                + "WHERE RoomId = ? AND Status IN ('CONFIRMED', 'PENDING') "
                + "AND ((CheckIn <= ? AND CheckOut > ?) "
                + "OR (CheckIn < ? AND CheckOut >= ?) "
                + "OR (CheckIn >= ? AND CheckOut <= ?))";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            ps.setDate(2, checkOut);
            ps.setDate(3, checkIn);
            ps.setDate(4, checkOut);
            ps.setDate(5, checkOut);
            ps.setDate(6, checkIn);
            ps.setDate(7, checkOut);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) == 0; // Return true if no conflicting reservations
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

// Get rooms by floor
<<<<<<< HEAD
    public List<Room> getRoomsByFloor(int floor) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE LEFT(r.RoomNumber, 1) = ? "
                + "ORDER BY r.RoomNumber";
=======
public List<Room> getRoomsByFloor(int floor) {
    List<Room> rooms = new ArrayList<>();
    String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                "rt.Capacity, rt.Description, rt.imageUrl " +
                "FROM Rooms r " +
                "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                "WHERE LEFT(r.RoomNumber, 1) = ? " +
                "ORDER BY r.RoomNumber";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, String.valueOf(floor));
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            rooms.add(mapResultSetToRoom(rs));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return rooms;
}

public List<Room> getAvailableRoomsByTypeNoDateCheck(int roomTypeId) {
    List<Room> rooms = new ArrayList<>();
    String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                "rt.Capacity, rt.Description, rt.imageUrl " +
                "FROM Rooms r " +
                "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                "WHERE r.Status = 'AVAILABLE' " +
                "AND r.RoomTypeId = ? " +
                "ORDER BY r.RoomNumber";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, roomTypeId);
        
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            rooms.add(mapResultSetToRoom(rs));
        }
        
        System.out.println("DEBUG: Found " + rooms.size() + " AVAILABLE rooms for type " + roomTypeId + " (no date check)");
            
    } catch (SQLException e) {
        System.err.println("Error in getAvailableRoomsByTypeNoDateCheck: " + e.getMessage());
        e.printStackTrace();
    }
    return rooms;
}
>>>>>>> develop

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, String.valueOf(floor));
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }

    public List<Room> getAvailableRoomsByTypeAndDate(int roomTypeId, Date checkIn, Date checkOut) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.Status = 'AVAILABLE' "
                + "AND r.RoomTypeId = ? "
                + "AND r.Id NOT IN ( "
                + "  SELECT DISTINCT res.RoomId FROM Reservations res "
                + "  WHERE res.Status IN ('CONFIRMED', 'PENDING') "
                + "  AND NOT (res.CheckOut <= ? OR res.CheckIn >= ?) "
                + ") "
                + "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomTypeId);
            ps.setDate(2, checkIn);
            ps.setDate(3, checkOut);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }

            System.out.println("Found " + rooms.size() + " available rooms for type " + roomTypeId
                    + " between " + checkIn + " and " + checkOut);

        } catch (SQLException e) {
            System.err.println("Error in getAvailableRoomsByTypeAndDate: " + e.getMessage());
            e.printStackTrace();
        }
        return rooms;
    }

    public List<Room> getAvailableRoomsByTypeNoDateCheck(int roomTypeId) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, "
                + "rt.Capacity, rt.Description, rt.imageUrl "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.Status = 'AVAILABLE' "
                + "AND r.RoomTypeId = ? "
                + "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomTypeId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }

            System.out.println("DEBUG: Found " + rooms.size() + " AVAILABLE rooms for type " + roomTypeId + " (no date check)");

        } catch (SQLException e) {
            System.err.println("Error in getAvailableRoomsByTypeNoDateCheck: " + e.getMessage());
            e.printStackTrace();
        }
        return rooms;
    }

    /**
     * Get all reservations for debugging
     */
    public void debugReservations(Date checkIn, Date checkOut) {
        String sql = "SELECT r.Id, r.RoomId, rm.RoomNumber, r.CheckIn, r.CheckOut, r.Status "
                + "FROM Reservations r "
                + "INNER JOIN Rooms rm ON r.RoomId = rm.Id "
                + "WHERE r.Status IN ('CONFIRMED', 'PENDING') "
                + "ORDER BY r.CheckIn";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ResultSet rs = ps.executeQuery();
            System.out.println("\n=== Current Reservations ===");
            System.out.println("Search dates: Check-in=" + checkIn + ", Check-out=" + checkOut);

            while (rs.next()) {
                System.out.println("Reservation ID: " + rs.getInt("Id")
                        + ", Room: " + rs.getString("RoomNumber")
                        + ", CheckIn: " + rs.getDate("CheckIn")
                        + ", CheckOut: " + rs.getDate("CheckOut")
                        + ", Status: " + rs.getString("Status"));
            }
            System.out.println("========================\n");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

// Lọc RoomTypes theo các tiêu chí
    public List<Room> filterRooms(Integer roomTypeId, Integer capacity, String status) {
        List<Room> rooms = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getConnection();

            StringBuilder sql = new StringBuilder(
                    "SELECT r.id, r.room_number, r.room_type_id, r.status, "
                    + "rt.name AS room_type_name, rt.base_price, rt.capacity, rt.description AS room_type_description, rt.image_url "
                    + "FROM Room r "
                    + "JOIN RoomType rt ON r.room_type_id = rt.id "
                    + "WHERE 1=1"
            );

            if (roomTypeId != null && roomTypeId != -1) {
                sql.append(" AND r.room_type_id = ?");
            }
            if (capacity != null && capacity != -1) {
                sql.append(" AND rt.capacity = ?");
            }
            if (status != null && !status.isEmpty()) {
                sql.append(" AND r.status = ?");
            }

            ps = conn.prepareStatement(sql.toString());

            int paramIndex = 1;
            if (roomTypeId != null && roomTypeId != -1) {
                ps.setInt(paramIndex++, roomTypeId);
            }
            if (capacity != null && capacity != -1) {
                ps.setInt(paramIndex++, capacity);
            }
            if (status != null && !status.isEmpty()) {
                ps.setString(paramIndex++, status);
            }

            rs = ps.executeQuery();
            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("id"));
                room.setRoomNumber(rs.getString("room_number"));
                room.setRoomTypeId(rs.getInt("room_type_id"));
                room.setStatus(rs.getString("status"));

                // RoomType info
                room.setRoomTypeName(rs.getString("room_type_name"));
                room.setBasePrice(rs.getDouble("base_price"));
                room.setCapacity(rs.getInt("capacity"));
                room.setRoomTypeDescription(rs.getString("room_type_description"));
                room.setImageUrl(rs.getString("image_url"));

                rooms.add(room);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return rooms;
    }

}
<<<<<<< HEAD
=======


public List<Room> getAvailableRoomsByTypeAndDate(int roomTypeId, Date checkIn, Date checkOut) {
    List<Room> rooms = new ArrayList<>();
    
    // Fixed SQL query with proper date overlap detection
    String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                "rt.Capacity, rt.Description, rt.imageUrl " +
                "FROM Rooms r " +
                "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                "WHERE r.Status = 'AVAILABLE' " +
                "AND r.RoomTypeId = ? " +
                "AND r.Id NOT IN ( " +
                "  SELECT DISTINCT res.RoomId " +
                "  FROM Reservations res " +
                "  WHERE res.RoomId IS NOT NULL " +  // Important: handle null RoomId
                "  AND res.Status IN ('CONFIRMED', 'PENDING') " +
                "  AND (" +
                "    (res.CheckIn < ? AND res.CheckOut > ?) OR " +  // Reservation spans check-in
                "    (res.CheckIn < ? AND res.CheckOut > ?) OR " +  // Reservation spans check-out
                "    (res.CheckIn >= ? AND res.CheckOut <= ?) OR " + // Reservation within dates
                "    (res.CheckIn <= ? AND res.CheckOut >= ?)" +    // Dates within reservation
                "  )" +
                ") " +
                "ORDER BY r.RoomNumber";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, roomTypeId);
        // Set all date parameters
        ps.setDate(2, checkOut);  // for CheckOut > checkIn
        ps.setDate(3, checkIn);   // for CheckOut > checkIn
        ps.setDate(4, checkOut);  // for CheckIn < checkOut
        ps.setDate(5, checkOut);  // for CheckIn < checkOut
        ps.setDate(6, checkIn);   // for CheckIn >= checkIn
        ps.setDate(7, checkOut);  // for CheckOut <= checkOut
        ps.setDate(8, checkIn);   // for CheckIn <= checkIn
        ps.setDate(9, checkOut);  // for CheckOut >= checkOut
        
        System.out.println("Executing availability query for RoomType " + roomTypeId + 
                         " from " + checkIn + " to " + checkOut);
        
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            rooms.add(mapResultSetToRoom(rs));
        }
        
        System.out.println("Found " + rooms.size() + " available rooms");
            
    } catch (SQLException e) {
        System.err.println("Error in getAvailableRoomsByTypeAndDate: " + e.getMessage());
        e.printStackTrace();
    }
    
    return rooms;
}

// Also add this simpler method that might be more reliable
public List<Room> getAvailableRoomsByTypeSimple(int roomTypeId, Date checkIn, Date checkOut) {
    List<Room> availableRooms = new ArrayList<>();
    
    // First get all rooms of this type with AVAILABLE status
    String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                "rt.Capacity, rt.Description, rt.imageUrl " +
                "FROM Rooms r " +
                "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                "WHERE r.RoomTypeId = ? AND r.Status = 'AVAILABLE'";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, roomTypeId);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Room room = mapResultSetToRoom(rs);
            
            // Check if this specific room is available for the dates
            if (isRoomAvailableForDates(room.getId(), checkIn, checkOut)) {
                availableRooms.add(room);
            }
        }
            
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    return availableRooms;
}

// Helper method to check if a specific room is available
private boolean isRoomAvailableForDates(int roomId, Date checkIn, Date checkOut) {
    String sql = "SELECT COUNT(*) FROM Reservations " +
                "WHERE RoomId = ? " +
                "AND Status IN ('CONFIRMED', 'PENDING') " +
                "AND (" +
                "  (CheckIn < ? AND CheckOut > ?) OR " +
                "  (CheckIn < ? AND CheckOut > ?) OR " +
                "  (CheckIn >= ? AND CheckOut <= ?) OR " +
                "  (CheckIn <= ? AND CheckOut >= ?)" +
                ")";
    
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, roomId);
        ps.setDate(2, checkOut);
        ps.setDate(3, checkIn);
        ps.setDate(4, checkOut);
        ps.setDate(5, checkOut);
        ps.setDate(6, checkIn);
        ps.setDate(7, checkOut);
        ps.setDate(8, checkIn);
        ps.setDate(9, checkOut);
        
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            int count = rs.getInt(1);
            return count == 0; // Room is available if no conflicting reservations
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    return false;
}

}
>>>>>>> develop
