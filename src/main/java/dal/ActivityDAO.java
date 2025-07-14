package dal;


import model.Activity;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityDAO {
    
    // Get recent activities
    public List<Activity> getRecentActivities(int limit) {
        List<Activity> activities = new ArrayList<>();
        String sql = "SELECT TOP (?) a.*, u.FullName as UserName " +
                    "FROM Activities a " +
                    "INNER JOIN Users u ON a.UserId = u.Id " +
                    "ORDER BY a.Timestamp DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Activity activity = new Activity();
                activity.setId(rs.getInt("Id"));
                activity.setType(rs.getString("Type"));
                
                int reservationId = rs.getInt("ReservationId");
                if (!rs.wasNull()) {
                    activity.setReservationId(reservationId);
                }
                
                activity.setUserId(rs.getInt("UserId"));
                activity.setDescription(rs.getString("Description"));
                
                double amount = rs.getDouble("Amount");
                if (!rs.wasNull()) {
                    activity.setAmount(amount);
                }
                
                activity.setTimestamp(rs.getTimestamp("Timestamp"));
                activity.setIpAddress(rs.getString("IpAddress"));
                activity.setUserName(rs.getString("UserName"));
                
                activities.add(activity);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activities;
    }
    
    // Log activity
    public boolean logActivity(Activity activity) {
        String sql = "INSERT INTO Activities (Type, ReservationId, UserId, " +
                    "Description, Amount, Timestamp, IpAddress) " +
                    "VALUES (?, ?, ?, ?, ?, GETDATE(), ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, activity.getType());
            
            if (activity.getReservationId() != null) {
                ps.setInt(2, activity.getReservationId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            
            ps.setInt(3, activity.getUserId());
            ps.setString(4, activity.getDescription());
            
            if (activity.getAmount() != null) {
                ps.setDouble(5, activity.getAmount());
            } else {
                ps.setNull(5, Types.DOUBLE);
            }
            
            ps.setString(6, activity.getIpAddress());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get activities by user
    public List<Activity> getActivitiesByUser(int userId, int limit) {
        List<Activity> activities = new ArrayList<>();
        String sql = "SELECT TOP (?) a.*, u.FullName as UserName " +
                    "FROM Activities a " +
                    "INNER JOIN Users u ON a.UserId = u.Id " +
                    "WHERE a.UserId = ? " +
                    "ORDER BY a.Timestamp DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Activity activity = new Activity();
                activity.setId(rs.getInt("Id"));
                activity.setType(rs.getString("Type"));
                
                int reservationId = rs.getInt("ReservationId");
                if (!rs.wasNull()) {
                    activity.setReservationId(reservationId);
                }
                
                activity.setUserId(rs.getInt("UserId"));
                activity.setDescription(rs.getString("Description"));
                
                double amount = rs.getDouble("Amount");
                if (!rs.wasNull()) {
                    activity.setAmount(amount);
                }
                
                activity.setTimestamp(rs.getTimestamp("Timestamp"));
                activity.setIpAddress(rs.getString("IpAddress"));
                activity.setUserName(rs.getString("UserName"));
                
                activities.add(activity);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activities;
    }
    
    // Get activities by reservation
    public List<Activity> getActivitiesByReservation(int reservationId) {
        List<Activity> activities = new ArrayList<>();
        String sql = "SELECT a.*, u.FullName as UserName " +
                    "FROM Activities a " +
                    "INNER JOIN Users u ON a.UserId = u.Id " +
                    "WHERE a.ReservationId = ? " +
                    "ORDER BY a.Timestamp DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reservationId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Activity activity = new Activity();
                activity.setId(rs.getInt("Id"));
                activity.setType(rs.getString("Type"));
                activity.setReservationId(rs.getInt("ReservationId"));
                activity.setUserId(rs.getInt("UserId"));
                activity.setDescription(rs.getString("Description"));
                
                double amount = rs.getDouble("Amount");
                if (!rs.wasNull()) {
                    activity.setAmount(amount);
                }
                
                activity.setTimestamp(rs.getTimestamp("Timestamp"));
                activity.setIpAddress(rs.getString("IpAddress"));
                activity.setUserName(rs.getString("UserName"));
                
                activities.add(activity);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activities;
    }
    
      
    public List<Activity> getActivitiesWithFilters(String dateFrom, String dateTo, 
            String type, String userId) {
        List<Activity> activities = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT a.*, u.FullName as UserName ");
        sql.append("FROM Activities a ");
        sql.append("INNER JOIN Users u ON a.UserId = u.Id ");
        sql.append("WHERE 1=1 ");
        
        List<Object> parameters = new ArrayList<>();
        
        if (dateFrom != null && !dateFrom.isEmpty()) {
            sql.append("AND a.Timestamp >= ? ");
            parameters.add(Date.valueOf(dateFrom));
        }
        
        if (dateTo != null && !dateTo.isEmpty()) {
            sql.append("AND a.Timestamp <= ? ");
            parameters.add(Date.valueOf(dateTo) + " 23:59:59");
        }
        
        if (type != null && !type.isEmpty()) {
            sql.append("AND a.Type = ? ");
            parameters.add(type);
        }
        
        if (userId != null && !userId.isEmpty()) {
            sql.append("AND a.UserId = ? ");
            parameters.add(Integer.parseInt(userId));
        }
        
        sql.append("ORDER BY a.Timestamp DESC");
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                activities.add(mapResultSetToActivity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activities;
    }
    
    public Map<String, Integer> getActivityStatsByType() {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT Type, COUNT(*) as Count FROM Activities " +
                    "WHERE Timestamp >= DATEADD(day, -7, GETDATE()) " +
                    "GROUP BY Type";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                stats.put(rs.getString("Type"), rs.getInt("Count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
    
    private Activity mapResultSetToActivity(ResultSet rs) throws SQLException {
        Activity activity = new Activity();
        activity.setId(rs.getInt("Id"));
        activity.setType(rs.getString("Type"));
        activity.setReservationId(rs.getObject("ReservationId") != null ? 
            rs.getInt("ReservationId") : null);
        activity.setUserId(rs.getInt("UserId"));
        activity.setDescription(rs.getString("Description"));
        activity.setAmount(rs.getObject("Amount") != null ? 
            rs.getDouble("Amount") : null);
        activity.setTimestamp(rs.getTimestamp("Timestamp"));
        activity.setIpAddress(rs.getString("IpAddress"));
        activity.setUserName(rs.getString("UserName"));
        return activity;
    }
   
    
    // Get activities by date range
    public List<Activity> getActivitiesByDateRange(Date startDate, Date endDate) {
        List<Activity> activities = new ArrayList<>();
        String sql = "SELECT a.*, u.FullName as UserName, " +
                    "r.Id as ReservationId, rm.RoomNumber " +
                    "FROM Activities a " +
                    "INNER JOIN Users u ON a.UserId = u.Id " +
                    "LEFT JOIN Reservations r ON a.ReservationId = r.Id " +
                    "LEFT JOIN Rooms rm ON r.RoomId = rm.Id " +
                    "WHERE a.Timestamp BETWEEN ? AND ? " +
                    "ORDER BY a.Timestamp DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setDate(1, startDate);
            ps.setDate(2, endDate);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                activities.add(mapResultSetToActivity(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return activities;
    }
    
    // Get activity count by type
    public int getActivityCountByType(String type, Date date) {
        String sql = "SELECT COUNT(*) FROM Activities " +
                    "WHERE Type = ? AND CAST(Timestamp AS DATE) = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, type);
            ps.setDate(2, date);
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