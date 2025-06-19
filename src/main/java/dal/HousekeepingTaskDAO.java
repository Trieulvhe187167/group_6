package dal;

import model.HousekeepingTask;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HousekeepingTaskDAO {
    
    // Get all tasks with room and user details
    public List<HousekeepingTask> getAllTasks() {
        List<HousekeepingTask> tasks = new ArrayList<>();
        String sql = "SELECT ht.*, r.RoomNumber, rt.Name as RoomTypeName, " +
                    "r.Status as RoomStatus, u.FullName as AssignedToName " +
                    "FROM HousekeepingTasks ht " +
                    "INNER JOIN Rooms r ON ht.RoomId = r.Id " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users u ON ht.AssignedTo = u.Id " +
                    "ORDER BY " +
                    "CASE ht.Status " +
                    "  WHEN 'PENDING' THEN 1 " +
                    "  WHEN 'IN_PROGRESS' THEN 2 " +
                    "  WHEN 'DONE' THEN 3 " +
                    "END, ht.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                tasks.add(mapResultSetToTask(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    // Get tasks by status
    public List<HousekeepingTask> getTasksByStatus(String status) {
        List<HousekeepingTask> tasks = new ArrayList<>();
        String sql = "SELECT ht.*, r.RoomNumber, rt.Name as RoomTypeName, " +
                    "r.Status as RoomStatus, u.FullName as AssignedToName " +
                    "FROM HousekeepingTasks ht " +
                    "INNER JOIN Rooms r ON ht.RoomId = r.Id " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users u ON ht.AssignedTo = u.Id " +
                    "WHERE ht.Status = ? " +
                    "ORDER BY ht.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                tasks.add(mapResultSetToTask(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    // Get tasks assigned to a specific user
    public List<HousekeepingTask> getTasksByUser(int userId) {
        List<HousekeepingTask> tasks = new ArrayList<>();
        String sql = "SELECT ht.*, r.RoomNumber, rt.Name as RoomTypeName, " +
                    "r.Status as RoomStatus, u.FullName as AssignedToName " +
                    "FROM HousekeepingTasks ht " +
                    "INNER JOIN Rooms r ON ht.RoomId = r.Id " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users u ON ht.AssignedTo = u.Id " +
                    "WHERE ht.AssignedTo = ? " +
                    "ORDER BY " +
                    "CASE ht.Status " +
                    "  WHEN 'PENDING' THEN 1 " +
                    "  WHEN 'IN_PROGRESS' THEN 2 " +
                    "  WHEN 'DONE' THEN 3 " +
                    "END, ht.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                tasks.add(mapResultSetToTask(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    // Get tasks by room
    public List<HousekeepingTask> getTasksByRoom(int roomId) {
        List<HousekeepingTask> tasks = new ArrayList<>();
        String sql = "SELECT ht.*, r.RoomNumber, rt.Name as RoomTypeName, " +
                    "r.Status as RoomStatus, u.FullName as AssignedToName " +
                    "FROM HousekeepingTasks ht " +
                    "INNER JOIN Rooms r ON ht.RoomId = r.Id " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users u ON ht.AssignedTo = u.Id " +
                    "WHERE ht.RoomId = ? " +
                    "ORDER BY ht.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, roomId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                tasks.add(mapResultSetToTask(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    // Search tasks
    public List<HousekeepingTask> searchTasks(String keyword, String status) {
        List<HousekeepingTask> tasks = new ArrayList<>();
        String sql = "SELECT ht.*, r.RoomNumber, rt.Name as RoomTypeName, " +
                    "r.Status as RoomStatus, u.FullName as AssignedToName " +
                    "FROM HousekeepingTasks ht " +
                    "INNER JOIN Rooms r ON ht.RoomId = r.Id " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users u ON ht.AssignedTo = u.Id " +
                    "WHERE (r.RoomNumber LIKE ? OR ht.Notes LIKE ? OR u.FullName LIKE ?) ";
        
        if (status != null && !status.equals("ALL")) {
            sql += "AND ht.Status = ? ";
        }
        
        sql += "ORDER BY " +
               "CASE ht.Status " +
               "  WHEN 'PENDING' THEN 1 " +
               "  WHEN 'IN_PROGRESS' THEN 2 " +
               "  WHEN 'DONE' THEN 3 " +
               "END, ht.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            
            if (status != null && !status.equals("ALL")) {
                ps.setString(4, status);
            }
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                tasks.add(mapResultSetToTask(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    // Get task by ID
    public HousekeepingTask getTaskById(int id) {
        String sql = "SELECT ht.*, r.RoomNumber, rt.Name as RoomTypeName, " +
                    "r.Status as RoomStatus, u.FullName as AssignedToName " +
                    "FROM HousekeepingTasks ht " +
                    "INNER JOIN Rooms r ON ht.RoomId = r.Id " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users u ON ht.AssignedTo = u.Id " +
                    "WHERE ht.Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToTask(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Create new task
    public boolean createTask(HousekeepingTask task) {
        String sql = "INSERT INTO HousekeepingTasks (RoomId, AssignedTo, Status, Notes) " +
                    "VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, task.getRoomId());
            if (task.getAssignedTo() > 0) {
                ps.setInt(2, task.getAssignedTo());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, task.getStatus());
            ps.setString(4, task.getNotes());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update task
    public boolean updateTask(HousekeepingTask task) {
        String sql = "UPDATE HousekeepingTasks SET RoomId = ?, AssignedTo = ?, " +
                    "Status = ?, Notes = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, task.getRoomId());
            if (task.getAssignedTo() > 0) {
                ps.setInt(2, task.getAssignedTo());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, task.getStatus());
            ps.setString(4, task.getNotes());
            ps.setInt(5, task.getId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Update task status
    public boolean updateTaskStatus(int taskId, String status) {
        String sql = "UPDATE HousekeepingTasks SET Status = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, taskId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Assign task to user
    public boolean assignTask(int taskId, int userId) {
        String sql = "UPDATE HousekeepingTasks SET AssignedTo = ? WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            if (userId > 0) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setInt(2, taskId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Delete task
    public boolean deleteTask(int taskId) {
        String sql = "DELETE FROM HousekeepingTasks WHERE Id = ?";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, taskId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Get task statistics
    public int[] getTaskStatistics() {
        int[] stats = new int[3]; // [pending, inProgress, done]
        String sql = "SELECT Status, COUNT(*) as Count FROM HousekeepingTasks " +
                    "GROUP BY Status";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String status = rs.getString("Status");
                int count = rs.getInt("Count");
                
                switch (status) {
                    case "PENDING":
                        stats[0] = count;
                        break;
                    case "IN_PROGRESS":
                        stats[1] = count;
                        break;
                    case "DONE":
                        stats[2] = count;
                        break;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return stats;
    }
    
    // Get tasks by status for a specific user
    public List<HousekeepingTask> getTasksByUserAndStatus(int userId, String status) {
        List<HousekeepingTask> tasks = new ArrayList<>();
        String sql = "SELECT ht.*, r.RoomNumber, rt.Name as RoomTypeName, " +
                    "r.Status as RoomStatus, u.FullName as AssignedToName " +
                    "FROM HousekeepingTasks ht " +
                    "INNER JOIN Rooms r ON ht.RoomId = r.Id " +
                    "INNER JOIN RoomTypes rt ON r.RoomTypeId = rt.Id " +
                    "LEFT JOIN Users u ON ht.AssignedTo = u.Id " +
                    "WHERE ht.AssignedTo = ? AND ht.Status = ? " +
                    "ORDER BY ht.CreatedAt DESC";
        
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                tasks.add(mapResultSetToTask(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tasks;
    }
    
    // Helper method to map ResultSet to HousekeepingTask
    private HousekeepingTask mapResultSetToTask(ResultSet rs) throws SQLException {
        HousekeepingTask task = new HousekeepingTask();
        task.setId(rs.getInt("Id"));
        task.setRoomId(rs.getInt("RoomId"));
        
        int assignedTo = rs.getInt("AssignedTo");
        if (!rs.wasNull()) {
            task.setAssignedTo(assignedTo);
        }
        
        task.setStatus(rs.getString("Status"));
        task.setNotes(rs.getString("Notes"));
        task.setCreatedAt(rs.getTimestamp("CreatedAt"));
        task.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        
        // Additional fields
        task.setRoomNumber(rs.getString("RoomNumber"));
        task.setRoomTypeName(rs.getString("RoomTypeName"));
        task.setRoomStatus(rs.getString("RoomStatus"));
        
        String assignedToName = rs.getString("AssignedToName");
        task.setAssignedToName(assignedToName != null ? assignedToName : "Unassigned");
        
        return task;
    }
}