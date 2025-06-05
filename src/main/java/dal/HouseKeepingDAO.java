package dal;


import model.HousekeepingTask;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HouseKeepingDAO {
//lay thong tin task
    public List<HousekeepingTask> getAllTasks() {
        List<HousekeepingTask> tasks = new ArrayList<>();

        String sql = "SELECT ht.Id, r.RoomNumber, ht.Status, ht.Notes, " +
                     "       u.Username AS AssignedTo, ht.CreatedAt, ht.UpdatedAt " +
                     "FROM HousekeepingTasks ht " +
                     "JOIN Rooms r ON ht.RoomId = r.Id " +
                     "LEFT JOIN Users u ON ht.AssignedTo = u.Id " +
                     "ORDER BY ht.CreatedAt DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                HousekeepingTask task = new HousekeepingTask();
                task.setId(rs.getInt("Id"));
                task.setRoomNum(rs.getString("RoomNumber"));
                task.setStatus(rs.getString("Status"));
                task.setNotes(rs.getString("Notes"));
                task.setAssignedcToID(rs.getString("AssignedTo")); // Username, not ID
                task.setCreatedAt(rs.getTimestamp("CreatedAt"));
                task.setUpdatedAt(rs.getTimestamp("UpdatedAt"));

                tasks.add(task);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return tasks;
    }

    
    //tim task theo trang thai
public List<HousekeepingTask> searchTasksByStatus(String status) {
    List<HousekeepingTask> tasks = new ArrayList<>();

    String sql = "SELECT r.RoomNumber, h.Status, h.Notes, u.Username AS AssignedTo, h.CreatedAt, h.UpdatedAt " +
                 "FROM HousekeepingTasks h " +
                 "JOIN Rooms r ON h.RoomId = r.Id " +
                 "LEFT JOIN Users u ON h.AssignedTo = u.Id " +
                 "WHERE LOWER(h.Status) LIKE ? " +  // Chuyển về lowercase để so sánh
                 "ORDER BY h.CreatedAt DESC";

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, "%" + status.toLowerCase() + "%");  // Cũng chuyển về lowercase

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            HousekeepingTask task = new HousekeepingTask();
            task.setRoomNum(rs.getString("RoomNumber"));
            task.setStatus(rs.getString("Status"));
            task.setNotes(rs.getString("Notes"));
            task.setAssignedcToID(rs.getString("AssignedTo"));
            task.setCreatedAt(rs.getTimestamp("CreatedAt"));
            task.setUpdatedAt(rs.getTimestamp("UpdatedAt"));

            tasks.add(task);
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }

    return tasks;
}

    
   //Hàm sửa trạng thái theo id Task
    public boolean updateTaskStatusById(int taskId, String newStatus) {
    String sql = "UPDATE HousekeepingTasks SET Status = ?, UpdatedAt = GETDATE() WHERE Id = ?";

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, newStatus);
        ps.setInt(2, taskId);

        int rowsAffected = ps.executeUpdate();
        return rowsAffected > 0; // Trả về true nếu có ít nhất 1 dòng được cập nhật

    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}   
    //ham xoa task theo id
    public boolean deleteTaskById(int taskId) {
    String sql = "DELETE FROM HousekeepingTasks WHERE Id = ?";

    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setInt(1, taskId);
        int rowsAffected = ps.executeUpdate();

        return rowsAffected > 0; // true nếu có ít nhất 1 dòng bị xóa
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return false;
}


public static void main(String[] args) {
    HouseKeepingDAO dao = new HouseKeepingDAO();

    int taskIdToUpdate = 22; // ID task cần sửa
    String newStatus = "DONE";

    boolean success = dao.updateTaskStatusById(taskIdToUpdate, newStatus);

    if (success) {
        System.out.println("Status cập nhật thành công!");
    } else {
        System.out.println("Cập nhật thất bại. Kiểm tra ID hoặc lỗi kết nối.");
    }
}



}
