package dal;


import model.Room;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {
    
    // Get all rooms with room type details
    public List<Room> getAllRooms() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                    "rt.Capacity, rt.Description, rt.imageUrl " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "ORDER BY r.RoomNumber";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
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
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                    "rt.Capacity, rt.Description, rt.imageUrl " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "WHERE r.Status = ? " +
                    "ORDER BY r.RoomNumber";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                    "rt.Capacity, rt.Description, rt.imageUrl " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "WHERE r.RoomTypeId = ? " +
                    "ORDER BY r.RoomNumber";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                    "rt.Capacity, rt.Description, rt.imageUrl " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "WHERE r.Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                    "rt.Capacity, rt.Description, rt.imageUrl " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "WHERE r.RoomNumber = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                    "rt.Capacity, rt.Description, rt.imageUrl " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "WHERE (r.RoomNumber LIKE ? OR rt.Name LIKE ?) ";
        
        if (status != null && !status.equals("ALL")) {
            sql += "AND r.Status = ? ";
        }
        
        sql += "ORDER BY r.RoomNumber";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
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
    
    // Get available rooms for date range
    public List<Room> getAvailableRoomsForDateRange(Date checkIn, Date checkOut) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                    "rt.Capacity, rt.Description, rt.imageUrl " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "WHERE r.Status = 'AVAILABLE' " +
                    "AND r.Id NOT IN ( " +
                    "  SELECT res.RoomId FROM Reservations res " +
                    "  WHERE res.Status IN ('CONFIRMED', 'PENDING') " +
                    "  AND ((res.CheckIn <= ? AND res.CheckOut > ?) " +
                    "  OR (res.CheckIn < ? AND res.CheckOut >= ?) " +
                    "  OR (res.CheckIn >= ? AND res.CheckOut <= ?)) " +
                    ") " +
                    "ORDER BY r.RoomNumber";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                    "rt.Capacity, rt.Description, rt.imageUrl " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "ORDER BY r.RoomNumber " +
                    "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice, " +
                    "rt.Capacity, rt.Description, rt.imageUrl " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "WHERE r.RoomTypeId = ? AND r.Status = 'AVAILABLE' " +
                    "ORDER BY r.RoomNumber";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
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
}