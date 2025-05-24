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
                rtype.setCapacity(rs.getInt("Capacity"));
                rtype.setCreatedAt(rs.getTimestamp("CreatedAt"));
                rtype.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                rtype.setImageUrl(rs.getString("image_url"));
                listRoom.add(rtype);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listRoom;
    }
}
