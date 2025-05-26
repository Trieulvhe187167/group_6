package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import model.RoomType;

public class RoomTypeDAO {

    /** Lấy tất cả RoomType từ bảng RoomTypes */
    public List<RoomType> getAllRoomTypes() {
        List<RoomType> listRoom = new ArrayList<>();
        String sql = "SELECT Id, Name, Description, imageUrl, BasePrice, Capacity, CreatedAt, UpdatedAt "
                   + "FROM RoomTypes";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoomType rtype = new RoomType();
                rtype.setId(rs.getInt("Id"));
                rtype.setName(rs.getString("Name"));
                rtype.setDescription(rs.getString("Description"));
                // Đổi tên cột cho khớp schema: imageUrl (không phải image_url)
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
                        rs.getString("image_url"),
                        rs.getBigDecimal("BasePrice"),
                        rs.getInt("Capacity"),
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
        String sql = "SELECT Id, Name, Description, imageUrl, BasePrice, Capacity, CreatedAt, UpdatedAt "
                   + "FROM RoomTypes WHERE Capacity >= ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, minCapacity);
            try (ResultSet rs = ps.executeQuery()) {
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
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listRoom;
    }

    // Loại bỏ hoàn toàn phương thức getRoomsByCategory,
    // vì nó đang query sai bảng (Rooms) mà ánh xạ vào RoomType.
}
