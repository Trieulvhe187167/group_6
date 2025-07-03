package dal;

import model.ContactMessage;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ContactMessageDAO {

    public boolean addMessage(ContactMessage message) {
        String sql = "INSERT INTO ContactMessages (Name, Email, Phone, Message, CreatedAt) VALUES (?, ?, ?, ?, GETDATE())";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, message.getName());
            ps.setString(2, message.getEmail());
            ps.setString(3, message.getPhone());
            ps.setString(4, message.getMessage());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
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
}