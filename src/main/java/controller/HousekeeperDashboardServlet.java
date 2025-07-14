package controller;

import dal.HousekeepingTaskDAO;
import dal.RoomDAO;
import model.HousekeepingTask;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Calendar;

@WebServlet(name = "HousekeeperDashboardServlet", urlPatterns = {"/housekeeper-dashboard"})
public class HousekeeperDashboardServlet extends HttpServlet {
    
    private HousekeepingTaskDAO taskDAO = new HousekeepingTaskDAO();
    private RoomDAO roomDAO = new RoomDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Check if user is logged in and is a housekeeper
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        if (!"HOUSEKEEPER".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        // Get tasks assigned to this housekeeper
        List<HousekeepingTask> myTasks = taskDAO.getTasksByUser(currentUser.getId());
        
        // Calculate statistics
        Map<String, Integer> stats = new HashMap<>();
        int pendingCount = 0;
        int inProgressCount = 0;
        int completedCount = 0;
        int todayCompletedCount = 0;
        
        java.util.Date today = new java.util.Date();
        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
        String todayStr = dateFormat.format(today);
        
        for (HousekeepingTask task : myTasks) {
            switch (task.getStatus()) {
                case "PENDING":
                    pendingCount++;
                    break;
                case "IN_PROGRESS":
                    inProgressCount++;
                    break;
                case "DONE":
                    completedCount++;
                    // Check if completed today
                    if (task.getUpdatedAt() != null) {
                        String taskDateStr = dateFormat.format(task.getUpdatedAt());
                        if (todayStr.equals(taskDateStr)) {
                            todayCompletedCount++;
                        }
                    }
                    break;
            }
        }
        
        stats.put("pendingCount", pendingCount);
        stats.put("inProgressCount", inProgressCount);
        stats.put("completedCount", completedCount);
        stats.put("todayCompletedCount", todayCompletedCount);
        stats.put("totalTasks", myTasks.size());
        
        // Get recent tasks (last 5)
        List<HousekeepingTask> recentTasks = myTasks.size() > 5 ? 
            myTasks.subList(0, 5) : myTasks;
        
        // Set greeting based on time
        Calendar cal = Calendar.getInstance();
        int hour = cal.get(Calendar.HOUR_OF_DAY);
        String greeting;
        if (hour < 12) {
            greeting = "morning";
        } else if (hour < 18) {
            greeting = "afternoon";
        } else {
            greeting = "evening";
        }
        
        // Set attributes
        request.setAttribute("stats", stats);
        request.setAttribute("recentTasks", recentTasks);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("greeting", greeting);
        
        // Set page info for template
        request.setAttribute("pageTitle", "Dashboard");
        request.setAttribute("activePage", "dashboard");
        request.setAttribute("contentPage", "/jsp/housekeeper/housekeeper-dashboard-content.jsp");
        
        // Forward to template
        request.getRequestDispatcher("/jsp/housekeeper/housekeeper-template.jsp").forward(request, response);
    }
}