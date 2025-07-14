/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.*;
import model.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/inspector/dashboard")
public class RoomInspectorDashboardServlet extends HttpServlet {
    private RoomInspectionDAO inspectionDAO = new RoomInspectionDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Check if user is room inspector
        if (user == null || !"ROOM_INSPECTOR".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        try {
            // Get pending inspections
            List<Reservation> pendingInspections = inspectionDAO.getPendingInspections();
            
            // Get inspector's recent inspections
            List<RoomInspection> myInspections = inspectionDAO.getInspectorInspections(user.getId(), null);
            
            // Get statistics
            Map<String, Object> stats = calculateStats(myInspections);
            
            // Set attributes
            request.setAttribute("pendingInspections", pendingInspections);
            request.setAttribute("myInspections", myInspections);
            request.setAttribute("stats", stats);
            request.setAttribute("currentUser", user);
            request.setAttribute("today", new java.sql.Date(System.currentTimeMillis()));
            
            // Set template attributes
            request.setAttribute("pageTitle", "Room Inspector Dashboard");
            request.setAttribute("activePage", "dashboard");
            request.setAttribute("contentPage", "/jsp/inspector/dashboard-content.jsp");
            
            // Forward to template
            request.getRequestDispatcher("/jsp/inspector/inspector-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading dashboard: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    private Map<String, Object> calculateStats(List<RoomInspection> inspections) {
        Map<String, Object> stats = new HashMap<>();
        
        int totalInspections = inspections.size();
        int pendingCount = 0;
        int completedToday = 0;
        double totalRevenue = 0;
        
        Calendar today = Calendar.getInstance();
        today.set(Calendar.HOUR_OF_DAY, 0);
        today.set(Calendar.MINUTE, 0);
        today.set(Calendar.SECOND, 0);
        
        for (RoomInspection inspection : inspections) {
            if ("PENDING".equals(inspection.getStatus())) {
                pendingCount++;
            }
            
            if (inspection.getInspectionTime().after(today.getTime())) {
                completedToday++;
            }
            
            if (inspection.getTotalCharges() != null) {
                totalRevenue += inspection.getTotalCharges().doubleValue();
            }
        }
        
        stats.put("totalInspections", totalInspections);
        stats.put("pendingInspections", pendingCount);
        stats.put("completedToday", completedToday);
        stats.put("totalRevenue", totalRevenue);
        
        return stats;
    }
}