/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.RoomInspectionDAO;
import model.Reservation;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 *
 * @author dmx
 */
@WebServlet(name="PendingInspectionsServlet", urlPatterns={"/inspector/pending-inspections"})
public class PendingInspectionsServlet extends HttpServlet {
   
     private RoomInspectionDAO inspectionDAO = new RoomInspectionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Chỉ cho phép ROOM_INSPECTOR truy cập
        if (user == null || !"ROOM_INSPECTOR".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        try {
            // Lấy danh sách pending inspections
            List<Reservation> pendingInspections = inspectionDAO.getPendingInspections();
            request.setAttribute("pendingInspections", pendingInspections);
            request.setAttribute("currentUser", user);
            request.setAttribute("pageTitle", "Pending Inspections");
            request.setAttribute("activePage", "pending-inspections");
            request.setAttribute("contentPage", "/jsp/inspector/pending-inspections.jsp");
            request.getRequestDispatcher("/jsp/inspector/inspector-template.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading pending inspections: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
