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
    public boolean addFeedback(Feedback feedback) {
        String sql = "INSERT INTO feedback (ReservationId, UserId, Rating, Comment, CreatedAt) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, feedback.getReservationId());
            stmt.setInt(2, feedback.getUserId());
            stmt.setInt(3, feedback.getRating());
            stmt.setString(4, feedback.getComment());
            stmt.setTimestamp(5, new Timestamp(System.currentTimeMillis()));
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error adding feedback: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Lấy tất cả feedback của một user
     */
    public List<Feedback> getFeedbackByUserId(int userId) {
        String sql = "SELECT f.Id, f.ReservationId, f.UserId, f.Rating, f.Comment, f.CreatedAt " +
                    "FROM feedback f WHERE f.UserId = ? ORDER BY f.CreatedAt DESC";
        
        List<Feedback> feedbacks = new ArrayList<>();
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("Id"));
                feedback.setReservationId(rs.getInt("ReservationId"));
                feedback.setUserId(rs.getInt("UserId"));
                feedback.setRating(rs.getInt("Rating"));
                feedback.setComment(rs.getString("Comment"));
                feedback.setCreatedAt(rs.getTimestamp("CreatedAt"));
                
                feedbacks.add(feedback);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting feedback by user ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return feedbacks;
    }
    
    /**
     * Lấy feedback theo reservation ID
     */
    public Feedback getFeedbackByReservationId(int reservationId) {
        String sql = "SELECT Id, ReservationId, UserId, Rating, Comment, CreatedAt " +
                    "FROM feedback WHERE ReservationId = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, reservationId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("Id"));
                feedback.setReservationId(rs.getInt("ReservationId"));
                feedback.setUserId(rs.getInt("UserId"));
                feedback.setRating(rs.getInt("Rating"));
                feedback.setComment(rs.getString("Comment"));
                feedback.setCreatedAt(rs.getTimestamp("CreatedAt"));
                
                return feedback;
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting feedback by reservation ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Lấy feedback theo ID
     */
    public Feedback getFeedbackById(int id) {
        String sql = "SELECT Id, ReservationId, UserId, Rating, Comment, CreatedAt " +
                    "FROM feedback WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("Id"));
                feedback.setReservationId(rs.getInt("ReservationId"));
                feedback.setUserId(rs.getInt("UserId"));
                feedback.setRating(rs.getInt("Rating"));
                feedback.setComment(rs.getString("Comment"));
                feedback.setCreatedAt(rs.getTimestamp("CreatedAt"));
                
                return feedback;
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting feedback by ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Lấy tất cả feedback (cho admin)
     */
    public List<Feedback> getAllFeedback() {
        String sql = "SELECT f.Id, f.ReservationId, f.UserId, f.Rating, f.Comment, f.CreatedAt " +
                    "FROM feedback f ORDER BY f.CreatedAt DESC";
        
        List<Feedback> feedbacks = new ArrayList<>();
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("Id"));
                feedback.setReservationId(rs.getInt("ReservationId"));
                feedback.setUserId(rs.getInt("UserId"));
                feedback.setRating(rs.getInt("Rating"));
                feedback.setComment(rs.getString("Comment"));
                feedback.setCreatedAt(rs.getTimestamp("CreatedAt"));
                
                feedbacks.add(feedback);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting all feedback: " + e.getMessage());
            e.printStackTrace();
        }
        
        return feedbacks;
    }
    
    /**
     * Cập nhật feedback
     */
    public boolean updateFeedback(Feedback feedback) {
        String sql = "UPDATE feedback SET Rating = ?, Comment = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, feedback.getRating());
            stmt.setString(2, feedback.getComment());
            stmt.setInt(3, feedback.getId());
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating feedback: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Xóa feedback
     */
    public boolean deleteFeedback(int id) {
        String sql = "DELETE FROM feedback WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error deleting feedback: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Kiểm tra xem user đã feedback cho reservation này chưa
     */
    public boolean hasUserFeedbackForReservation(int userId, int reservationId) {
        String sql = "SELECT COUNT(*) FROM feedback WHERE UserId = ? AND ReservationId = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, reservationId);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error checking existing feedback: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Lấy feedback với thông tin chi tiết (join với reservation và user)
     */
    public List<Feedback> getFeedbackWithDetails() {
        String sql = "SELECT f.Id, f.ReservationId, f.UserId, f.Rating, f.Comment, f.CreatedAt, " +
                    "u.Username, u.Email, r.CheckInDate, r.CheckOutDate " +
                    "FROM feedback f " +
                    "JOIN users u ON f.UserId = u.Id " +
                    "JOIN reservations r ON f.ReservationId = r.Id " +
                    "ORDER BY f.CreatedAt DESC";
        
        List<Feedback> feedbacks = new ArrayList<>();
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("Id"));
                feedback.setReservationId(rs.getInt("ReservationId"));
                feedback.setUserId(rs.getInt("UserId"));
                feedback.setRating(rs.getInt("Rating"));
                feedback.setComment(rs.getString("Comment"));
                feedback.setCreatedAt(rs.getTimestamp("CreatedAt"));
                
                // Thêm thông tin user và reservation nếu cần
                // feedback.setUsername(rs.getString("Username"));
                // feedback.setEmail(rs.getString("Email"));
                // feedback.setCheckInDate(rs.getDate("CheckInDate"));
                // feedback.setCheckOutDate(rs.getDate("CheckOutDate"));
                
                feedbacks.add(feedback);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting feedback with details: " + e.getMessage());
            e.printStackTrace();
        }
        
        return feedbacks;
    }
    
    /**
     * Lấy rating trung bình
     */
    public double getAverageRating() {
        String sql = "SELECT AVG(CAST(Rating AS FLOAT)) FROM feedback";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting average rating: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0.0;
    }
    
    /**
     * Đếm tổng số feedback
     */
    public int getTotalFeedbackCount() {
        String sql = "SELECT COUNT(*) FROM feedback";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting feedback count: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * Lấy feedback theo rating
     */
    public List<Feedback> getFeedbackByRating(int rating) {
        String sql = "SELECT Id, ReservationId, UserId, Rating, Comment, CreatedAt " +
                    "FROM feedback WHERE Rating = ? ORDER BY CreatedAt DESC";
        
        List<Feedback> feedbacks = new ArrayList<>();
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, rating);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Feedback feedback = new Feedback();
                feedback.setId(rs.getInt("Id"));
                feedback.setReservationId(rs.getInt("ReservationId"));
                feedback.setUserId(rs.getInt("UserId"));
                feedback.setRating(rs.getInt("Rating"));
                feedback.setComment(rs.getString("Comment"));
                feedback.setCreatedAt(rs.getTimestamp("CreatedAt"));
                
                feedbacks.add(feedback);
            }
            
        } catch (SQLException e) {
            System.err.println("Error getting feedback by rating: " + e.getMessage());
            e.printStackTrace();
        }
        
        return feedbacks;
    }
}
