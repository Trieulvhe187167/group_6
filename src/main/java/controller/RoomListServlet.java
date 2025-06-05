/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.RoomTypeDAO;
import model.RoomType;
import java.util.List;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.util.Date;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "RoomListServlet", urlPatterns = {"/RoomListServlet"})
public class RoomListServlet extends HttpServlet {

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
            out.println("<title>Servlet RoomListServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet RoomListServlet at " + request.getContextPath() + "</h1>");
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

        RoomTypeDAO dao = new RoomTypeDAO();
        List<RoomType> roomTypes;
        String keyword = request.getParameter("keyword");
        String action = request.getParameter("action");
        String price = request.getParameter("price");
        String capacity = request.getParameter("capacity");
        String status = request.getParameter("status");

        if (keyword != null && !keyword.trim().isEmpty()) {
            roomTypes = dao.searchRooms(keyword.trim());
            request.setAttribute("keyword", keyword);
        } else if ((price != null && !price.isEmpty())
                || (capacity != null && !capacity.isEmpty())
                || (status != null && !status.isEmpty())) {
            roomTypes = dao.filterRoomTypes(price, capacity, status);
            request.setAttribute("selectedPrice", price);
            request.setAttribute("selectedCapacity", capacity);
            request.setAttribute("selectedStatus", status);
        } else {
            roomTypes = dao.getAllRoomTypes();
        }

        //Phân trang
        int recordsPerPage = 6;

        String pageStr = request.getParameter("page");
        int currentPage = 1;
        if (pageStr != null) {
            currentPage = Integer.parseInt(pageStr);
        }

        int totalRecords = roomTypes.size();
        int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
        //Phân trang
        //Phân trang
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("recordsPerPage", recordsPerPage);
        request.setAttribute("totalPages", totalPages);
        //Phân trang

        request.setAttribute("roomTypes", roomTypes);
        request.getRequestDispatcher("jsp/admin-roomList.jsp").forward(request, response);
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
        RoomTypeDAO dao = new RoomTypeDAO();
        String action = request.getParameter("action");

        if (action != null && action.equals("create")) {
            // Xử lý tạo mới RoomType
            request.setCharacterEncoding("UTF-8");

            String name = request.getParameter("name");
            String basePriceStr = request.getParameter("basePrice");
            String capacityStr = request.getParameter("capacity");
            String bed = request.getParameter("bed");
            String description = request.getParameter("description");
            String special = request.getParameter("special");
            String imageUrl = request.getParameter("imageUrl");

            try {
                BigDecimal basePrice = new BigDecimal(basePriceStr);
                int capacity = Integer.parseInt(capacityStr);

                RoomType roomType = new RoomType();
                roomType.setName(name);
                roomType.setDescription(description + "," + bed + "," + special);
                roomType.setImageUrl(imageUrl);
                roomType.setBasePrice(basePrice);
                roomType.setCapacity(capacity);
                roomType.setCreatedAt(new Date());
                roomType.setUpdatedAt(new Date());

                dao.insert(roomType);

                response.sendRedirect("RoomListServlet");
            } catch (Exception e) {
                request.setAttribute("message", "Lỗi tạo RoomType: " + e.getMessage());
                request.getRequestDispatcher("/jsp/create-roomtype.jsp").forward(request, response);
            }
        } else if (action != null && action.equalsIgnoreCase("delete")) {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");

            dao.updateRoomTypeStatus(id, status);
            response.sendRedirect("RoomListServlet");

        } else if (action != null && action.equalsIgnoreCase("filter")) {
            String price = request.getParameter("price");
            String capacity = request.getParameter("capacity");
            String status = request.getParameter("status");

            List<RoomType> roomTypes = dao.filterRoomTypes(price, capacity, status);

            request.setAttribute("roomTypes", roomTypes);
            request.getRequestDispatcher("jsp/admin-roomList.jsp").forward(request, response);
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
