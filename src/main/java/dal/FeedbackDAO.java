package dal;

import java.sql.*;
import java.util.*;
import java.util.stream.Collectors;
import model.Feedback;
import model.RatingStats;
public class FeedbackDAO {
    public List<Feedback> getFeedbacksByUser(int userId) {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT * FROM Feedback WHERE UserId = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Feedback f = new Feedback();
                f.setId(rs.getInt("Id"));
                f.setReservationId(rs.getInt("ReservationId"));
                f.setUserId(rs.getInt("UserId"));
                f.setRating(rs.getInt("Rating"));
                f.setComment(rs.getString("Comment"));
                f.setCreatedAt(rs.getTimestamp("CreatedAt"));
                list.add(f);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
     /**
     * Retrieve feedback for a specific room type ordered by latest date
     */
    public List<Feedback> getFeedbacksByRoomType(int roomTypeId) {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT f.Id, f.ReservationId, f.UserId, f.Rating, f.Comment, f.CreatedAt, u.FullName " +
                     "FROM Feedback f " +
                     "JOIN Reservations r ON f.ReservationId = r.Id " +
                     "LEFT JOIN Rooms rm ON r.RoomId = rm.Id " +
                     "JOIN Users u ON f.UserId = u.Id " +
                     "WHERE (r.RoomTypeId = ? OR rm.RoomTypeId = ?) " +
                     "ORDER BY f.CreatedAt DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomTypeId);
            ps.setInt(2, roomTypeId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Feedback f = new Feedback();
                    f.setId(rs.getInt("Id"));
                    f.setReservationId(rs.getInt("ReservationId"));
                    f.setUserId(rs.getInt("UserId"));
                    f.setRating(rs.getInt("Rating"));
                    f.setComment(rs.getString("Comment"));
                    f.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    f.setUserFullName(rs.getString("FullName"));
                    list.add(f);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
     /**
     * Get average rating and review count for multiple room types.
     */
    public Map<Integer, RatingStats> getRatingStatsForRoomTypes(List<Integer> roomTypeIds) {
        Map<Integer, RatingStats> map = new HashMap<>();
        if (roomTypeIds == null || roomTypeIds.isEmpty()) {
            return map;
        }

        String placeholders = roomTypeIds.stream()
                .map(id -> "?")
                .collect(Collectors.joining(","));

        String sql = "SELECT COALESCE(r.RoomTypeId, rm.RoomTypeId) AS RoomTypeId, " +
                     "COUNT(f.Id) AS ReviewCount, AVG(CAST(f.Rating AS FLOAT)) AS AvgRating " +
                     "FROM Feedback f " +
                     "JOIN Reservations r ON f.ReservationId = r.Id " +
                     "LEFT JOIN Rooms rm ON r.RoomId = rm.Id " +
                     "WHERE COALESCE(r.RoomTypeId, rm.RoomTypeId) IN (" + placeholders + ") " +
                     "GROUP BY COALESCE(r.RoomTypeId, rm.RoomTypeId)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            int index = 1;
            for (Integer id : roomTypeIds) {
                ps.setInt(index++, id);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int rtId = rs.getInt("RoomTypeId");
                    RatingStats stats = new RatingStats();
                    stats.setReviewCount(rs.getInt("ReviewCount"));
                    stats.setAverageRating(rs.getDouble("AvgRating"));
                    map.put(rtId, stats);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }
}