/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.RoomAmenityDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.RoomAmenityDTO;
import model.User;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "AdminRoomAmenityServlet", urlPatterns = {"/admin/amenities"})
public class AdminRoomAmenityServlet extends HttpServlet {

    private RoomAmenityDAO amenityDAO = new RoomAmenityDAO();

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
            out.println("<title>Servlet AdminRoomAmenityServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminRoomAmenityServlet at " + request.getContextPath() + "</h1>");
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

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Phân quyền admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "list";
        }

        try {
            switch (action) {
                case "list":
                    listAmenities(request, response);
                    break;
                // các case khác như create, edit, detail sẽ thêm sau
                default:
                    listAmenities(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            listAmenities(request, response);
        }
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
        processRequest(request, response);
    }

    private void listAmenities(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<RoomAmenityDTO> amenities = amenityDAO.getAllWithRoomNumber();

        String success = request.getParameter("success");
        if (success != null && !success.isEmpty()) {
            request.setAttribute("success", success);
        }

        // Gán dữ liệu về template
        request.setAttribute("amenities", amenities);
        request.setAttribute("pageTitle", "Room Amenity Management");
        request.setAttribute("activePage", "room-amenity");
        request.setAttribute("contentPage", "/jsp/admin/room-amenity-list.jsp");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
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
