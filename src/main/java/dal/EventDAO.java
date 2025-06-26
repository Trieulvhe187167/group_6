package dal;

import model.Event;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {
    
    /**
     * Get all events with filters
     */
    public List<Event> getAllEventsWithFilters(String search, String status, String location, String dateRange) {
        List<Event> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT Id, Title, Description, Location, StartAt, EndAt, Status, ImageUrl, CreatedBy, CreatedAt, UpdatedAt FROM dbo.Events WHERE 1=1");
        
        // Build dynamic query based on filters
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (Title LIKE ? OR Description LIKE ?)");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND Status = ?");
        }
        if (location != null && !location.trim().isEmpty()) {
            sql.append(" AND Location = ?");
        }
        if (dateRange != null && !dateRange.trim().isEmpty()) {
            switch(dateRange) {
                case "today":
                    sql.append(" AND CAST(StartAt AS DATE) = CAST(GETDATE() AS DATE)");
                    break;
                case "thisWeek":
                    sql.append(" AND StartAt >= DATEADD(wk, DATEDIFF(wk, 0, GETDATE()), 0) AND StartAt < DATEADD(wk, DATEDIFF(wk, 0, GETDATE()) + 1, 0)");
                    break;
                case "thisMonth":
                    sql.append(" AND MONTH(StartAt) = MONTH(GETDATE()) AND YEAR(StartAt) = YEAR(GETDATE())");
                    break;
                case "upcoming":
                    sql.append(" AND StartAt > GETDATE()");
                    break;
                case "past":
                    sql.append(" AND EndAt < GETDATE()");
                    break;
            }
        }
        
        sql.append(" ORDER BY StartAt DESC");
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + search + "%");
                ps.setString(paramIndex++, "%" + search + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }
            if (location != null && !location.trim().isEmpty()) {
                ps.setString(paramIndex++, location);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
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
                    e.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
                    e.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    e.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    list.add(e);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return list;
    }
    
    /**
     * Get all events
     */
    public List<Event> getAllEvents() {
        return getAllEventsWithFilters(null, null, null, null);
    }
    
    /**
     * Get Event by Id
     */
    public Event getEventById(int id) {
        String sql = "SELECT Id, Title, Description, Location, StartAt, EndAt, Status, ImageUrl, CreatedBy, CreatedAt, UpdatedAt FROM dbo.Events WHERE Id = ?";
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
                    e.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
                    e.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    e.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    return e;
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }
    
    /**
     * Insert new event
     */
    public boolean insertEvent(Event event) {
        String sql = "INSERT INTO dbo.Events (Title, Description, Location, StartAt, EndAt, Status, ImageUrl, CreatedBy) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, event.getTitle());
            ps.setString(2, event.getDescription());
            ps.setString(3, event.getLocation());
            ps.setTimestamp(4, event.getStartAt());
            ps.setTimestamp(5, event.getEndAt());
            ps.setString(6, event.getStatus());
            ps.setString(7, event.getImageUrl());
            if (event.getCreatedBy() != null) {
                ps.setInt(8, event.getCreatedBy());
            } else {
                ps.setNull(8, Types.INTEGER);
            }
            
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update event
     */
    public boolean updateEvent(Event event) {
        String sql = "UPDATE dbo.Events SET Title = ?, Description = ?, Location = ?, StartAt = ?, EndAt = ?, Status = ?, ImageUrl = ? WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, event.getTitle());
            ps.setString(2, event.getDescription());
            ps.setString(3, event.getLocation());
            ps.setTimestamp(4, event.getStartAt());
            ps.setTimestamp(5, event.getEndAt());
            ps.setString(6, event.getStatus());
            ps.setString(7, event.getImageUrl());
            ps.setInt(8, event.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete event
     */
    public boolean deleteEvent(int id) {
        String sql = "DELETE FROM dbo.Events WHERE Id = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return false;
    }
    
    /**
     * Get total events count
     */
    public int getTotalEvents() {
        String sql = "SELECT COUNT(*) FROM dbo.Events";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Get upcoming events count
     */
    public int getUpcomingEventsCount() {
        String sql = "SELECT COUNT(*) FROM dbo.Events WHERE Status = 'SCHEDULED' AND StartAt > GETDATE()";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Get ongoing events count
     */
    public int getOngoingEventsCount() {
        String sql = "SELECT COUNT(*) FROM dbo.Events WHERE Status = 'ONGOING' OR (StartAt <= GETDATE() AND EndAt >= GETDATE() AND Status = 'SCHEDULED')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Get completed events count
     */
    public int getCompletedEventsCount() {
        String sql = "SELECT COUNT(*) FROM dbo.Events WHERE Status = 'COMPLETED'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Get unique locations
     */
    public List<String> getUniqueLocations() {
        List<String> locations = new ArrayList<>();
        String sql = "SELECT DISTINCT Location FROM dbo.Events WHERE Location IS NOT NULL ORDER BY Location";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                locations.add(rs.getString("Location"));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return locations;
    }
    
    /**
     * Get latest event by user
     */
    public Event getLatestEventByUser(int userId) {
        String sql = "SELECT TOP 1 Id, Title, Description, Location, StartAt, EndAt, Status, ImageUrl, CreatedBy, CreatedAt, UpdatedAt FROM dbo.Events WHERE CreatedBy = ? ORDER BY CreatedAt DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setInt(1, userId);
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
                    e.setCreatedBy(rs.getObject("CreatedBy") != null ? rs.getInt("CreatedBy") : null);
                    e.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    e.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
                    return e;
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }
    
    /**
     * Auto-update event statuses based on current time
     * This method should be called periodically (e.g., when listing events)
     */
    public void autoUpdateEventStatuses() {
        String sql = "UPDATE dbo.Events SET Status = CASE " +
                     "WHEN Status = 'SCHEDULED' AND StartAt <= GETDATE() AND EndAt >= GETDATE() THEN 'ONGOING' " +
                     "WHEN Status IN ('SCHEDULED', 'ONGOING') AND EndAt < GETDATE() THEN 'COMPLETED' " +
                     "ELSE Status END " +
                     "WHERE Status IN ('SCHEDULED', 'ONGOING')";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.executeUpdate();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
}