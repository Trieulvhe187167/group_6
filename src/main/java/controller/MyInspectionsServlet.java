/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.RoomInspectionDAO;
import model.RoomInspection;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name="MyInspectionsServlet", urlPatterns={"/inspector/my-inspections"})
public class MyInspectionsServlet extends HttpServlet {
   
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
            // Lấy danh sách tất cả inspections của inspector này
            List<RoomInspection> myInspections = inspectionDAO.getInspectorInspections(user.getId(), null);
            request.setAttribute("myInspections", myInspections);
            request.setAttribute("currentUser", user);
            request.setAttribute("pageTitle", "My Inspections");
            request.setAttribute("activePage", "myInspections");
            request.setAttribute("contentPage", "/jsp/inspector/my-inspections.jsp");
            request.getRequestDispatcher("/jsp/inspector/inspector-template.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading your inspections: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
