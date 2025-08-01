/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import model.*;
import java.sql.*;
import java.util.*;

/**
 *
 * @author ASUS
 */
public class CustomerSupportDAO {
    // Insert a support request

    public void insertSupportRequest(SupportRequest request) throws SQLException {
        String sql = "INSERT INTO SupportRequests (UserId, RoomId, Title, Description, Status, CreatedAt, UpdatedAt) "
                + "VALUES (?, ?, ?, ?, ?, GETDATE(), GETDATE())";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, request.getUserId());
            ps.setInt(2, request.getRoomId());
            ps.setString(3, request.getTitle());
            ps.setString(4, request.getDescription());
            ps.setString(5, request.getStatus());
            ps.executeUpdate();
        }
    }

    // Get rooms where status = OCCUPIED
    public List<Room> getOccupiedRooms(int userId) throws SQLException {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT DISTINCT r.Id, r.RoomNumber FROM Rooms r "
                + "JOIN Reservations res ON r.Id = res.RoomId "
                + "WHERE r.Status = 'OCCUPIED' AND res.UserId = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Room r = new Room();
                    r.setId(rs.getInt("Id"));
                    r.setRoomNumber(rs.getString("RoomNumber"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    // Lấy danh sách yêu cầu hỗ trợ theo userId
    public List<SupportRequest> getSupportRequestsByUser(int userId, String filter, String sort) throws SQLException {
    List<SupportRequest> list = new ArrayList<>();
    StringBuilder sql = new StringBuilder(
        "SELECT sr.*, r.RoomNumber " +
        "FROM SupportRequests sr " +
        "JOIN Rooms r ON sr.RoomId = r.Id " +
        "WHERE sr.UserId = ?"
    );

    // Thêm điều kiện filter theo Status nếu khác 'all'
    if (filter != null && !filter.equalsIgnoreCase("all")) {
        sql.append(" AND sr.Status = ?");
    }

    // Sắp xếp theo Title hoặc CreatedAt
    if ("title".equalsIgnoreCase(sort)) {
        sql.append(" ORDER BY sr.Title ASC");
    } else {
        sql.append(" ORDER BY sr.CreatedAt DESC"); // Mặc định
    }

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql.toString())) {

        ps.setInt(1, userId);
        if (filter != null && !filter.equalsIgnoreCase("all")) {
            ps.setString(2, filter.toUpperCase());
        }

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            SupportRequest sr = new SupportRequest();
            sr.setId(rs.getInt("Id"));
            sr.setUserId(rs.getInt("UserId"));
            sr.setRoomId(rs.getInt("RoomId"));
            sr.setTitle(rs.getString("Title"));
            sr.setDescription(rs.getString("Description"));
            sr.setStatus(rs.getString("Status"));
            sr.setCreatedAt(rs.getTimestamp("CreatedAt"));
            sr.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
            sr.setRoomNumber(rs.getString("RoomNumber"));

            list.add(sr);
        }
    }

    return list;
}


    // Get all support requests
    public List<SupportRequest> getAllSupportRequests() throws SQLException {
        List<SupportRequest> list = new ArrayList<>();
        String sql = "SELECT sr.*, u.FullName, r.RoomNumber "
                + "FROM SupportRequests sr "
                + "JOIN Users u ON sr.UserId = u.Id "
                + "JOIN Rooms r ON sr.RoomId = r.Id "
                + "ORDER BY sr.CreatedAt DESC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SupportRequest sr = new SupportRequest();
                sr.setId(rs.getInt("Id"));
                sr.setUserId(rs.getInt("UserId"));
                sr.setRoomId(rs.getInt("RoomId"));
                sr.setTitle(rs.getString("Title"));
                sr.setDescription(rs.getString("Description"));
                sr.setStatus(rs.getString("Status"));
                sr.setCreatedAt(rs.getTimestamp("CreatedAt"));
                sr.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                sr.setUserName(rs.getString("FullName"));
                sr.setRoomNumber(rs.getString("RoomNumber"));

                list.add(sr);
            }
        }
        return list;
    }

    public boolean isRoomOccupiedByUser(int roomId, int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Reservations WHERE RoomId = ? AND UserId = ? AND Status = 'CHECKED_IN'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roomId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

}
