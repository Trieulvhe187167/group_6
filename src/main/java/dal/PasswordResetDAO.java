package dal;

import java.sql.*;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.User;

public class PasswordResetDAO {

    private static final Logger LOGGER = Logger.getLogger(PasswordResetDAO.class.getName());

    public User findUserByEmail(String email) {
        String sql = "SELECT * FROM Users WHERE Email = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("Id"));
                user.setUsername(rs.getString("Username"));
                user.setFullName(rs.getString("FullName"));
                user.setEmail(rs.getString("Email"));
                return user;
            }

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error finding user by email", ex);
        }
        return null;
    }

   public String createResetToken(int userId) {
    String token = UUID.randomUUID().toString();
    Timestamp createdAt = new Timestamp(System.currentTimeMillis());
    Timestamp expiry = new Timestamp(System.currentTimeMillis() + 60 * 60 * 1000); 

    String sql = "INSERT INTO PasswordResetTokens (UserId, Token, Expiry) VALUES (?, ?, ?)";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, userId);
        ps.setString(2, token);
        ps.setTimestamp(3, expiry);  // thêm dòng này
        ps.executeUpdate();

    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "Error creating reset token", ex);
    }

    return token;
}


    public boolean updatePassword(String token, String hashedPassword) {
        String sql = "UPDATE Users SET PasswordHash = ?, UpdatedAt = GETDATE() WHERE Id = " +
                     "(SELECT UserId FROM PasswordResetTokens WHERE Token = ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, hashedPassword);
            ps.setString(2, token);
            return ps.executeUpdate() > 0;

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating password by token", ex);
        }
        return false;
    }

    public void updatePassword(int userId, String newHashedPassword) {
        String sql = "UPDATE Users SET PasswordHash = ?, UpdatedAt = GETDATE() WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newHashedPassword);
            ps.setInt(2, userId);
            ps.executeUpdate();

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error updating password by userId", ex);
        }
    }

    public boolean isValidToken(String token) {
        String sql = "SELECT * FROM PasswordResetTokens WHERE Token = ? AND Expiry > GETDATE()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error checking token validity", ex);
        }
        return false;
    }

    public void deleteTokenByUserId(int userId) {
        String sql = "DELETE FROM PasswordResetTokens WHERE UserId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();

        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting token by userId", ex);
        }
    }
    public void deleteToken(String token) {
    String sql = "DELETE FROM PasswordResetTokens WHERE Token = ?";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, token);
        ps.executeUpdate();

    } catch (SQLException ex) {
        Logger.getLogger(PasswordResetDAO.class.getName()).log(Level.SEVERE, "Error deleting token", ex);
    }
}

}
