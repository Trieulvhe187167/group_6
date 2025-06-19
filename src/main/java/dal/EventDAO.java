package dal;

import model.Event;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {
    /**
     * Lấy danh sách tất cả sự kiện, sắp xếp theo StartAt
     */
    public List<Event> getAllEvents() {
        List<Event> list = new ArrayList<>();
        String sql = "SELECT Id, Title, Description, Location, StartAt, EndAt, Status, ImageUrl "
                   + "FROM dbo.Events "
                   + "ORDER BY StartAt";
        
        // Dùng DBContext để lấy connection
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Event e = new Event();
                e.setId(rs.getInt("Id"));
                e.setTitle(rs.getString("Title"));
                e.setDescription(rs.getString("Description"));
                e.setLocation(rs.getString("Location"));
                e.setStartAt(rs.getTimestamp("StartAt"));
                e.setEndAt(rs.getTimestamp("EndAt"));
                e.setStatus(rs.getString("Status"));
                e.setImageUrl(rs.getString("ImageUrl"));
                list.add(e);
            }
            
        } catch (SQLException ex) {
            ex.printStackTrace();
            // Có thể log hoặc ném exception tuỳ nhu cầu
        }
        
        return list;
    }
    
    /**
     * Lấy Event theo Id
     */
    public Event getEventById(int id) {
        String sql = "SELECT Id, Title, Description, Location, StartAt, EndAt, Status, ImageUrl "
                   + "FROM dbo.Events "
                   + "WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Event e = new Event();
                    e.setId(rs.getInt("Id"));
                    e.setTitle(rs.getString("Title"));
                    e.setDescription(rs.getString("Description"));
                    e.setLocation(rs.getString("Location"));
                    e.setStartAt(rs.getTimestamp("StartAt"));
                    e.setEndAt(rs.getTimestamp("EndAt"));
                    e.setStatus(rs.getString("Status"));
                    e.setImageUrl(rs.getString("ImageUrl"));
                    return e;
                }
            }
            
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }
    
    // Bạn có thể bổ sung thêm các phương thức insert/update/delete tuỳ nhu cầu
}
