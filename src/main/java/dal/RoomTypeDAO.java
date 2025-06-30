/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import java.sql.Timestamp;
import model.Room;
import model.RoomType;
import model.RoomTypeImage;

/**
 *
 * @author ASUS
 */
public class RoomTypeDAO {

    // Lấy tất cả RoomTypes
    public List<RoomType> getAllRoomTypes() {
        List<RoomType> listRoom = new ArrayList<>();
        String sql = "SELECT * FROM RoomTypes";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoomType rtype = new RoomType();
                rtype.setId(rs.getInt("Id"));
                rtype.setName(rs.getString("Name"));
                rtype.setDescription(rs.getString("Description"));
                rtype.setBasePrice(rs.getBigDecimal("BasePrice"));
                rtype.setImageUrl(rs.getString("imageUrl"));
                rtype.setCapacity(rs.getInt("Capacity"));
                rtype.setStatus(rs.getString("Status"));
                rtype.setCreatedAt(rs.getTimestamp("CreatedAt"));
                rtype.setUpdatedAt(rs.getTimestamp("UpdatedAt"));

                listRoom.add(rtype);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listRoom;
    }

    // Lấy tất cả RoomTypes đang active
    public List<RoomType> getAllRoomTypesActive() {
        List<RoomType> listRoom = new ArrayList<>();
        String sql = "SELECT * FROM RoomTypes WHERE status = 'active' ";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoomType rtype = new RoomType();
                rtype.setId(rs.getInt("Id"));
                rtype.setName(rs.getString("Name"));
                rtype.setDescription(rs.getString("Description"));
                rtype.setBasePrice(rs.getBigDecimal("BasePrice"));
                rtype.setImageUrl(rs.getString("imageUrl"));
                rtype.setCapacity(rs.getInt("Capacity"));
                rtype.setStatus(rs.getString("Status"));
                rtype.setCreatedAt(rs.getTimestamp("CreatedAt"));
                rtype.setUpdatedAt(rs.getTimestamp("UpdatedAt"));

                listRoom.add(rtype);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listRoom;
    }

    // Tìm kiếm RoomTypes
    public List<RoomType> searchRooms(String keyword) {
        List<RoomType> list = new ArrayList<>();
        String sql = "SELECT * FROM RoomTypes WHERE Name LIKE ? OR CAST(BasePrice AS VARCHAR) LIKE ? OR CAST(Capacity AS VARCHAR) LIKE ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                RoomType room = new RoomType(
                        rs.getInt("Id"),
                        rs.getString("Name"),
                        rs.getString("Description"),
                        rs.getBigDecimal("BasePrice"),
                        rs.getString("imageUrl"),
                        rs.getInt("Capacity"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt"),
                        rs.getTimestamp("UpdatedAt")
                );
                list.add(room);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy RoomTypes theo category (Note: SQL có vẻ sai - đang query từ Rooms thay vì RoomTypes)
    public List<RoomType> getRoomsByCategory(String category) {
        List<RoomType> listRoom = new ArrayList<>();
        String sql = "SELECT * FROM Rooms WHERE category = ?"; // Có thể cần sửa thành RoomTypes

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                RoomType rtype = new RoomType(
                        rs.getInt("Id"),
                        rs.getString("Name"),
                        rs.getString("Description"),
                        rs.getBigDecimal("BasePrice"),
                        rs.getString("imageUrl"),
                        rs.getInt("Capacity"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt"),
                        rs.getTimestamp("UpdatedAt")
                );
                listRoom.add(rtype);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return listRoom;
    }

    // Lấy RoomType theo ID (overloaded methods - một nhận String, một nhận int)
    public RoomType getRoomsById(String id) {
        String sql = "SELECT * FROM RoomTypes WHERE id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new RoomType(
                        rs.getInt("Id"),
                        rs.getString("Name"),
                        rs.getString("Description"),
                        rs.getBigDecimal("BasePrice"),
                        rs.getString("imageUrl"),
                        rs.getInt("Capacity"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt"),
                        rs.getTimestamp("UpdatedAt")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public RoomType getRoomTypesById(int id) {
        String sql = "SELECT * FROM RoomTypes WHERE id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new RoomType(
                        rs.getInt("Id"),
                        rs.getString("Name"),
                        rs.getString("Description"),
                        rs.getBigDecimal("BasePrice"),
                        rs.getString("imageUrl"),
                        rs.getInt("Capacity"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt"),
                        rs.getTimestamp("UpdatedAt")
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy RoomTypes available (Note: SQL sai tên bảng - thiếu 's')
    public List<RoomType> getAvailableRoomTypes() {
        List<RoomType> list = new ArrayList<>();
        String sql = "SELECT * FROM RoomTypes WHERE status = 'active'"; // Đã sửa từ RoomType thành RoomTypes
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoomType rtype = new RoomType();
                rtype.setId(rs.getInt("Id")); // Thêm ID
                rtype.setName(rs.getString("Name"));
                rtype.setDescription(rs.getString("Description"));
                rtype.setBasePrice(rs.getBigDecimal("BasePrice"));
                rtype.setImageUrl(rs.getString("imageUrl"));
                rtype.setCapacity(rs.getInt("Capacity"));
                rtype.setStatus(rs.getString("Status")); // Thêm Status
                rtype.setCreatedAt(rs.getTimestamp("CreatedAt")); // Thêm CreatedAt
                rtype.setUpdatedAt(rs.getTimestamp("UpdatedAt")); // Thêm UpdatedAt
                list.add(rtype);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Thêm RoomType mới
    public int insert(RoomType roomType) throws SQLException {
        String sql = "INSERT INTO RoomTypes (name, description, basePrice, imageUrl, capacity, status, createdAt, updatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, roomType.getName());
            ps.setString(2, roomType.getDescription());
            ps.setBigDecimal(3, roomType.getBasePrice());
            ps.setString(4, roomType.getImageUrl());
            ps.setInt(5, roomType.getCapacity());
            ps.setString(6, "active");
            ps.setObject(7, roomType.getCreatedAt());
            ps.setObject(8, roomType.getUpdatedAt());
            ps.executeUpdate();

            // Lấy RoomTypeId vừa insert
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.err.println("Error insert RoomType: " + e.getMessage());
            throw e;
        }
        return -1;
    }

    // Cập nhật status của RoomType
    public void updateRoomTypeStatus(int id, String newStatus) {
        String sql = "UPDATE RoomTypes SET status = ? WHERE id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Cập nhật toàn bộ thông tin RoomType (Phương thức này chỉ có trong file 1)
    public void updateRoomType(RoomType roomType) {
        String sql = "UPDATE RoomTypes SET name = ?, description = ?, basePrice = ?, imageUrl = ?, capacity = ?, status = ?, updatedAt = GETDATE() WHERE id = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, roomType.getName());
            ps.setString(2, roomType.getDescription());
            ps.setBigDecimal(3, roomType.getBasePrice());
            ps.setString(4, roomType.getImageUrl());
            ps.setInt(5, roomType.getCapacity());
            ps.setString(6, roomType.getStatus());
            ps.setInt(7, roomType.getId());

            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Lấy danh sách Rooms theo RoomType
    public List<Room> getRoomsByType(int roomTypeId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM Rooms WHERE RoomTypeId = ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomTypeId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("Id"));
                room.setRoomNumber(rs.getString("RoomNumber"));
                room.setRoomTypeId(rs.getInt("RoomTypeId"));
                room.setStatus(rs.getString("Status"));
                list.add(room);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy danh sách Rooms available theo RoomType (Note: SQL có vẻ sai column name)
    public List<Room> getAvailableRoomsByType(int roomTypeId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM Rooms WHERE RoomTypeId = ? AND Status = 'AVAILABLE'"; // Đã sửa từ room_type_id và is_available

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomTypeId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Room room = new Room();
                room.setId(rs.getInt("Id"));
                room.setRoomNumber(rs.getString("RoomNumber"));
                room.setRoomTypeId(rs.getInt("RoomTypeId"));
                room.setStatus(rs.getString("Status"));
                list.add(room);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lọc RoomTypes theo các tiêu chí
    public List<RoomType> filterRoomTypes(String priceRange, String capacityValue, String statusValue) {
        List<RoomType> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM RoomTypes WHERE 1=1");

        // Danh sách parameter để set vào PreparedStatement
        List<Object> params = new ArrayList<>();

        // Lọc theo price (Note: SQL dùng column 'price' nhưng database dùng 'BasePrice')
        if (priceRange != null && !priceRange.isEmpty()) {
            switch (priceRange) {
                case "1":
                    sql.append(" AND BasePrice < ?"); // Đã sửa từ price thành BasePrice
                    params.add(500000);
                    break;
                case "2":
                    sql.append(" AND BasePrice BETWEEN ? AND ?"); // Đã sửa từ price thành BasePrice
                    params.add(500000);
                    params.add(1000000);
                    break;
                case "3":
                    sql.append(" AND BasePrice > ?"); // Đã sửa từ price thành BasePrice
                    params.add(1000000);
                    break;
            }
        }

        // Lọc theo capacity
        if (capacityValue != null && !capacityValue.isEmpty()) {
            switch (capacityValue) {
                case "1":
                    sql.append(" AND Capacity = ?"); // Đã sửa từ capacity thành Capacity
                    params.add(1);
                    break;
                case "2":
                    sql.append(" AND Capacity = ?"); // Đã sửa từ capacity thành Capacity
                    params.add(2);
                    break;
                case "3":
                    sql.append(" AND Capacity >= ?"); // Đã sửa từ capacity thành Capacity
                    params.add(3);
                    break;
            }
        }

        // Lọc theo status
        if (statusValue != null && !statusValue.isEmpty()) {
            sql.append(" AND Status = ?"); // Đã sửa từ status thành Status
            params.add(statusValue);
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // Gán các giá trị vào PreparedStatement
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                RoomType rtype = new RoomType(
                        rs.getInt("Id"),
                        rs.getString("Name"),
                        rs.getString("Description"),
                        rs.getBigDecimal("BasePrice"),
                        rs.getString("imageUrl"),
                        rs.getInt("Capacity"),
                        rs.getString("Status"),
                        rs.getTimestamp("CreatedAt"),
                        rs.getTimestamp("UpdatedAt")
                );
                list.add(rtype);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean isRoomTypeNameExists(String name, int excludeId) {
        String sql = "SELECT COUNT(*) FROM RoomTypes WHERE LOWER(name) = LOWER(?)";
        if (excludeId > 0) {
            sql += " AND id != ?";
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            if (excludeId > 0) {
                ps.setInt(2, excludeId);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<RoomType> getAllActiveRoomTypes() {
        List<RoomType> roomTypes = new ArrayList<>();
        String sql = "SELECT * FROM RoomTypes WHERE Status = 'ACTIVE' ORDER BY Name";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoomType roomType = new RoomType();
                roomType.setId(rs.getInt("Id"));
                roomType.setName(rs.getString("Name"));
                roomType.setDescription(rs.getString("Description"));
                roomType.setBasePrice(rs.getBigDecimal("BasePrice"));
                roomType.setCapacity(rs.getInt("Capacity"));
                roomType.setStatus(rs.getString("Status"));
                roomTypes.add(roomType);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return roomTypes;
    }

    public String getRoomImageFolderUrl(int roomTypeId) {
        String folderName = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // Câu lệnh SQL đúng: Lấy tên thư mục ảnh (ImageType)
        String sql = "SELECT TOP 1 ImageType FROM RoomTypeImages WHERE RoomTypeId = ?";

        try {
            conn = DBContext.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, roomTypeId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                folderName = rs.getString("ImageType");
            }

        } catch (SQLException e) {
            System.err.println("Error while fetching room image folder name: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (pstmt != null) {
                    pstmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return folderName;
    }

    public List<RoomTypeImage> getImagesByRoomTypeId(int roomTypeId) {
        List<RoomTypeImage> images = new ArrayList<>();

        String sql = "SELECT Id, RoomTypeId, ImageUrl, ImageType, DisplayOrder, CreatedAt "
                + "FROM RoomTypeImages WHERE RoomTypeId = ? ORDER BY DisplayOrder ASC, CreatedAt ASC";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomTypeId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                RoomTypeImage img = new RoomTypeImage();
                img.setId(rs.getInt("Id"));
                img.setRoomTypeId(rs.getInt("RoomTypeId"));
                img.setImageUrl(rs.getString("ImageUrl"));
                img.setImageType(rs.getString("ImageType"));
                img.setDisplayOrder(rs.getInt("DisplayOrder"));
                img.setCreatedAt(rs.getTimestamp("CreatedAt"));

                images.add(img);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return images;
    }

    public boolean insertRoomTypeImage(int roomTypeId, String fileName, String roomTypeName, int displayOrder) {
        String sql = "INSERT INTO RoomTypeImages (RoomTypeId, ImageUrl, ImageType, DisplayOrder, CreatedAt) "
                + "VALUES (?, ?, ?, ?, GETDATE())";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, roomTypeId);
            ps.setString(2, fileName); // imageUrl
            ps.setString(3, roomTypeName); // imageType
            ps.setInt(4, displayOrder);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getNextDisplayOrder(int roomTypeId) {
        String sql = "SELECT ISNULL(MAX(DisplayOrder), 0) + 1 FROM RoomTypeImages WHERE RoomTypeId = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, roomTypeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1;
    }

}
