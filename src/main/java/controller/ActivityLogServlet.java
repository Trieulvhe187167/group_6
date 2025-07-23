package controller;


import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import java.sql.Date;

@WebServlet(name = "ActivityLogServlet", urlPatterns = {"/receptionist/activity-log"})
public class ActivityLogServlet extends HttpServlet {
    
    private final ActivityDAO activityDAO = new ActivityDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        try {
            // Get filter parameters
            String dateFrom = request.getParameter("dateFrom");
            if (dateFrom == null) {
                dateFrom = request.getParameter("fromDate");
            }
            String dateTo = request.getParameter("dateTo");
            if (dateTo == null) {
                dateTo = request.getParameter("toDate");
            }
            String type = request.getParameter("type");
            if (type == null) {
                type = request.getParameter("activityType");
            }
            String userId = request.getParameter("userId");
            
            // Get activities with filters
            List<Activity> activities;
            if (dateFrom != null || dateTo != null || type != null || userId != null) {
                activities = activityDAO.getActivitiesWithFilters(dateFrom, dateTo, type, userId);
            } else {
                activities = activityDAO.getRecentActivities(100);
            }
            
            // Get activity type statistics
            Map<String, Integer> activityStats = activityDAO.getActivityStatsByType();
            
            // Set attributes
            request.setAttribute("activities", activities);
            request.setAttribute("activityStats", activityStats);
            request.setAttribute("currentUser", currentUser);
            
            // Set template attributes
            request.setAttribute("pageTitle", "Activity Log");
            request.setAttribute("activePage", "activitylog");
            request.setAttribute("contentPage", "/jsp/reception/activity-log-content.jsp");
            
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading activity log: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
       if ("exportActivities".equals(action) || "export".equals(action)) {
            exportActivities(request, response);
        } else if ("getLatestCount".equals(action)) {
            int count = activityDAO.getTotalActivityCount();
            response.setContentType("text/plain");
            response.getWriter().write(String.valueOf(count));
        } else if ("report".equals(action)) {
            exportActivities(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
    
    private void exportActivities(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
       try {
               // Get filter parameters
            String dateFrom = request.getParameter("dateFrom");
            if (dateFrom == null) {
                dateFrom = request.getParameter("fromDate");
            }
            String dateTo = request.getParameter("dateTo");
            if (dateTo == null) {
                dateTo = request.getParameter("toDate");
            }
            String type = request.getParameter("type");
            if (type == null) {
                type = request.getParameter("activityType");
            }
            String userId = request.getParameter("userId");
            
            List<Activity> activities = activityDAO.getActivitiesWithFilters(dateFrom, dateTo, type, userId);
            
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=\"activity_log.csv\"");
            
            StringBuilder csv = new StringBuilder();
            csv.append("Date,Time,User,Type,Description,Amount,IP Address\n");
            
            for (Activity activity : activities) {
                csv.append(activity.getTimestamp()).append(",");
                csv.append(activity.getUserName()).append(",");
                csv.append(activity.getTypeDisplayName()).append(",");
                csv.append("\"").append(activity.getDescription()).append("\",");
                csv.append(activity.getAmount() != null ? activity.getAmount() : "").append(",");
                csv.append(activity.getIpAddress()).append("\n");
            }
            
            response.getWriter().write(csv.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}