package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.Feedback;

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
}