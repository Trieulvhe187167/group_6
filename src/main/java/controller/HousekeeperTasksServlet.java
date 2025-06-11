package controller;


import dal.HousekeepingTaskDAO;
import model.HousekeepingTask;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HousekeeperTasksServlet", urlPatterns = {"/housekeeper/tasks"})
public class HousekeeperTasksServlet extends HttpServlet {
    
    private HousekeepingTaskDAO taskDAO = new HousekeepingTaskDAO();
    private static final int RECORDS_PER_PAGE = 10;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"HOUSEKEEPER".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String status = request.getParameter("status");
        String search = request.getParameter("search");
        int page = 1;
        
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        List<HousekeepingTask> allTasks;
        
        if (status != null && !status.equals("ALL")) {
            allTasks = taskDAO.getTasksByUserAndStatus(currentUser.getId(), status);
        } else {
            allTasks = taskDAO.getTasksByUser(currentUser.getId());
        }
        
        // Calculate pagination
        int totalRecords = allTasks.size();
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;
        
        int start = (page - 1) * RECORDS_PER_PAGE;
        int end = Math.min(start + RECORDS_PER_PAGE, totalRecords);
        
        List<HousekeepingTask> tasks = allTasks.subList(start, end);
        
        // Set attributes
        request.setAttribute("tasks", tasks);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("status", status);
        request.setAttribute("search", search);
        
        request.getRequestDispatcher("/jsp/housekeeper/tasks.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"HOUSEKEEPER".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("updateStatus".equals(action)) {
            String taskIdStr = request.getParameter("taskId");
            String newStatus = request.getParameter("status");
            
            try {
                int taskId = Integer.parseInt(taskIdStr);
                
                // Verify task belongs to this housekeeper
                HousekeepingTask task = taskDAO.getTaskById(taskId);
                if (task != null && task.getAssignedTo() == currentUser.getId()) {
                    if (taskDAO.updateTaskStatus(taskId, newStatus)) {
                        session.setAttribute("success", "Task status updated successfully");
                    } else {
                        session.setAttribute("error", "Failed to update task status");
                    }
                } else {
                    session.setAttribute("error", "You can only update your own tasks");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "Invalid task ID");
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/housekeeper/tasks");
    }
}