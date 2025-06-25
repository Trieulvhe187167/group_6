package dal;


import model.Notification;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {
    
    public List<Notification> getAllNotifications() {
        List<Notification> notifications = new ArrayList<>();
        String sql = "SELECT n.*, u.FullName as RecipientName " +
                    "FROM Notifications n " +
                    "LEFT JOIN Users u ON n.UserId = u.Id " +
                    "ORDER BY n.SentAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Notification notification = new Notification();
                notification.setId(rs.getInt("Id"));
                notification.setUserId(rs.getInt("UserId"));
                notification.setReservationId(rs.getObject("ReservationId") != null ? 
                    rs.getInt("ReservationId") : null);
                notification.setType(rs.getString("Type"));
                notification.setMessage(rs.getString("Message"));
                notification.setSentAt(rs.getTimestamp("SentAt"));
                notification.setStatus(rs.getString("Status"));
                notification.setRecipientName(rs.getString("RecipientName"));
                notifications.add(notification);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return notifications;
    }
    
    public boolean sendNotification(Notification notification) {
        String sql = "INSERT INTO Notifications (UserId, ReservationId, Type, Message, SentAt, Status) " +
                    "VALUES (?, ?, ?, ?, GETDATE(), 'SENT')";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, notification.getUserId());
            if (notification.getReservationId() != null) {
                ps.setInt(2, notification.getReservationId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, notification.getType());
            ps.setString(4, notification.getMessage());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public boolean resendNotification(int notificationId) {
        String sql = "UPDATE Notifications SET SentAt = GETDATE(), Status = 'SENT' WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, notificationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public int getTotalNotifications() {
        String sql = "SELECT COUNT(*) FROM Notifications";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    public int getNotificationCountByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Notifications WHERE Status = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}