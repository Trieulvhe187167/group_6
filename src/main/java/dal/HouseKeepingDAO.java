package dal;


import model.HousekeepingTask;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HouseKeepingDAO {
//lay thong tin task
    public List<HousekeepingTask> getAllTasks() {
        List<HousekeepingTask> tasks = new ArrayList<>();

        String sql = "SELECT r.RoomNumber, h.Status, h.Notes, u.Username AS AssignedTo, h.CreatedAt, h.UpdatedAt " +
                     "FROM HousekeepingTasks h " +
                     "JOIN Rooms r ON h.RoomId = r.Id " +
                     "LEFT JOIN Users u ON h.AssignedTo = u.Id " +
                     "ORDER BY h.CreatedAt DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

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
    
    // ✅ Hàm main để test
    public static void main(String[] args) {
        HouseKeepingDAO dao = new HouseKeepingDAO();
        List<HousekeepingTask> tasks = dao.getAllTasks();

        for (HousekeepingTask task : tasks) {
            System.out.println("Room: " + task.getRoomNum());
            System.out.println("Status: " + task.getStatus());
            System.out.println("Assigned To: " + task.getAssignedcToID());
            System.out.println("Notes: " + task.getNotes());
            System.out.println("Created At: " + task.getCreatedAt());
            System.out.println("Updated At: " + task.getUpdatedAt());
            System.out.println("-------------------------------");
        }
    }
    
}
