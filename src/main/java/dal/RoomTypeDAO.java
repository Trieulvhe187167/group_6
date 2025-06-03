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
                rtype.setImageUrl(rs.getString("imageUrl"));
                rtype.setBasePrice(rs.getBigDecimal("BasePrice"));
                rtype.setCapacity(rs.getInt("Capacity"));
                rtype.setCreatedAt(rs.getTimestamp("CreatedAt"));
                rtype.setUpdatedAt(rs.getTimestamp("UpdatedAt"));

                listRoom.add(rtype);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listRoom;
    }

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
                        rs.getString("imageUrl"),
                        rs.getBigDecimal("BasePrice"),
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
                        rs.getString("imageUrl"),
                        rs.getBigDecimal("BasePrice"),
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
                        rs.getString("imageUrl"),
                        rs.getBigDecimal("BasePrice"),
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
                rtype.setImageUrl(rs.getString("imageUrl"));
                rtype.setBasePrice(rs.getBigDecimal("BasePrice"));
                rtype.setCapacity(rs.getInt("Capacity"));
                list.add(rtype);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void insert(RoomType roomType) throws SQLException {
        String sql = "INSERT INTO RoomTypes (name, description, imageUrl, basePrice, capacity, status, createdAt, updatedAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roomType.getName());
            ps.setString(2, roomType.getDescription());
            ps.setString(3, roomType.getImageUrl());
            ps.setBigDecimal(4, roomType.getBasePrice());
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

}
