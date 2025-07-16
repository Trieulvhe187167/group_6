/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.RoomDAO;
import dal.RoomTypeDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import model.Room;
import model.RoomType;
import model.User;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "AdminRoom2Servlet", urlPatterns = {"/admin/rooms2"})
public class AdminRoom2Servlet extends HttpServlet {

    private static final int RECORDS_PER_PAGE = 3;

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
            out.println("<title>Servlet AdminRoom2Servlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminRoom2Servlet at " + request.getContextPath() + "</h1>");
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
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "list":
                    listRooms(request, response);
                    break;
                case "form":
                    showRoomForm(request, response);
                    break;
                case "view":
                    viewRoom(request, response);
                    break;
                case "update":
                    showUpdateForm(request, response);
                    break;
                default:
                    listRooms(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            listRooms(request, response);
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
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        RoomDAO dao = new RoomDAO();
        String action = request.getParameter("action");
        if (action != null) {
            switch (action) {
                case "create":
                    createRoom(request, response, dao);
                    break;
                case "update":
                    updateRoom(request, response, dao);
                    break;
                case "delete":
                    deleteRoom(request, response, dao);
                    break;
                default:
                    response.sendRedirect("rooms2");
            }
        } else {
            response.sendRedirect("rooms2");
        }
    }

    private void listRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        RoomDAO roomDAO = new RoomDAO();
        RoomTypeDAO roomTypeDAO = new RoomTypeDAO();

        List<Room> rooms = new ArrayList<>();

        // Lấy tham số và chuẩn hóa
        String keyword = request.getParameter("keyword");
        String roomTypeIdStr = request.getParameter("roomTypeId");
        String capacityStr = request.getParameter("capacity");
        String status = request.getParameter("status");

        keyword = (keyword != null) ? keyword.trim() : null;
        roomTypeIdStr = (roomTypeIdStr != null) ? roomTypeIdStr.trim() : "";
        capacityStr = (capacityStr != null) ? capacityStr.trim() : "";
        status = (status != null) ? status.trim() : null;

        if ("all".equalsIgnoreCase(status) || "".equals(status)) {
            status = null;
        }

        Integer roomTypeId = (!roomTypeIdStr.isEmpty()) ? Integer.parseInt(roomTypeIdStr) : -1;
        Integer capacity = (!capacityStr.isEmpty()) ? Integer.parseInt(capacityStr) : -1;

        // Phân trang
        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr.trim());
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        // Tìm + lọc
        rooms = roomDAO.searchAndFilterRooms(
                (keyword != null && !keyword.isEmpty()) ? keyword : null,
                roomTypeId,
                capacity,
                status
        );

        // Phân trang thủ công
        int totalRecords = rooms.size();
        int totalPages = (int) Math.ceil(totalRecords * 1.0 / RECORDS_PER_PAGE);
        int startIndex = (page - 1) * RECORDS_PER_PAGE;
        int endIndex = Math.min(startIndex + RECORDS_PER_PAGE, totalRecords);

        List<Room> paginatedRooms = rooms.subList(startIndex, endIndex);

        String success = request.getParameter("success");
        if (success != null && !success.isEmpty()) {
            request.setAttribute("success", success);
        }

        // Set về JSP
        request.setAttribute("rooms", paginatedRooms);
        request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());

        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedRoomTypeId", roomTypeId);
        request.setAttribute("selectedCapacity", capacity);
        request.setAttribute("selectedStatus", status);

        request.setAttribute("currentPage", page);
        request.setAttribute("recordsPerPage", RECORDS_PER_PAGE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);

        request.setAttribute("pageTitle", "Room Management");
        request.setAttribute("activePage", "room-manage");
        request.setAttribute("contentPage", "/jsp/admin/room2-list.jsp");
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void showRoomForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        Room room = null;
        boolean isEdit = false;

        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                RoomDAO dao = new RoomDAO();
                room = dao.getRoomById(id);
                isEdit = true;
            } catch (NumberFormatException e) {
                // Có thể log nếu cần
            }
        }

        RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
        List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();

        request.setAttribute("room", room); // null nếu tạo mới
        request.setAttribute("roomTypes", roomTypes);
        request.setAttribute("isEdit", isEdit);
        request.setAttribute("pageTitle", isEdit ? "Edit Room" : "Create Room");
        request.setAttribute("activePage", "room-manage");
        request.setAttribute("contentPage", "/jsp/admin/room2-form.jsp");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void viewRoom(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("rooms2");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            RoomDAO roomDAO = new RoomDAO();
            Room room = roomDAO.getRoomById(id);
            if (room == null) {
                request.setAttribute("error", "Room not found");
                listRooms(request, response);
                return;
            }

            request.setAttribute("room", room);
            request.setAttribute("pageTitle", "Room Details");
            request.setAttribute("activePage", "room-manage");
            request.setAttribute("contentPage", "/jsp/admin/room2-detail.jsp");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("rooms2");
        }
    }

    private void showUpdateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("rooms2");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            RoomDAO dao = new RoomDAO();
            Room room = dao.getRoomById(id);
            if (room == null) {
                request.setAttribute("error", "Room not found");
                listRooms(request, response);
                return;
            }

            RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
            List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();

            request.setAttribute("room", room);
            request.setAttribute("roomTypes", roomTypes);
            request.setAttribute("isEdit", true);
            request.setAttribute("pageTitle", "Edit Room");
            request.setAttribute("activePage", "room-manage");
            request.setAttribute("contentPage", "/jsp/admin/room2-form.jsp");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect("rooms2");
        }
    }

    private void createRoom(HttpServletRequest request, HttpServletResponse response, RoomDAO dao)
            throws ServletException, IOException {

        String roomNumber = request.getParameter("roomNumber").trim();
        int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
        String status = request.getParameter("status");

        Room room = new Room();
        room.setRoomNumber(roomNumber);
        room.setRoomTypeId(roomTypeId);
        room.setStatus(status);

        if (dao.isRoomNumberExists(roomNumber, null)) {
            forwardToRoomForm(request, response, room, false, "Room number already exists.");
            return;
        }

        dao.createRoom(room);
        response.sendRedirect("rooms2?success=Room created successfully");
    }

    private void updateRoom(HttpServletRequest request, HttpServletResponse response, RoomDAO dao)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        String roomNumber = request.getParameter("roomNumber").trim();
        int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
        String status = request.getParameter("status");

        Room room = new Room();
        room.setId(id);
        room.setRoomNumber(roomNumber);
        room.setRoomTypeId(roomTypeId);
        room.setStatus(status);

        if (dao.isRoomNumberExists(roomNumber, id)) {
            forwardToRoomForm(request, response, room, true, "Room number already exists.");
            return;
        }

        dao.updateRoom(room);
        response.sendRedirect("rooms2?success=Room updated successfully");
    }

    private void deleteRoom(HttpServletRequest request, HttpServletResponse response, RoomDAO dao)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");

            dao.updateRoomStatus(id, status);
            request.getSession().setAttribute("success", "Room status updated successfully");
        } catch (Exception e) {
            request.getSession().setAttribute("error", "Error updating room type status: " + e.getMessage());
        }
        response.sendRedirect("rooms2");
    }

    private void forwardToRoomForm(HttpServletRequest request, HttpServletResponse response,
            Room room, boolean isEdit, String errorMessage)
            throws ServletException, IOException {
        RoomTypeDAO roomTypeDAO = new RoomTypeDAO(); // phải có DAO riêng nếu RoomDAO không có getRoomTypes()

        request.setAttribute("error", errorMessage);
        request.setAttribute("room", room);
        request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes()); // dùng để đổ vào <select>
        request.setAttribute("isEdit", isEdit);
        request.setAttribute("pageTitle", isEdit ? "Edit Room" : "Create Room");
        request.setAttribute("activePage", "room-manage");
        request.setAttribute("contentPage", "/jsp/admin/room2-form.jsp");

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
