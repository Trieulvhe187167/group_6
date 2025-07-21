package dal;

import java.math.BigDecimal;
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
        String sql = "SELECT a.*, ra.Quantity as RoomQuantity "
                + "FROM RoomAmenities a "
                + "LEFT JOIN RoomAmenities ra ON a.Id = ra.Id AND ra.RoomId = ? "
                + "WHERE a.Status = 'ACTIVE' "
                + "ORDER BY a.Name";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

    public List<InspectionItem> getInspectionItemsByReservation(int reservationId) throws SQLException {
        String sql = "SELECT ii.* FROM InspectionItems ii "
                + "JOIN RoomInspections ri ON ii.InspectionId = ri.Id "
                + "WHERE ri.ReservationId = ?";
        List<InspectionItem> list = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                InspectionItem item = new InspectionItem();
                item.setId(rs.getInt("Id"));
                item.setInspectionId(rs.getInt("InspectionId"));
                item.setItemName(rs.getString("ItemName"));
                item.setItemCategory(rs.getString("ItemCategory"));
                item.setQuantity(rs.getInt("Quantity"));
                item.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                item.setNotes(rs.getString("Notes"));
                list.add(item);
            }
        }
        return list;
    }

    // Get chargeable amenities for a room
    public List<RoomAmenity> getChargeableAmenities(int roomId) {
        List<RoomAmenity> amenities = new ArrayList<>();
        String sql = "SELECT a.*, ra.Quantity as RoomQuantity "
                + "FROM RoomAmenities a "
                + "LEFT JOIN RoomAmenities ra ON a.Id = ra.Id AND ra.RoomId = ? "
                + "WHERE a.Status = 'ACTIVE' AND a.IsChargeable = 1 "
                + "ORDER BY a.Name";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
//    public List<RoomAmenity> getAmenitiesByCategory(String category) {
//        List<RoomAmenity> amenities = new ArrayList<>();
//        String sql = "SELECT * FROM RoomAmenities WHERE Category = ? AND Status = 'ACTIVE' ORDER BY Name";
//
//        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
//
//            ps.setString(1, category);
//            ResultSet rs = ps.executeQuery();
//
//            while (rs.next()) {
//                RoomAmenity amenity = new RoomAmenity();
//                amenity.setId(rs.getInt("Id"));
//                amenity.setName(rs.getString("Name"));
//                amenity.setDescription(rs.getString("Description"));
//                amenity.setCategory(rs.getString("Category"));
//                amenity.setIsChargeable(rs.getBoolean("IsChargeable"));
//                amenity.setUnitPrice(rs.getDouble("UnitPrice"));
//                amenity.setStatus(rs.getString("Status"));
//                amenities.add(amenity);
//            }
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//        return amenities;
//    }
    // Record amenity inventory check during check-in
    public boolean recordAmenityInventory(int reservationId, int amenityId, int quantity, int checkedBy) {
        String sql = "INSERT INTO AmenityInventory (ReservationId, AmenityId, Quantity, CheckType, CheckedAt, CheckedBy) "
                + "VALUES (?, ?, ?, 'CHECK_IN', GETDATE(), ?)";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
    public boolean recordAmenityUsage(int reservationId, int amenityId, int quantity, double unitPrice, int checkedBy) {
        String sql = "INSERT INTO ReservationAmenityUsage "
                + "(ReservationId, AmenityId, Quantity, UnitPrice, TotalPrice, CheckedAt, CheckedBy) "
                + "VALUES (?, ?, ?, ?, ?, GETDATE(), ?)";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            double totalPrice = quantity * unitPrice;

            ps.setInt(1, reservationId);
            ps.setInt(2, amenityId);
            ps.setInt(3, quantity);
            ps.setDouble(4, unitPrice);
            ps.setDouble(5, totalPrice);
            ps.setInt(6, checkedBy);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get current amenity usage for a reservation
    public Map<String, Integer> getCurrentAmenityUsage(int reservationId) {
        Map<String, Integer> usage = new HashMap<>();
        String sql = "SELECT ItemName, ItemCategory, SUM(Quantity) AS TotalQuantity "
                + "FROM InspectionItems "
                + "WHERE ReservationId = ? "
                + "GROUP BY ItemName, ItemCategory";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String key = rs.getString("ItemCategory") + "::" + rs.getString("ItemName");
                usage.put(key, rs.getInt("TotalQuantity"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usage;
    }

    // Get amenity usage logs for a reservation
    public List<AmenityUsageLog> getAmenityUsageLogs(int reservationId) {
        List<AmenityUsageLog> logs = new ArrayList<>();
        String sql = "SELECT ii.*, ra.Id AS AmenityId, ra.Name AS AmenityName, "
                + "u.FullName AS RecordedByName, r.Id AS ReservationId, rm.RoomNumber "
                + "FROM InspectionItems ii "
                + "INNER JOIN RoomInspections i ON ii.InspectionId = i.Id "
                + "LEFT JOIN RoomAmenities ra ON ii.ItemName = ra.Name "
                + "LEFT JOIN Users u ON i.InspectorId = u.Id "
                + "INNER JOIN Reservations r ON i.ReservationId = r.Id "
                + "INNER JOIN Rooms rm ON r.RoomId = rm.Id "
                + "WHERE i.ReservationId = ? "
                + "ORDER BY i.InspectionTime DESC";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                AmenityUsageLog log = new AmenityUsageLog();
                log.setId(rs.getInt("Id"));
                log.setReservationId(rs.getInt("ReservationId"));
                log.setAmenityId(rs.getInt("AmenityId")); // có thể null nếu không khớp
                log.setAmenityName(rs.getString("AmenityName"));
                log.setCategory(rs.getString("Category"));
                log.setQuantity(rs.getInt("Quantity"));
                log.setUnitPrice(rs.getDouble("UnitPrice"));
                log.setTotalPrice(rs.getDouble("TotalPrice"));
                log.setUsageDate(rs.getTimestamp("InspectionTime")); // thay cho CheckedAt
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
        String sql = "SELECT TOP (?) ii.*, ra.Id AS AmenityId, ra.Name AS AmenityName, ra.IsChargeable, "
                + "u.FullName AS RecordedByName, r.Id AS ReservationId, rm.RoomNumber, guest.FullName AS CustomerName, "
                + "ri.InspectionTime AS UsageDate "
                + "FROM InspectionItems ii "
                + "INNER JOIN RoomInspections ri ON ii.InspectionId = ri.Id "
                + "LEFT JOIN RoomAmenities ra ON ii.ItemName = ra.Name "
                + "LEFT JOIN Users u ON ri.InspectorId = u.Id "
                + "INNER JOIN Reservations r ON ri.ReservationId = r.Id "
                + "INNER JOIN Rooms rm ON r.RoomId = rm.Id "
                + "INNER JOIN Users guest ON r.UserId = guest.Id "
                + "ORDER BY ri.InspectionTime DESC";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                AmenityUsageLog log = new AmenityUsageLog();
                log.setId(rs.getInt("Id"));
                log.setReservationId(rs.getInt("ReservationId"));
                log.setAmenityId(rs.getInt("AmenityId")); // có thể null nếu không match
                log.setAmenityName(rs.getString("AmenityName"));
                log.setCategory(rs.getString("Category"));
                log.setQuantity(rs.getInt("Quantity"));
                log.setUnitPrice(rs.getDouble("UnitPrice"));
                log.setTotalPrice(rs.getDouble("TotalPrice"));
                log.setUsageDate(rs.getTimestamp("UsageDate"));
                log.setRecordedByName(rs.getString("RecordedByName"));
                log.setRoomNumber(rs.getString("RoomNumber"));
                log.setCustomerName(rs.getString("CustomerName"));
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
        String sql = "SELECT ISNULL(SUM(TotalPrice), 0) FROM InspectionItems WHERE ReservationId = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
        String sql = "INSERT INTO RoomAmenities (Name, Description, Category, IsChargeable, UnitPrice, Status, CreatedAt, CreatedBy) "
                + "VALUES (?, ?, ?, ?, ?, 'ACTIVE', GETDATE(), ?)";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
        String sql = "UPDATE RoomAmenities SET Name = ?, Description = ?, Category = ?, "
                + "IsChargeable = ?, UnitPrice = ?, UpdatedAt = GETDATE() WHERE Id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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
        String sql = "SELECT r.*, rt.Name as RoomTypeName "
                + "FROM Rooms r "
                + "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id "
                + "WHERE r.RoomNumber LIKE ? "
                + "ORDER BY r.RoomNumber";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

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

    public RoomAmenity getAmenityById(int id) throws SQLException {
        String sql = "SELECT * FROM RoomAmenities WHERE Id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RoomAmenity amenity = new RoomAmenity();
                    amenity.setId(rs.getInt("Id"));
                    amenity.setName(rs.getString("Name"));
                    amenity.setDescription(rs.getString("Description"));
                    amenity.setCategory(rs.getString("Category"));
                    amenity.setIsChargeable(rs.getBoolean("IsChargeable"));
                    amenity.setUnitPrice(rs.getDouble("UnitPrice"));
                    amenity.setStatus(rs.getString("Status"));
                    amenity.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    amenity.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    amenity.setCreatedBy(rs.getInt("CreatedBy"));
                    return amenity;
                }
            }
        }
        return null;
    }

    public boolean saveAmenityInspectionItem(int reservationId, int inspectorId,
            String itemName, String category, int quantity,
            BigDecimal unitPrice, String notes) throws SQLException {

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            // 1. Tìm hoặc tạo inspection record
            int inspectionId = -1;
            String checkSql = "SELECT Id FROM RoomInspections WHERE ReservationId = ? AND InspectorId = ? AND Status = 'PENDING'";
            ps = con.prepareStatement(checkSql);
            ps.setInt(1, reservationId);
            ps.setInt(2, inspectorId);
            rs = ps.executeQuery();
            if (rs.next()) {
                inspectionId = rs.getInt("Id");
            } else {
                // Insert new inspection
                String insertInspection = "INSERT INTO RoomInspections (ReservationId, InspectorId, InspectionTime, RoomCondition, CleanlinessScore, Status) "
                        + "VALUES (?, ?, GETDATE(), 'OK', 5, 'PENDING')";
                ps = con.prepareStatement(insertInspection, Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, reservationId);
                ps.setInt(2, inspectorId);
                ps.executeUpdate();
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    inspectionId = rs.getInt(1);
                } else {
                    con.rollback();
                    return false;
                }
            }

            // 2. Insert inspection item
            String insertItem = "INSERT INTO InspectionItems (InspectionId, ItemName, ItemCategory, Quantity, UnitPrice, Notes) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";
            ps = con.prepareStatement(insertItem);
            ps.setInt(1, inspectionId);
            ps.setString(2, itemName);
            ps.setString(3, category);
            ps.setInt(4, quantity);
            ps.setBigDecimal(5, unitPrice);
            ps.setString(6, notes);
            ps.executeUpdate();

            con.commit();
            return true;
        } catch (Exception e) {
            if (con != null) {
                con.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (con != null) {
                con.setAutoCommit(true);
            }
            if (con != null) {
                con.close();
            }
        }
    }

    public int getOrCreateInspection(int reservationId, int inspectorId) throws SQLException {
        // Kiểm tra đã tồn tại Inspection chưa
        String checkSql = "SELECT Id FROM RoomInspections WHERE ReservationId = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(checkSql)) {

            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("Id");
            }
        }

        // Chưa có thì insert mới
        String insertSql = "INSERT INTO RoomInspections (ReservationId, InspectorId, InspectionTime, RoomCondition, CleanlinessScore, Status) VALUES (?, ?, GETDATE(), 'GOOD', 10, 'PENDING')";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, reservationId);
            ps.setInt(2, inspectorId);
            ps.executeUpdate();

            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return -1;
    }

    public boolean insertInspectionItem(int inspectionId, String itemName, String itemCategory, int quantity, BigDecimal unitPrice, String notes) throws SQLException {
        String sql = "INSERT INTO InspectionItems (InspectionId, ItemName, ItemCategory, Quantity, UnitPrice, Notes) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, inspectionId);
            ps.setString(2, itemName);
            ps.setString(3, itemCategory);
            ps.setInt(4, quantity);
            ps.setBigDecimal(5, unitPrice);
            ps.setString(6, notes);
            return ps.executeUpdate() > 0;
        }
    }

    public List<RoomAmenityDTO> getAllPaginated(int offset, int pageSize) {
        List<RoomAmenityDTO> list = new ArrayList<>();
        String sql = "SELECT ra.*, r.RoomNumber "
                + "FROM RoomAmenities ra "
                + "JOIN Rooms r ON ra.RoomId = r.Id "
                + "ORDER BY ra.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, pageSize);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                RoomAmenityDTO dto = new RoomAmenityDTO();
                dto.setId(rs.getInt("Id"));
                dto.setRoomId(rs.getInt("RoomId"));
                dto.setRoomNumber(rs.getString("RoomNumber"));
                dto.setName(rs.getString("Name"));
                dto.setDescription(rs.getString("Description"));
                dto.setIsChargeable(rs.getBoolean("IsChargeable"));
                dto.setUnitPrice(rs.getBigDecimal("UnitPrice"));

                Timestamp createdAt = rs.getTimestamp("CreatedAt");
                if (createdAt != null) {
                    dto.setCreatedAt(new Date(createdAt.getTime()));
                }

                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Room> getAllRooms() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT Id, RoomNumber FROM Rooms ORDER BY RoomNumber";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("Id"));
                room.setRoomNumber(rs.getString("RoomNumber"));
                list.add(room);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<String> getAllAmenityNames() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT Name FROM RoomAmenities ORDER BY Name";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(rs.getString("Name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<RoomAmenityDTO> searchAndFilterAmenities(String keyword, String roomNumber, String amenityName, int offset, int limit) {
        List<RoomAmenityDTO> list = new ArrayList<>();

        String sql = "SELECT ra.*, r.RoomNumber FROM RoomAmenities ra "
                + "JOIN Rooms r ON ra.RoomId = r.Id WHERE 1=1";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (ra.Name LIKE ? OR ra.Description LIKE ?)";
        }

        if (roomNumber != null && !roomNumber.trim().isEmpty()) {
            sql += " AND r.RoomNumber = ?";
        }

        if (amenityName != null && !amenityName.trim().isEmpty()) {
            sql += " AND ra.Name = ?";
        }

        sql += " ORDER BY r.RoomNumber, ra.Name OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int index = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(index++, "%" + keyword.trim() + "%");
            }

            if (roomNumber != null && !roomNumber.trim().isEmpty()) {
                ps.setString(index++, roomNumber.trim());
            }

            if (amenityName != null && !amenityName.trim().isEmpty()) {
                ps.setString(index++, amenityName.trim());
            }

            ps.setInt(index++, offset);
            ps.setInt(index, limit);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                RoomAmenityDTO a = new RoomAmenityDTO();
                a.setId(rs.getInt("Id"));
                a.setRoomId(rs.getInt("RoomId"));
                a.setRoomNumber(rs.getString("RoomNumber"));
                a.setName(rs.getString("Name"));
                a.setDescription(rs.getString("Description"));
                a.setIsChargeable(rs.getBoolean("IsChargeable"));
                a.setUnitPrice(rs.getBigDecimal("UnitPrice"));

                Timestamp createdAt = rs.getTimestamp("CreatedAt");
                if (createdAt != null) {
                    a.setCreatedAt(new Date(createdAt.getTime()));
                }

                list.add(a);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countAmenities(String keyword, String roomNumber, String amenityName) {
        String sql = "SELECT COUNT(*) FROM RoomAmenities ra JOIN Rooms r ON ra.RoomId = r.Id WHERE 1=1";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (ra.Name LIKE ? OR ra.Description LIKE ?)";
        }
        if (roomNumber != null && !roomNumber.trim().isEmpty()) {
            sql += " AND r.RoomNumber = ?";
        }

        if (amenityName != null && !amenityName.trim().isEmpty()) {
            sql += " AND ra.Name = ?";
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            int index = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(index++, "%" + keyword + "%");
            }
            if (roomNumber != null && !roomNumber.trim().isEmpty()) {
                ps.setString(index++, roomNumber);
            }
            if (amenityName != null && !amenityName.trim().isEmpty()) {
                ps.setString(index++, amenityName);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public RoomAmenityDTO getRoomAmenityById(int id) {
        RoomAmenityDTO amenity = null;
        String sql = "SELECT ra.Id, ra.RoomId, r.RoomNumber, ra.Name, ra.Description, ra.IsChargeable, ra.UnitPrice, ra.CreatedAt "
                + "FROM RoomAmenities ra "
                + "JOIN Rooms r ON ra.RoomId = r.Id "
                + "WHERE ra.Id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    amenity = new RoomAmenityDTO();
                    amenity.setId(rs.getInt("Id"));
                    amenity.setRoomId(rs.getInt("RoomId"));
                    amenity.setRoomNumber(rs.getString("RoomNumber"));
                    amenity.setName(rs.getString("Name"));
                    amenity.setDescription(rs.getString("Description"));
                    amenity.setIsChargeable(rs.getBoolean("IsChargeable"));
                    amenity.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                    amenity.setCreatedAt(rs.getTimestamp("CreatedAt"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return amenity;
    }

    public void insertAmenity(RoomAmenityDTO amenity) {
        String sql = "INSERT INTO RoomAmenities (RoomId, Name, Description, IsChargeable, UnitPrice, CreatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, amenity.getRoomId());
            ps.setString(2, amenity.getName());
            ps.setString(3, amenity.getDescription());
            ps.setBoolean(4, amenity.isIsChargeable());
            ps.setBigDecimal(5, amenity.getUnitPrice());
            ps.setTimestamp(6, new java.sql.Timestamp(amenity.getCreatedAt().getTime()));

            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateAmenity(RoomAmenityDTO amenity) {
        String sql = "UPDATE RoomAmenities SET RoomId = ?, Name = ?, Description = ?, IsChargeable = ?, UnitPrice = ? "
                + "WHERE Id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, amenity.getRoomId());
            ps.setString(2, amenity.getName());
            ps.setString(3, amenity.getDescription());
            ps.setBoolean(4, amenity.isIsChargeable());
            ps.setBigDecimal(5, amenity.getUnitPrice());
            ps.setInt(6, amenity.getId());

            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean deleteRoomAmenity(int id) {
        String sql = "DELETE FROM RoomAmenities WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean checkAmenityDuplicate(int roomId, String name, String description) {
        String sql = "SELECT COUNT(*) FROM RoomAmenities WHERE RoomId = ? AND Name = ? AND Description = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.setString(2, name);
            ps.setString(3, description);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    return count > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean checkAmenityDuplicateExceptId(int roomId, String name, String description, int excludeId) {
        String sql = "SELECT COUNT(*) FROM RoomAmenities WHERE RoomId = ? AND Name = ? AND Description = ? AND Id != ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.setString(2, name);
            ps.setString(3, description);
            ps.setInt(4, excludeId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    return count > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

}
