package controller;

import dal.HousekeepingTaskDAO;
import dal.RoomDAO;
import dal.UserDAO;
import model.HousekeepingTask;
import model.Room;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "HousekeepingServlet", urlPatterns = {"/HouseKeeping"})
public class HouseKeepingServlet extends HttpServlet {
    
    private HousekeepingTaskDAO taskDAO = new HousekeepingTaskDAO();
    private RoomDAO roomDAO = new RoomDAO();
    private UserDAO userDAO = new UserDAO();
    private static final int RECORDS_PER_PAGE = 10;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        // Check if user has permission (ADMIN, RECEPTIONIST, or HOUSEKEEPER)
        String role = currentUser.getRole();
        if (!"ADMIN".equals(role) && !"RECEPTIONIST".equals(role) && !"HOUSEKEEPER".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    listTasks(request, response, currentUser);
                    break;
                case "form":
                    showTaskForm(request, response);
                    break;
                case "detail":
                    showTaskDetail(request, response, currentUser);
                    break;
                case "assign":
                    showAssignForm(request, response);
                    break;
                default:
                    listTasks(request, response, currentUser);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            listTasks(request, response, currentUser);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "";
        
        try {
            switch (action) {
                case "create":
                    createTask(request, response);
                    break;
                case "update":
                    updateTask(request, response);
                    break;
                case "updateStatus":
                    updateTaskStatus(request, response);
                    break;
                case "assign":
                    assignTask(request, response);
                    break;
                case "delete":
                    deleteTask(request, response);
                    break;
                default:
                    response.sendRedirect("HouseKeeping");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            listTasks(request, response, currentUser);
        }
    }
    
    private void listTasks(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        int page = 1;
        
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        if (search == null) search = "";
        if (status == null) status = "ALL";
        
        List<HousekeepingTask> allTasks;
        
        // If user is HOUSEKEEPER, show only their tasks
        if ("HOUSEKEEPER".equals(currentUser.getRole())) {
            if (!"ALL".equals(status)) {
                allTasks = taskDAO.getTasksByUserAndStatus(currentUser.getId(), status);
            } else {
                allTasks = taskDAO.getTasksByUser(currentUser.getId());
            }
        } else {
            // ADMIN or RECEPTIONIST can see all tasks
            if (!search.isEmpty()) {
                allTasks = taskDAO.searchTasks(search, status);
            } else if (!"ALL".equals(status)) {
                allTasks = taskDAO.getTasksByStatus(status);
            } else {
                allTasks = taskDAO.getAllTasks();
            }
        }
        
        // Calculate pagination
        int totalRecords = allTasks.size();
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        // Ensure page is within valid range
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;
        
        int start = (page - 1) * RECORDS_PER_PAGE;
        int end = Math.min(start + RECORDS_PER_PAGE, totalRecords);
        
        // Get tasks for current page
        List<HousekeepingTask> tasks = new ArrayList<>();
        if (start < totalRecords) {
            tasks = allTasks.subList(start, end);
        }
        
        // Get task statistics
        int[] stats = taskDAO.getTaskStatistics();
        
        // Get housekeepers for assignment
        List<User> housekeepers = userDAO.getUsersByRole("HOUSEKEEPER");
        
        request.setAttribute("tasks", tasks);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("pendingCount", stats[0]);
        request.setAttribute("inProgressCount", stats[1]);
        request.setAttribute("completedCount", stats[2]);
        request.setAttribute("housekeepers", housekeepers);
        request.setAttribute("currentUser", currentUser);
        
        // Set page info
        request.setAttribute("pageTitle", "Housekeeping Tasks");
        request.setAttribute("activePage", "housekeeping");
        request.setAttribute("contentPage", "/jsp/admin/housekeeping-tasks.jsp");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showTaskForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        HousekeepingTask task = null;
        boolean isEdit = false;
        
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                task = taskDAO.getTaskById(id);
                isEdit = true;
            } catch (NumberFormatException e) {
                // Invalid ID
            }
        }
        
        // Get available rooms and housekeepers
        List<Room> rooms = roomDAO.getAllRooms();
        List<User> housekeepers = userDAO.getUsersByRole("HOUSEKEEPER");
        
        request.setAttribute("task", task);
        request.setAttribute("isEdit", isEdit);
        request.setAttribute("rooms", rooms);
        request.setAttribute("housekeepers", housekeepers);
        request.setAttribute("pageTitle", isEdit ? "Edit Task" : "Create Task");
        request.setAttribute("activePage", "housekeeping");
        request.setAttribute("contentPage", "/jsp/admin/housekeeping-form.jsp");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showTaskDetail(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            request.getSession().setAttribute("error", "Task ID is required");
            response.sendRedirect("HouseKeeping");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            HousekeepingTask task = taskDAO.getTaskById(id);
            
            if (task == null) {
                request.getSession().setAttribute("error", "Task not found with ID: " + id);
                response.sendRedirect("HouseKeeping");
                return;
            }
            
            // Check if housekeeper can only view their own tasks
            if ("HOUSEKEEPER".equals(currentUser.getRole()) && task.getAssignedTo() != currentUser.getId()) {
                request.getSession().setAttribute("error", "You can only view tasks assigned to you");
                response.sendRedirect("HouseKeeping");
                return;
            }
            
            // Get housekeepers for potential assignment
            List<User> housekeepers = userDAO.getUsersByRole("HOUSEKEEPER");
            request.setAttribute("housekeepers", housekeepers);
            
            // Debug information
            System.out.println("Task Details:");
            System.out.println("ID: " + task.getId());
            System.out.println("Room ID: " + task.getRoomId());
            System.out.println("Room Number: " + task.getRoomNumber());
            System.out.println("Status: " + task.getStatus());
            System.out.println("Assigned To: " + task.getAssignedTo());
            System.out.println("Created At: " + task.getCreatedAt());
            System.out.println("Updated At: " + task.getUpdatedAt());
            
            request.setAttribute("task", task);
            request.setAttribute("pageTitle", "Task Details - Room " + task.getRoomNumber());
            request.setAttribute("activePage", "housekeeping");
            
            // Thử các đường dẫn khác nhau
            String[] possiblePaths = {
                "/jsp/admin/housekeeping-detail.jsp",
                "/jsp/housekeeping-detail.jsp", 
                "/housekeeping-detail.jsp",
                "/WEB-INF/jsp/admin/housekeeping-detail.jsp"
            };
            
            String detailPagePath = null;
            for (String path : possiblePaths) {
                if (getServletContext().getResource(path) != null) {
                    detailPagePath = path;
                    break;
                }
            }
            
            if (detailPagePath != null) {
                request.setAttribute("contentPage", detailPagePath);
                request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            } else {
                // Fallback: redirect to list with error
                request.getSession().setAttribute("error", "Task detail page not found. Please check file location.");
                response.sendRedirect("HouseKeeping");
            }
            
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid task ID: " + idStr);
            response.sendRedirect("HouseKeeping");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Error loading task details: " + e.getMessage());
            response.sendRedirect("HouseKeeping");
        }
    }
    
    private void createTask(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String roomIdStr = request.getParameter("roomId");
        String assignedToStr = request.getParameter("assignedTo");
        String status = request.getParameter("status");
        String notes = request.getParameter("notes");
        
        // Validate required fields
        if (roomIdStr == null || roomIdStr.trim().isEmpty()) {
            request.setAttribute("error", "Room is required");
            showTaskForm(request, response);
            return;
        }
        
        if (status == null || status.trim().isEmpty()) {
            request.setAttribute("error", "Status is required");
            showTaskForm(request, response);
            return;
        }
        
        try {
            int roomId = Integer.parseInt(roomIdStr);
            int assignedTo = 0;
            if (assignedToStr != null && !assignedToStr.trim().isEmpty()) {
                assignedTo = Integer.parseInt(assignedToStr);
            }
            
            HousekeepingTask task = new HousekeepingTask(roomId, assignedTo, status, notes);
            
            if (taskDAO.createTask(task)) {
                request.getSession().setAttribute("success", "Task created successfully");
                response.sendRedirect("HouseKeeping");
            } else {
                request.setAttribute("error", "Failed to create task");
                showTaskForm(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid room or user ID");
            showTaskForm(request, response);
        }
    }
    
    private void updateTask(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        String roomIdStr = request.getParameter("roomId");
        String assignedToStr = request.getParameter("assignedTo");
        String status = request.getParameter("status");
        String notes = request.getParameter("notes");
        
        if (idStr == null) {
            request.getSession().setAttribute("error", "Task ID is required");
            response.sendRedirect("HouseKeeping");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            int roomId = Integer.parseInt(roomIdStr);
            int assignedTo = 0;
            if (assignedToStr != null && !assignedToStr.trim().isEmpty()) {
                assignedTo = Integer.parseInt(assignedToStr);
            }
            
            HousekeepingTask task = new HousekeepingTask(roomId, assignedTo, status, notes);
            task.setId(id);
            
            if (taskDAO.updateTask(task)) {
                request.getSession().setAttribute("success", "Task updated successfully");
                response.sendRedirect("HouseKeeping?action=detail&id=" + id);
            } else {
                request.setAttribute("error", "Failed to update task");
                showTaskForm(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid input format");
            showTaskForm(request, response);
        }
    }
    
    private void updateTaskStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("taskId");
        String status = request.getParameter("status");
        
        if (idStr == null || status == null) {
            request.getSession().setAttribute("error", "Task ID and status are required");
            response.sendRedirect("HouseKeeping");
            return;
        }
        
        try {
            int taskId = Integer.parseInt(idStr);
            
            if (taskDAO.updateTaskStatus(taskId, status)) {
                request.getSession().setAttribute("success", "Task status updated successfully");
                // Redirect back to detail page if coming from detail
                String referer = request.getHeader("referer");
                if (referer != null && referer.contains("action=detail")) {
                    response.sendRedirect("HouseKeeping?action=detail&id=" + taskId);
                } else {
                    response.sendRedirect("HouseKeeping");
                }
            } else {
                request.getSession().setAttribute("error", "Failed to update task status");
                response.sendRedirect("HouseKeeping");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid task ID");
            response.sendRedirect("HouseKeeping");
        }
    }
    
    // Temporary method to create inline detail page
    private void createInlineDetailPage(HttpServletRequest request, HttpServletResponse response, HousekeepingTask task)
            throws ServletException, IOException {
        
        // Set simple detail content in request
        StringBuilder detailContent = new StringBuilder();
        detailContent.append("<div class='container-fluid'>");
        detailContent.append("<h1>Task Details</h1>");
        detailContent.append("<div class='card'>");
        detailContent.append("<div class='card-body'>");
        detailContent.append("<p><strong>Task ID:</strong> #").append(task.getId()).append("</p>");
        detailContent.append("<p><strong>Room:</strong> ").append(task.getRoomNumber()).append("</p>");
        detailContent.append("<p><strong>Status:</strong> ").append(task.getStatus()).append("</p>");
        detailContent.append("<p><strong>Notes:</strong> ").append(task.getNotes() != null ? task.getNotes() : "No notes").append("</p>");
        detailContent.append("<a href='HouseKeeping' class='btn btn-secondary'>Back to List</a>");
        detailContent.append("</div></div></div>");
        
        request.setAttribute("inlineContent", detailContent.toString());
        request.setAttribute("contentPage", "/jsp/admin/inline-content.jsp");
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void assignTask(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String taskIdStr = request.getParameter("taskId");
        String userIdStr = request.getParameter("userId");
        
        if (taskIdStr == null) {
            request.getSession().setAttribute("error", "Task ID is required");
            response.sendRedirect("HouseKeeping");
            return;
        }
        
        try {
            int taskId = Integer.parseInt(taskIdStr);
            int userId = 0;
            if (userIdStr != null && !userIdStr.trim().isEmpty()) {
                userId = Integer.parseInt(userIdStr);
            }
            
            if (taskDAO.assignTask(taskId, userId)) {
                request.getSession().setAttribute("success", "Task assigned successfully");
                // Redirect back to detail page if possible
                response.sendRedirect("HouseKeeping?action=detail&id=" + taskId);
            } else {
                request.getSession().setAttribute("error", "Failed to assign task");
                response.sendRedirect("HouseKeeping");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid task or user ID");
            response.sendRedirect("HouseKeeping");
        }
    }
    
    private void deleteTask(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        
        if (idStr == null) {
            request.getSession().setAttribute("error", "Task ID is required");
            response.sendRedirect("HouseKeeping");
            return;
        }
        
        try {
            int taskId = Integer.parseInt(idStr);
            
            if (taskDAO.deleteTask(taskId)) {
                request.getSession().setAttribute("success", "Task deleted successfully");
            } else {
                request.getSession().setAttribute("error", "Failed to delete task");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid task ID");
        }
        
        response.sendRedirect("HouseKeeping");
    }
    
    private void showAssignForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("HouseKeeping");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            HousekeepingTask task = taskDAO.getTaskById(id);
            
            if (task == null) {
                request.getSession().setAttribute("error", "Task not found");
                response.sendRedirect("HouseKeeping");
                return;
            }
            
            List<User> housekeepers = userDAO.getUsersByRole("HOUSEKEEPER");
            
            request.setAttribute("task", task);
            request.setAttribute("housekeepers", housekeepers);
            request.setAttribute("pageTitle", "Assign Task");
            request.setAttribute("activePage", "housekeeping");
            request.setAttribute("contentPage", "/jsp/admin/housekeeping-assign.jsp");
            
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid task ID");
            response.sendRedirect("HouseKeeping");
        }
    }
}
