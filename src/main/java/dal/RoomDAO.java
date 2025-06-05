package dal;


import model.Room;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO extends DBContext {
    
    // Get total rooms count
    public int getTotalRooms() {
        String sql = "SELECT COUNT(*) FROM Rooms";
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
    
    // Get available rooms count
    public int getAvailableRoomsCount() {
        String sql = "SELECT COUNT(*) FROM Rooms WHERE Status = 'AVAILABLE'";
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
    
    // Get occupied rooms count
    public int getOccupiedRoomsCount() {
        String sql = "SELECT COUNT(*) FROM Rooms WHERE Status = 'OCCUPIED'";
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
    
    // Get maintenance rooms count
    public int getMaintenanceRoomsCount() {
        String sql = "SELECT COUNT(*) FROM Rooms WHERE Status = 'MAINTENANCE'";
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
    
    // Get dirty rooms count
    public int getDirtyRoomsCount() {
        String sql = "SELECT COUNT(*) FROM Rooms WHERE Status = 'DIRTY'";
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
    
    // Get available rooms list
    public List<Room> getAvailableRoomsList() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName, rt.BasePrice " +
                     "FROM Rooms r " +
                     "JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                     "WHERE r.Status = 'AVAILABLE' " +
                     "ORDER BY r.RoomNumber";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("Id"));
                room.setRoomNumber(rs.getString("RoomNumber"));
                room.setRoomTypeId(rs.getInt("RoomTypeId"));
                room.setStatus(rs.getString("Status"));
                room.setRoomTypeName(rs.getString("RoomTypeName"));
                room.setBasePrice(rs.getBigDecimal("BasePrice"));
                list.add(room);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Get all rooms with filter
    public List<Room> getRoomsWithFilter(String status) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName " +
                     "FROM Rooms r " +
                     "JOIN RoomTypes rt ON r.RoomTypeId = rt.Id ";
        if (status != null && !status.equals("ALL")) {
            sql += "WHERE r.Status = ? ";
        }
        sql += "ORDER BY r.RoomNumber";
        
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (status != null && !status.equals("ALL")) {
                ps.setString(1, status);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("Id"));
                room.setRoomNumber(rs.getString("RoomNumber"));
                room.setRoomTypeId(rs.getInt("RoomTypeId"));
                room.setStatus(rs.getString("Status"));
                room.setRoomTypeName(rs.getString("RoomTypeName"));
                list.add(room);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    // Update room status
    public boolean updateRoomStatus(int roomId, String newStatus) {
        String sql = "UPDATE Rooms SET Status = ? WHERE Id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, roomId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Thêm vào RoomDAO.java
public List<Room> searchRoomsByNumber(String roomNumber) {
    List<Room> list = new ArrayList<>();
    String sql = "SELECT r.*, rt.Name as RoomTypeName " +
                 "FROM Rooms r " +
                 "JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                 "WHERE r.RoomNumber LIKE ? " +
                 "ORDER BY r.RoomNumber";
    
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, "%" + roomNumber + "%");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Room room = new Room();
            room.setId(rs.getInt("Id"));
            room.setRoomNumber(rs.getString("RoomNumber"));
            room.setRoomTypeId(rs.getInt("RoomTypeId"));
            room.setStatus(rs.getString("Status"));
            room.setRoomTypeName(rs.getString("RoomTypeName"));
            list.add(room);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}
}