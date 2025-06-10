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

@WebServlet(name = "HousekeeperTaskDetailServlet", urlPatterns = {"/housekeeper/task-detail"})
public class HousekeeperTaskDetailServlet extends HttpServlet {
    
    private HousekeepingTaskDAO taskDAO = new HousekeepingTaskDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"HOUSEKEEPER".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/housekeeper/tasks");
            return;
        }
        
        try {
            int taskId = Integer.parseInt(idStr);
            HousekeepingTask task = taskDAO.getTaskById(taskId);
            
            if (task == null || task.getAssignedTo() != currentUser.getId()) {
                session.setAttribute("error", "Task not found or access denied");
                response.sendRedirect(request.getContextPath() + "/jsp/housekeeper/tasks");
                return;
            }
            
            request.setAttribute("task", task);
            request.getRequestDispatcher("/jsp/housekeeper/task-detail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/jsp/housekeeper/tasks");
        }
    }
}