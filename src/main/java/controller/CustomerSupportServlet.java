/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.*;
import model.*;
import java.util.*;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.sql.SQLException;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "CustomerSupportServlet", urlPatterns = {"/customer/support"})
public class CustomerSupportServlet extends HttpServlet {

    private CustomerSupportDAO supportDAO = new CustomerSupportDAO();

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
            out.println("<title>Servlet CustomerSupportServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CustomerSupportServlet at " + request.getContextPath() + "</h1>");
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
        User user = (User) session.getAttribute("user");

        if (user == null || !"CUSTOMER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("new".equals(action)) {
                showSupportForm(request, response, user);
            } else {
                showCustomerRequestList(request, response, user);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
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
        //processRequest(request, response);

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"CUSTOMER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("create".equals(action)) {
                createSupportRequest(request, response, user);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    private void showSupportForm(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException, SQLException {

        List<Room> rooms = supportDAO.getOccupiedRooms(user.getId());
        request.setAttribute("occupiedRooms", rooms);
        request.setAttribute("pageTitle", "Request Support");
        request.getRequestDispatcher("/jsp/customer/support-form.jsp").forward(request, response);
    }

    private void showCustomerRequestList(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException, SQLException {

        // Lấy filter & sort từ request
        String filter = request.getParameter("filter");
        String sort = request.getParameter("sort");

        // Gán giá trị mặc định nếu null
        if (filter == null || filter.trim().isEmpty()) {
            filter = "all";
        }
        if (sort == null || sort.trim().isEmpty()) {
            sort = "date";
        }

        List<SupportRequest> requests = supportDAO.getSupportRequestsByUser(user.getId(), filter, sort);

        request.setAttribute("requestList", requests);
        request.setAttribute("selectedFilter", filter); // để giữ trạng thái filter trong form
        request.setAttribute("selectedSort", sort);     // để giữ trạng thái sort trong form
        request.setAttribute("pageTitle", "My Support Requests");

        request.getRequestDispatcher("/jsp/customer/support-list.jsp").forward(request, response);
    }

    private void createSupportRequest(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException, SQLException {

        String roomIdRaw = request.getParameter("roomId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");

        String error = null;
        int roomId = -1;

        try {
            // Validate roomId
            roomId = Integer.parseInt(roomIdRaw);
            if (roomId <= 0) {
                error = "Invalid room selected.";
            }

            // Validate title and description
            if (title == null || title.trim().isEmpty()) {
                error = "Title cannot be empty.";
            } else if (title.length() > 100) {
                error = "Title is too long.";
            }

            if (description == null || description.trim().isEmpty()) {
                error = "Description cannot be empty.";
            } else if (description.length() > 1000) {
                error = "Description is too long.";
            }

            // Nếu có lỗi → gọi lại showSupportForm
            if (error != null) {
                request.setAttribute("error", error);
                request.setAttribute("inputTitle", title);
                request.setAttribute("inputDescription", description);
                request.setAttribute("selectedRoomId", roomId);
                showSupportForm(request, response, user);  // Gọi lại đúng hàm
                return;
            }

            // Không có lỗi → Thêm request mới
            SupportRequest sr = new SupportRequest(user.getId(), roomId, title, description);
            supportDAO.insertSupportRequest(sr);
            response.sendRedirect(request.getContextPath() + "/customer/support");

        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid room selection.");
            request.setAttribute("inputTitle", title);
            request.setAttribute("inputDescription", description);
            request.setAttribute("selectedRoomId", roomId);
            showSupportForm(request, response, user); // Gọi lại hàm
        }
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
