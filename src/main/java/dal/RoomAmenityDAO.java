package dal;


import model.*;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public class RoomAmenityDAO {
    
    // Get all room amenities for a specific room
    public List<RoomAmenity> getRoomAmenities(int roomId) {
        List<RoomAmenity> amenities = new ArrayList<>();
        String sql = "SELECT a.*, ra.Quantity as RoomQuantity " +
                    "FROM Amenities a " +
                    "LEFT JOIN RoomAmenities ra ON a.Id = ra.AmenityId AND ra.RoomId = ? " +
                    "WHERE a.Status = 'ACTIVE' " +
                    "ORDER BY a.Category, a.Name";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RoomAmenity amenity = new RoomAmenity();
                amenity.setId(rs.getInt("Id"));
                amenity.setName(rs.getString("Name"));
                amenity.setDescription(rs.getString("Description"));
                amenity.setCategory(rs.getString("Category"));
                amenity.setIsChargeable(rs.getBoolean("IsChargeable"));
                amenity.setUnitPrice(rs.getDouble("UnitPrice"));
                amenity.setStatus(rs.getString("Status"));
                amenity.setQuantity(rs.getInt("RoomQuantity"));
                amenities.add(amenity);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return amenities;
    }
    
    // Get chargeable amenities for a room
    public List<RoomAmenity> getChargeableAmenities(int roomId) {
        List<RoomAmenity> amenities = new ArrayList<>();
        String sql = "SELECT a.*, ra.Quantity as RoomQuantity " +
                    "FROM Amenities a " +
                    "LEFT JOIN RoomAmenities ra ON a.Id = ra.AmenityId AND ra.RoomId = ? " +
                    "WHERE a.Status = 'ACTIVE' AND a.IsChargeable = 1 " +
                    "ORDER BY a.Category, a.Name";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RoomAmenity amenity = new RoomAmenity();
                amenity.setId(rs.getInt("Id"));
                amenity.setName(rs.getString("Name"));
                amenity.setDescription(rs.getString("Description"));
                amenity.setCategory(rs.getString("Category"));
                amenity.setIsChargeable(rs.getBoolean("IsChargeable"));
                amenity.setUnitPrice(rs.getDouble("UnitPrice"));
                amenity.setStatus(rs.getString("Status"));
                amenity.setQuantity(rs.getInt("RoomQuantity"));
                amenities.add(amenity);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return amenities;
    }
    
    // Get amenities by category
    public List<RoomAmenity> getAmenitiesByCategory(String category) {
        List<RoomAmenity> amenities = new ArrayList<>();
        String sql = "SELECT * FROM Amenities WHERE Category = ? AND Status = 'ACTIVE' ORDER BY Name";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                RoomAmenity amenity = new RoomAmenity();
                amenity.setId(rs.getInt("Id"));
                amenity.setName(rs.getString("Name"));
                amenity.setDescription(rs.getString("Description"));
                amenity.setCategory(rs.getString("Category"));
                amenity.setIsChargeable(rs.getBoolean("IsChargeable"));
                amenity.setUnitPrice(rs.getDouble("UnitPrice"));
                amenity.setStatus(rs.getString("Status"));
                amenities.add(amenity);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return amenities;
    }
    
    // Record amenity inventory check during check-in
    public boolean recordAmenityInventory(int reservationId, int amenityId, int quantity, int checkedBy) {
        String sql = "INSERT INTO AmenityInventory (ReservationId, AmenityId, Quantity, CheckType, CheckedAt, CheckedBy) " +
                    "VALUES (?, ?, ?, 'CHECK_IN', GETDATE(), ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ps.setInt(2, amenityId);
            ps.setInt(3, quantity);
            ps.setInt(4, checkedBy);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Record amenity usage during stay
    public boolean recordAmenityUsage(int reservationId, int amenityId, int quantity, double unitPrice, int recordedBy) {
        String sql = "INSERT INTO AmenityUsage (ReservationId, AmenityId, Quantity, UnitPrice, TotalPrice, UsageDate, RecordedBy) " +
                    "VALUES (?, ?, ?, ?, ?, GETDATE(), ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            double totalPrice = quantity * unitPrice;
            
            ps.setInt(1, reservationId);
            ps.setInt(2, amenityId);
            ps.setInt(3, quantity);
            ps.setDouble(4, unitPrice);
            ps.setDouble(5, totalPrice);
            ps.setInt(6, recordedBy);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get current amenity usage for a reservation
    public Map<Integer, Integer> getCurrentAmenityUsage(int reservationId) {
        Map<Integer, Integer> usage = new HashMap<>();
        String sql = "SELECT AmenityId, SUM(Quantity) as TotalQuantity " +
                    "FROM AmenityUsage " +
                    "WHERE ReservationId = ? " +
                    "GROUP BY AmenityId";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                usage.put(rs.getInt("AmenityId"), rs.getInt("TotalQuantity"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usage;
    }
    
    // Get amenity usage logs for a reservation
    public List<AmenityUsageLog> getAmenityUsageLogs(int reservationId) {
        List<AmenityUsageLog> logs = new ArrayList<>();
        String sql = "SELECT au.*, a.Name as AmenityName, a.Category, " +
                    "u.FullName as RecordedByName, r.Id as ReservationId, rm.RoomNumber " +
                    "FROM AmenityUsage au " +
                    "INNER JOIN Amenities a ON au.AmenityId = a.Id " +
                    "INNER JOIN Users u ON au.RecordedBy = u.Id " +
                    "INNER JOIN Reservations r ON au.ReservationId = r.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE au.ReservationId = ? " +
                    "ORDER BY au.UsageDate DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                AmenityUsageLog log = new AmenityUsageLog();
                log.setId(rs.getInt("Id"));
                log.setReservationId(rs.getInt("ReservationId"));
                log.setAmenityId(rs.getInt("AmenityId"));
                log.setAmenityName(rs.getString("AmenityName"));
                log.setCategory(rs.getString("Category"));
                log.setQuantity(rs.getInt("Quantity"));
                log.setUnitPrice(rs.getDouble("UnitPrice"));
                log.setTotalPrice(rs.getDouble("TotalPrice"));
                log.setUsageDate(rs.getTimestamp("UsageDate"));
                log.setRecordedBy(rs.getInt("RecordedBy"));
                log.setRecordedByName(rs.getString("RecordedByName"));
                log.setRoomNumber(rs.getString("RoomNumber"));
                logs.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }
    
    // Get recent amenity usage logs across all rooms
    public List<AmenityUsageLog> getRecentAmenityLogs(int limit) {
        List<AmenityUsageLog> logs = new ArrayList<>();
        String sql = "SELECT TOP (?) au.*, a.Name as AmenityName, a.Category, a.IsChargeable, " +
                    "u.FullName as RecordedByName, r.Id as ReservationId, rm.RoomNumber, " +
                    "guest.FullName as GuestName " +
                    "FROM AmenityUsage au " +
                    "INNER JOIN Amenities a ON au.AmenityId = a.Id " +
                    "INNER JOIN Users u ON au.RecordedBy = u.Id " +
                    "INNER JOIN Reservations r ON au.ReservationId = r.Id " +
                    "INNER JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "INNER JOIN Users guest ON r.UserId = guest.Id " +
                    "ORDER BY au.UsageDate DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                AmenityUsageLog log = new AmenityUsageLog();
                log.setId(rs.getInt("Id"));
                log.setReservationId(rs.getInt("ReservationId"));
                log.setAmenityId(rs.getInt("AmenityId"));
                log.setAmenityName(rs.getString("AmenityName"));
                log.setCategory(rs.getString("Category"));
                log.setQuantity(rs.getInt("Quantity"));
                log.setUnitPrice(rs.getDouble("UnitPrice"));
                log.setTotalPrice(rs.getDouble("TotalPrice"));
                log.setUsageDate(rs.getTimestamp("UsageDate"));
                log.setRecordedBy(rs.getInt("RecordedBy"));
                log.setRecordedByName(rs.getString("RecordedByName"));
                log.setRoomNumber(rs.getString("RoomNumber"));
                log.setGuestName(rs.getString("GuestName"));
                log.setIsChargeable(rs.getBoolean("IsChargeable"));
                logs.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }
    
    // Get total amenity charges for a reservation
    public double getReservationAmenityTotal(int reservationId) {
        String sql = "SELECT ISNULL(SUM(TotalPrice), 0) FROM AmenityUsage WHERE ReservationId = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
    
    // Create new amenity
    public boolean createAmenity(RoomAmenity amenity) {
        String sql = "INSERT INTO Amenities (Name, Description, Category, IsChargeable, UnitPrice, Status, CreatedAt, CreatedBy) " +
                    "VALUES (?, ?, ?, ?, ?, 'ACTIVE', GETDATE(), ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, amenity.getName());
            ps.setString(2, amenity.getDescription());
            ps.setString(3, amenity.getCategory());
            ps.setBoolean(4, amenity.getIsChargeable());
            ps.setDouble(5, amenity.getUnitPrice());
            ps.setInt(6, amenity.getCreatedBy());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update amenity
    public boolean updateAmenity(RoomAmenity amenity) {
        String sql = "UPDATE Amenities SET Name = ?, Description = ?, Category = ?, " +
                    "IsChargeable = ?, UnitPrice = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, amenity.getName());
            ps.setString(2, amenity.getDescription());
            ps.setString(3, amenity.getCategory());
            ps.setBoolean(4, amenity.getIsChargeable());
            ps.setDouble(5, amenity.getUnitPrice());
            ps.setInt(6, amenity.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get rooms by floor
    public List<Room> getRoomsByFloor(int floor) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT r.*, rt.Name as RoomTypeName " +
                    "FROM Rooms r " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "WHERE r.RoomNumber LIKE ? " +
                    "ORDER BY r.RoomNumber";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, floor + "%");
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("Id"));
                room.setRoomNumber(rs.getString("RoomNumber"));
                room.setRoomTypeId(rs.getInt("RoomTypeId"));
                room.setStatus(rs.getString("Status"));
                room.setRoomTypeName(rs.getString("RoomTypeName"));
                rooms.add(room);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rooms;
    }
}