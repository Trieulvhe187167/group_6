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

    /**
     * (Nếu cần) Lấy RoomType theo một tiêu chí cụ thể.
     * Chỉ ví dụ, nên sửa lại query và params theo bảng RoomTypes.
     */
    public List<RoomType> getRoomTypesByCapacity(int minCapacity) {
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
