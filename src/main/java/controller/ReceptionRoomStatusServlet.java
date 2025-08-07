/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.RoomDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;
import model.Room;
import model.User;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "ReceptionRoomStatusServlet", urlPatterns = {"/receptionist/room-status"})
public class ReceptionRoomStatusServlet extends HttpServlet {

    private RoomDAO roomDAO = new RoomDAO();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ReceptionRoomStatusServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ReceptionRoomStatusServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //processRequest(request, response);

        // Check receptionist authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        // Get selected floor from request, default to 1
        int selectedFloor = 1;
        String floorParam = request.getParameter("floor");
        if (floorParam != null && floorParam.matches("\\d+")) {
            selectedFloor = Integer.parseInt(floorParam);
        }

        // Get status filter if any
        String statusFilter = request.getParameter("status");
        if (statusFilter != null && statusFilter.trim().isEmpty()) {
            statusFilter = null;
        }

        RoomDAO roomDAO = new RoomDAO();

        try {
            // Get all distinct floor numbers (from RoomNumber prefix)
            List<Integer> allFloors = roomDAO.getAllFloors();

            // Get rooms for the selected floor with optional status
            List<Room> rooms = roomDAO.getRoomsByFloor(selectedFloor, statusFilter);

            // Set attributes for JSP
            request.setAttribute("floors", allFloors);
            request.setAttribute("selectedFloor", selectedFloor);
            request.setAttribute("status", statusFilter);
            request.setAttribute("rooms", rooms);
            request.setAttribute("pageTitle", "Room Status");
            request.setAttribute("activePage", "roomstatus");
            request.setAttribute("contentPage", "room-status-board.jsp");

        } catch (Exception e) {
            e.printStackTrace();
//            request.setAttribute("error", "Unable to load room status board. Please try again.");
            request.setAttribute("error", "Unable to load room status board. Please try again. " + e.getMessage());
        }

        request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        //processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
