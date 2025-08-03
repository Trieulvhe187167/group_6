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
                "SELECT sr.*, r.RoomNumber "
                + "FROM SupportRequests sr "
                + "JOIN Rooms r ON sr.RoomId = r.Id "
                + "WHERE sr.UserId = ?"
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

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

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

    //New
    public List<SupportReply> getRepliesByRequestId(int requestId) throws SQLException {
        List<SupportReply> list = new ArrayList<>();
        String sql = "SELECT sr.*, u.FullName FROM SupportReplies sr "
                + "JOIN Users u ON sr.StaffId = u.Id "
                + "WHERE sr.RequestId = ? ORDER BY sr.CreatedAt ASC";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                SupportReply reply = new SupportReply();
                reply.setId(rs.getInt("Id"));
                reply.setRequestId(rs.getInt("RequestId"));
                reply.setStaffId(rs.getInt("StaffId"));
                reply.setMessage(rs.getString("Message"));
                reply.setCreatedAt(rs.getTimestamp("CreatedAt"));
                reply.setStaffName(rs.getString("FullName"));
                list.add(reply);
            }
        }
        return list;
    }

    // Get a single support request by its ID
    public SupportRequest getSupportRequestById(int requestId) throws SQLException {
        String sql = "SELECT sr.id, sr.userId, sr.roomId, sr.title, sr.description, sr.status, sr.createdAt, sr.updatedAt, "
                + "u.fullName AS userName, r.roomNumber AS roomNumber "
                + "FROM SupportRequests sr "
                + "JOIN Users u ON sr.userId = u.id "
                + "LEFT JOIN Rooms r ON sr.roomId = r.id "
                + "WHERE sr.id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    SupportRequest sr = new SupportRequest();
                    sr.setId(rs.getInt("id"));
                    sr.setUserId(rs.getInt("userId"));
                    sr.setRoomId(rs.getInt("roomId")); // đúng tên trường
                    sr.setTitle(rs.getString("title"));
                    sr.setDescription(rs.getString("description"));
                    sr.setStatus(rs.getString("status"));
                    sr.setCreatedAt(rs.getTimestamp("createdAt"));
                    sr.setUpdatedAt(rs.getTimestamp("updatedAt"));
                    sr.setUserName(rs.getString("userName"));       // biến bổ sung
                    sr.setRoomNumber(rs.getString("roomNumber"));   // biến bổ sung
                    return sr;
                }
            }
        }
        return null;
    }

    // Get filtered and sorted support requests for receptionist view
    public List<SupportRequest> getFilteredSupportRequests(String roomNumber, String status, String sortBy) throws SQLException {
        List<SupportRequest> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT sr.*, u.fullName AS userName, r.roomNumber "
                + "FROM SupportRequests sr "
                + "JOIN Users u ON sr.userId = u.id "
                + "JOIN Rooms r ON sr.roomId = r.id "
                + "WHERE 1 = 1 "
        );

        List<Object> params = new ArrayList<>();

        // Filter by roomNumber
        if (roomNumber != null && !roomNumber.isEmpty()) {
            sql.append("AND r.roomNumber = ? ");
            params.add(roomNumber);
        }

        // Filter by status
        if (status != null && !status.isEmpty()) {
            sql.append("AND sr.status = ? ");
            params.add(status);
        }

        // Sort by column
        if ("createdAt".equals(sortBy)) {
            sql.append("ORDER BY sr.createdAt DESC ");
        } else if ("requestId".equals(sortBy)) {
            sql.append("ORDER BY sr.id ASC ");
        } else {
            sql.append("ORDER BY sr.createdAt DESC "); // default
        }

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SupportRequest request = new SupportRequest();
                    request.setId(rs.getInt("id"));
                    request.setUserId(rs.getInt("userId"));
                    request.setRoomId(rs.getInt("roomId"));
                    request.setTitle(rs.getString("title"));
                    request.setDescription(rs.getString("description"));
                    request.setStatus(rs.getString("status"));
                    request.setCreatedAt(rs.getTimestamp("createdAt"));
                    request.setUpdatedAt(rs.getTimestamp("updatedAt"));

                    // Additional info
                    request.setUserName(rs.getString("userName"));
                    request.setRoomNumber(rs.getString("roomNumber"));

                    list.add(request);
                }
            }
        }

        return list;
    }

    // Lấy danh sách tất cả roomNumber có trong SupportRequests
    public Set<String> getAllRoomNumbersInRequests() throws SQLException {
        Set<String> roomNumbers = new TreeSet<>();
        String sql = "SELECT DISTINCT R.roomNumber FROM SupportRequests SR "
                + "JOIN Rooms R ON SR.roomId = R.id";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                roomNumbers.add(rs.getString("roomNumber"));
            }
        }

        return roomNumbers;
    }

    public void insertReply(int requestId, int staffId, String message) throws SQLException {
        String sql = "INSERT INTO SupportReplies (RequestId, StaffId, Message, CreatedAt) "
                + "VALUES (?, ?, ?, GETDATE())";

        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, staffId);
            ps.setString(3, message);
            ps.executeUpdate();
        }
    }

    public void updateSupportRequestStatus(int requestId, String status) throws SQLException {
        String sql = "UPDATE SupportRequests SET Status = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, requestId);
            ps.executeUpdate();
        }
    }

}
