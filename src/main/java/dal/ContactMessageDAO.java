package dal;

import model.ContactMessage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ContactMessageDAO {

    public boolean addMessage(ContactMessage message) {
        String sql = "INSERT INTO ContactMessages (Name, Email, Phone, Message, CreatedAt, feedbackId) VALUES (?, ?, ?, ?, GETDATE(), ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            System.out.println("[CONTACT-DAO-DEBUG] SQL: " + sql);
            System.out.println("[CONTACT-DAO-DEBUG] Name: " + message.getName());
            System.out.println("[CONTACT-DAO-DEBUG] Email: " + message.getEmail());
            System.out.println("[CONTACT-DAO-DEBUG] Phone: " + message.getPhone());
            System.out.println("[CONTACT-DAO-DEBUG] Message: " + message.getMessage());
            System.out.println("[CONTACT-DAO-DEBUG] feedbackId: " + message.getFeedbackId());

            ps.setString(1, message.getName());
            ps.setString(2, message.getEmail());
            ps.setString(3, message.getPhone());
            ps.setString(4, message.getMessage());
            if (message.getFeedbackId() != null) {
                ps.setInt(5, message.getFeedbackId());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }

            int result = ps.executeUpdate();
            System.out.println("[CONTACT-DAO-DEBUG] executeUpdate result: " + result);
            return result > 0;
        } catch (SQLException e) {
            System.err.println("[CONTACT-DAO-ERROR] SQL Exception: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception ex) {
            System.err.println("[CONTACT-DAO-ERROR] Exception: " + ex.getMessage());
            ex.printStackTrace();
        }
        return false;
    }

    public List<ContactMessage> getAllMessages() {
        List<ContactMessage> list = new ArrayList<>();
        String sql = "SELECT * FROM ContactMessages ORDER BY CreatedAt DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ContactMessage msg = new ContactMessage();
                msg.setId(rs.getInt("Id"));
                msg.setName(rs.getString("Name"));
                msg.setEmail(rs.getString("Email"));
                msg.setPhone(rs.getString("Phone"));
                msg.setMessage(rs.getString("Message"));
                msg.setCreatedAt(rs.getTimestamp("CreatedAt"));
                msg.setFeedbackId(rs.getObject("feedbackId") != null ? rs.getInt("feedbackId") : null);
                list.add(msg);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateMessage(ContactMessage message) {
        String sql = "UPDATE ContactMessages SET Name = ?, Email = ?, Phone = ?, Message = ? WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, message.getName());
            ps.setString(2, message.getEmail());
            ps.setString(3, message.getPhone());
            ps.setString(4, message.getMessage());
            ps.setInt(5, message.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<ContactMessage> getMessagesByFeedbackId(int feedbackId) {
        List<ContactMessage> list = new ArrayList<>();
        String sql = "SELECT * FROM ContactMessages WHERE feedbackId = ? ORDER BY CreatedAt ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, feedbackId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ContactMessage msg = new ContactMessage();
                    msg.setId(rs.getInt("Id"));
                    msg.setName(rs.getString("Name"));
                    msg.setEmail(rs.getString("Email"));
                    msg.setPhone(rs.getString("Phone"));
                    msg.setMessage(rs.getString("Message"));
                    msg.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    msg.setFeedbackId(rs.getInt("feedbackId"));
                    list.add(msg);
                }
            }
        } catch (SQLException e) {
            System.err.println("[CONTACT-DAO-ERROR] getMessagesByFeedbackId: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}
