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
import java.security.Timestamp;
import model.Room;
import model.RoomType;

/**
 *
 * @author ASUS
 */
public class RoomTypeDAO {

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

//Tìm kiếm
    public List<RoomType> searchRooms(String keyword) {
        List<RoomType> list = new ArrayList<>();
        String sql = "SELECT * FROM RoomTypes WHERE Name LIKE ? OR CAST(BasePrice AS VARCHAR) LIKE ? OR CAST(Capacity AS VARCHAR) LIKE ?";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql);) {

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

    public List<RoomType> getRoomsByCategory(String category) {
        List<RoomType> listRoom = new ArrayList<>();
        String sql = "SELECT * FROM Rooms WHERE category = ?";

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

    public List<RoomType> getAvailableRoomTypes() {
        List<RoomType> list = new ArrayList<>();
        String sql = "SELECT * FROM RoomType WHERE status = 'active'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RoomType rtype = new RoomType();
                rtype.setName(rs.getString("Name"));
                rtype.setDescription(rs.getString("Description"));
                rtype.setBasePrice(rs.getBigDecimal("BasePrice"));
                rtype.setImageUrl(rs.getString("imageUrl"));
                rtype.setCapacity(rs.getInt("Capacity"));
                list.add(rtype);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

//Thêm, tạo
    public void insert(RoomType roomType) throws SQLException {
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
        } catch (Exception e) {
            System.err.println("Lỗi khi insert RoomType: " + e.getMessage());
            throw e;
        }

    }

//Sửa
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

    public List<Room> getAvailableRoomsByType(int roomTypeId) {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM Rooms WHERE room_type_id = ? AND is_available = 1";

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

//Lọc
    public List<RoomType> filterRoomTypes(String priceRange, String capacityValue, String statusValue) {
        List<RoomType> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM RoomTypes WHERE 1=1");

        // Danh sách parameter để set vào PreparedStatement
        List<Object> params = new ArrayList<>();

        if (priceRange != null && !priceRange.isEmpty()) {
            switch (priceRange) {
                case "1":
                    sql.append(" AND price < ?");
                    params.add(500000);
                    break;
                case "2":
                    sql.append(" AND price BETWEEN ? AND ?");
                    params.add(500000);
                    params.add(1000000);
                    break;
                case "3":
                    sql.append(" AND price > ?");
                    params.add(1000000);
                    break;
            }
        }

        if (capacityValue != null && !capacityValue.isEmpty()) {
            switch (capacityValue) {
                case "1":
                    sql.append(" AND capacity = ?");
                    params.add(1);
                    break;
                case "2":
                    sql.append(" AND capacity = ?");
                    params.add(2);
                    break;
                case "3":
                    sql.append(" AND capacity >= ?");
                    params.add(3);
                    break;
            }
        }

        if (statusValue != null && !statusValue.isEmpty()) {
            sql.append(" AND status = ?");
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

}
