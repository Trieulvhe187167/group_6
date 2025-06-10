/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.RoomTypeDAO;
import dal.RoomDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import model.RoomType;
import model.Room;
import model.User;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "AdminRoomServlet", urlPatterns = {"/admin/rooms"})
public class AdminRoomServlet extends HttpServlet {

    private static final int RECORDS_PER_PAGE = 6;

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
            out.println("<title>Servlet AdminRoomServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminRoomServlet at " + request.getContextPath() + "</h1>");
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
        
        // Check admin authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    listRoomTypes(request, response);
                    break;
                case "form":
                    showRoomTypeForm(request, response);
                    break;
                case "view":
                    viewRoomType(request, response);
                    break;
                case "update":
                    showUpdateForm(request, response);
                    break;
                default:
                    listRoomTypes(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            listRoomTypes(request, response);
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
        
        // Check admin authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        RoomTypeDAO dao = new RoomTypeDAO();
        String action = request.getParameter("action");

        if (action != null && action.equals("create")) {
            createRoomType(request, response, dao);
        } else if (action != null && action.equalsIgnoreCase("delete")) {
            deleteRoomType(request, response, dao);
        } else if (action != null && action.equalsIgnoreCase("update")) {
            updateRoomType(request, response, dao);
        } else {
            response.sendRedirect("rooms");
        }
    }
    
    private void listRoomTypes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        RoomTypeDAO dao = new RoomTypeDAO();
        List<RoomType> roomTypes;
        String keyword = request.getParameter("keyword");
        String price = request.getParameter("price");
        String capacity = request.getParameter("capacity");
        String status = request.getParameter("status");
        
        // Get page parameter
        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        // Apply filters
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

        // Calculate pagination
        int totalRecords = roomTypes.size();
        int totalPages = (int) Math.ceil(totalRecords * 1.0 / RECORDS_PER_PAGE);

        // Set pagination attributes
        request.setAttribute("currentPage", page);
        request.setAttribute("recordsPerPage", RECORDS_PER_PAGE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        
        // Set room types
        request.setAttribute("roomTypes", roomTypes);
        
        // Set page info for template
        request.setAttribute("pageTitle", "Room Types Management");
        request.setAttribute("activePage", "rooms");
        request.setAttribute("contentPage", "/jsp/admin/room-list.jsp");
        
        // Forward to template
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showRoomTypeForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        RoomType roomType = null;
        boolean isEdit = false;
        
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                RoomTypeDAO dao = new RoomTypeDAO();
                roomType = dao.getRoomTypesById(id);
                isEdit = true;
            } catch (NumberFormatException e) {
                // Invalid ID
            }
        }
        
        request.setAttribute("roomType", roomType);
        request.setAttribute("isEdit", isEdit);
        request.setAttribute("pageTitle", isEdit ? "Edit Room Type" : "Create Room Type");
        request.setAttribute("activePage", "rooms");
        request.setAttribute("contentPage", "/jsp/admin/room-form.jsp");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void viewRoomType(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("rooms");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
            RoomDAO roomDAO = new RoomDAO();
            
            RoomType roomType = roomTypeDAO.getRoomTypesById(id);
            if (roomType == null) {
                request.setAttribute("error", "Room type not found");
                listRoomTypes(request, response);
                return;
            }
            
            // Get rooms for this room type
            List<Room> rooms = roomDAO.getRoomsByType(id);
            
            // Calculate room statistics for this room type
            int availableCount = 0, occupiedCount = 0, maintenanceCount = 0, dirtyCount = 0;
            for (Room room : rooms) {
                switch (room.getStatus()) {
                    case "AVAILABLE": availableCount++; break;
                    case "OCCUPIED": occupiedCount++; break;
                    case "MAINTENANCE": maintenanceCount++; break;
                    case "DIRTY": dirtyCount++; break;
                }
            }
            
            request.setAttribute("roomType", roomType);
            request.setAttribute("rooms", rooms);
            request.setAttribute("totalRooms", rooms.size());
            request.setAttribute("availableRooms", availableCount);
            request.setAttribute("occupiedRooms", occupiedCount);
            request.setAttribute("maintenanceRooms", maintenanceCount);
            request.setAttribute("dirtyRooms", dirtyCount);
            
            request.setAttribute("pageTitle", "Room Type Details");
            request.setAttribute("activePage", "rooms");
            request.setAttribute("contentPage", "/jsp/admin/room-detail.jsp");
            
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("rooms");
        }
    }
    
    private void showUpdateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("rooms");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            RoomTypeDAO dao = new RoomTypeDAO();
            RoomType roomType = dao.getRoomTypesById(id);
            
            if (roomType == null) {
                request.setAttribute("error", "Room type not found");
                listRoomTypes(request, response);
                return;
            }
            
            request.setAttribute("roomType", roomType);
            request.setAttribute("isEdit", true);
            request.setAttribute("pageTitle", "Edit Room Type");
            request.setAttribute("activePage", "rooms");
            request.setAttribute("contentPage", "/jsp/admin/room-form.jsp");
            
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("rooms");
        }
    }
    
    private void createRoomType(HttpServletRequest request, HttpServletResponse response, RoomTypeDAO dao)
            throws ServletException, IOException {
        
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

            request.getSession().setAttribute("success", "Room type created successfully");
            response.sendRedirect("rooms");
        } catch (Exception e) {
            request.setAttribute("error", "Error creating room type: " + e.getMessage());
            showRoomTypeForm(request, response);
        }
    }
    
    private void deleteRoomType(HttpServletRequest request, HttpServletResponse response, RoomTypeDAO dao)
            throws ServletException, IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");

            dao.updateRoomTypeStatus(id, status);
            request.getSession().setAttribute("success", "Room type status updated successfully");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error updating room type status: " + e.getMessage());
        }
        
        response.sendRedirect("rooms");
    }
    
    private void updateRoomType(HttpServletRequest request, HttpServletResponse response, RoomTypeDAO dao)
            throws ServletException, IOException {
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            BigDecimal basePrice = new BigDecimal(request.getParameter("basePrice"));
            String imageUrl = request.getParameter("imageUrl");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            String status = request.getParameter("status");

            RoomType roomType = new RoomType();
            roomType.setId(id);
            roomType.setName(name);
            roomType.setDescription(description);
            roomType.setBasePrice(basePrice);
            roomType.setImageUrl(imageUrl);
            roomType.setCapacity(capacity);
            roomType.setStatus(status);
            roomType.setUpdatedAt(new java.util.Date());

            dao.updateRoomType(roomType);

            request.getSession().setAttribute("success", "Room type updated successfully");
            response.sendRedirect("rooms");
        } catch (Exception e) {
            request.setAttribute("error", "Error updating room type: " + e.getMessage());
            showRoomTypeForm(request, response);
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