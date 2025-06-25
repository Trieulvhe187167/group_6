package dal;

import model.PendingChange;
import java.sql.*;
import java.util.*;
import java.util.Date;

public class VerificationDAO extends DBContext {
    
    // Create a new change request
    public PendingChange createChangeRequest(PendingChange change) {
        String sql = "EXEC sp_InitiateChangeRequest ?, ?, ?, ?, ?, ?, ?, ?";
        
        try (Connection conn = getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            stmt.setInt(1, change.getUserId());
            stmt.setInt(2, change.getInitiatedBy());
            stmt.setString(3, change.getChangeType());
            stmt.setString(4, change.getNewEmail());
            stmt.setString(5, change.getNewPhone());
            stmt.setString(6, change.getNewPasswordHash());
            stmt.setString(7, change.getChangeReason());
            stmt.setInt(8, 48); // 48 hours expiry
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    change.setId(rs.getInt("PendingChangeId"));
                    change.setVerificationToken(rs.getString("VerificationToken"));
                    return change;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Get pending change by token
    public PendingChange getPendingChangeByToken(String token) {
        String sql = """
            SELECT pc.*, u.FullName as UserName, u.Role as UserRole, 
                   admin.FullName as InitiatedByName
            FROM PendingChanges pc
            INNER JOIN Users u ON pc.UserId = u.Id
            INNER JOIN Users admin ON pc.InitiatedBy = admin.Id
            WHERE pc.VerificationToken = ? AND pc.Status = 'PENDING' AND pc.TokenExpiry > GETDATE()
            """;
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, token);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToPendingChange(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Approve change request
    public boolean approveChangeRequest(String token) {
        String sql = "EXEC sp_ApproveChangeRequest ?";
        
        try (Connection conn = getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            stmt.setString(1, token);
            
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && "SUCCESS".equals(rs.getString("Result"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Reject change request
    public boolean rejectChangeRequest(String token, String reason) {
        String sql = """
            UPDATE PendingChanges 
            SET Status = 'REJECTED', RejectedAt = GETDATE(), RejectionReason = ?
            WHERE VerificationToken = ? AND Status = 'PENDING'
            """;
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, reason);
            stmt.setString(2, token);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get all pending changes with pagination
    public List<PendingChange> getPendingChangesPaginated(int page, int pageSize) {
        List<PendingChange> changes = new ArrayList<>();
        String sql = """
            SELECT * FROM vw_PendingChangesSummary 
            ORDER BY CreatedAt DESC
            OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
            """;
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, (page - 1) * pageSize);
            stmt.setInt(2, pageSize);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    changes.add(mapResultSetToPendingChange(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return changes;
    }
    
    // Get pending changes for a specific user
    public List<PendingChange> getPendingChangesForUser(int userId) {
        List<PendingChange> changes = new ArrayList<>();
        String sql = """
            SELECT * FROM vw_PendingChangesSummary 
            WHERE UserId = ? AND Status IN ('PENDING', 'APPROVED', 'REJECTED')
            ORDER BY CreatedAt DESC
            """;
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    changes.add(mapResultSetToPendingChange(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return changes;
    }
    
    // Update notification status
    public boolean updateNotificationStatus(int pendingChangeId, boolean sent, boolean isReminder) {
        String sql = isReminder ? 
            "UPDATE PendingChanges SET ReminderSent = ?, ReminderCount = ReminderCount + 1 WHERE Id = ?" :
            "UPDATE PendingChanges SET NotificationSent = ? WHERE Id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setBoolean(1, sent);
            stmt.setInt(2, pendingChangeId);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Cleanup expired tokens
    public int cleanupExpiredTokens() {
        String sql = "EXEC sp_CleanupExpiredTokens";
        
        try (Connection conn = getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("ExpiredTokens");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    // Helper method to map ResultSet to PendingChange
    private PendingChange mapResultSetToPendingChange(ResultSet rs) throws SQLException {
        PendingChange change = new PendingChange();
        change.setId(rs.getInt("Id"));
        change.setUserId(rs.getInt("UserId"));
        change.setInitiatedBy(rs.getInt("InitiatedBy"));
        change.setChangeType(rs.getString("ChangeType"));
        change.setOriginalEmail(rs.getString("OriginalEmail"));
        change.setOriginalPhone(rs.getString("OriginalPhone"));
        change.setNewEmail(rs.getString("NewEmail"));
        change.setNewPhone(rs.getString("NewPhone"));
        change.setNewPasswordHash(rs.getString("NewPasswordHash"));
        change.setChangeReason(rs.getString("ChangeReason"));
        change.setVerificationToken(rs.getString("VerificationToken"));
        change.setTokenExpiry(rs.getTimestamp("TokenExpiry"));
        change.setStatus(rs.getString("Status"));
        change.setNotificationSent(rs.getBoolean("NotificationSent"));
        change.setReminderSent(rs.getBoolean("ReminderSent"));
        change.setReminderCount(rs.getInt("ReminderCount"));
        change.setApprovedAt(rs.getTimestamp("ApprovedAt"));
        change.setApprovedByEmail(rs.getBoolean("ApprovedByEmail"));
        change.setRejectedAt(rs.getTimestamp("RejectedAt"));
        change.setRejectionReason(rs.getString("RejectionReason"));
        change.setCreatedAt(rs.getTimestamp("CreatedAt"));
        change.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        
        // Display fields
        change.setUserName(rs.getString("UserName"));
        change.setUserRole(rs.getString("UserRole"));
        change.setInitiatedByName(rs.getString("InitiatedByName"));
        
        return change;
    }
}