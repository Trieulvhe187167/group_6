/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.RoomAmenityDAO;
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
import java.net.URLEncoder;
import java.util.Date;
import java.util.List;
import model.Room;
import model.RoomAmenityDTO;
import model.User;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "AdminRoomAmenityServlet", urlPatterns = {"/admin/amenities"})
public class AdminRoomAmenityServlet extends HttpServlet {

    private RoomAmenityDAO amenityDAO = new RoomAmenityDAO();
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
                case "detail":
                    viewAmenityDetail(request, response);
                    break;
                case "add":
                    showAmenityForm(request, response, null);
                    break;
                case "edit":
                    int id = Integer.parseInt(request.getParameter("id"));
                    RoomAmenityDTO amenity = amenityDAO.getRoomAmenityById(id);
                    showAmenityForm(request, response, amenity);
                    break;
                case "delete":
                    int idToDelete = Integer.parseInt(request.getParameter("id"));
                    boolean deleted = amenityDAO.deleteRoomAmenity(idToDelete);
                    if (deleted) {
                        request.setAttribute("success", "Amenity deleted successfully.");
                    } else {
                        request.setAttribute("error", "Failed to delete amenity.");
                    }
                    response.sendRedirect(request.getContextPath() + "/admin/amenities?action=list");
                    break;

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
        request.setCharacterEncoding("UTF-8");

        String formAction = request.getParameter("action");

        try {
            // Get form values
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String name = request.getParameter("name").trim();
            String description = request.getParameter("description").trim();
            boolean isChargeable = Boolean.parseBoolean(request.getParameter("isChargeable"));
            BigDecimal unitPrice = new BigDecimal(request.getParameter("unitPrice"));

            // Check for duplicates based on action
            boolean isDuplicate;
            if ("edit".equals(formAction)) {
                int id = Integer.parseInt(request.getParameter("id"));
                isDuplicate = amenityDAO.checkAmenityDuplicateExceptId(roomId, name, description, id);
            } else {
                isDuplicate = amenityDAO.checkAmenityDuplicate(roomId, name, description);
            }

            // If duplicate found, forward back to form with error
            if (isDuplicate) {
                String errorMessage = "Amenity already exists.";

                // Lưu lỗi vào request để có thể hiển thị lại
                request.setAttribute("error", errorMessage);

                HttpSession session = request.getSession();
                session.setAttribute("roomId", roomId);
                session.setAttribute("name", name);
                session.setAttribute("description", description);
                session.setAttribute("unitPrice", unitPrice);
                session.setAttribute("isChargeable", isChargeable);

                // Re-fetch room list for drop-down
                List<Room> roomList = amenityDAO.getAllRooms();
                request.setAttribute("roomList", roomList);

                // Populate DTO with current form data (Lưu lại các giá trị đã nhập vào form)
                RoomAmenityDTO amenity = new RoomAmenityDTO();
                amenity.setRoomId(roomId);
                amenity.setName(name);
                amenity.setDescription(description);
                amenity.setIsChargeable(isChargeable);
                amenity.setUnitPrice(unitPrice);

                request.setAttribute("amenity", amenity);
                request.setAttribute("formAction", formAction);
                request.setAttribute("pageTitle", ("edit".equals(formAction) ? "Edit" : "Add") + " Room Amenity");
                request.setAttribute("activePage", "room-amenity");
                request.setAttribute("contentPage", "/jsp/admin/room-amenity-form.jsp");

                // Chuyển hướng về trang Add hoặc Edit với thông báo lỗi
                if ("edit".equals(formAction)) {
                    // Dành cho chỉnh sửa
                    response.sendRedirect(request.getContextPath() + "/admin/amenities?action=edit&id=" + request.getParameter("id") + "&error=" + URLEncoder.encode(errorMessage, "UTF-8"));
                } else {
                    // Dành cho thêm mới
                    response.sendRedirect(request.getContextPath() + "/admin/amenities?action=add&error=" + URLEncoder.encode(errorMessage, "UTF-8"));
                }
                return;
            }

            // Proceed with add or update logic
            RoomAmenityDTO amenity = new RoomAmenityDTO();
            amenity.setRoomId(roomId);
            amenity.setName(name);
            amenity.setDescription(description);
            amenity.setIsChargeable(isChargeable);
            amenity.setUnitPrice(unitPrice);

            if ("edit".equals(formAction)) {
                amenity.setId(Integer.parseInt(request.getParameter("id")));
                amenityDAO.updateAmenity(amenity);
                response.sendRedirect(request.getContextPath() + "/admin/amenities?action=list&success=Update success!");
            } else {
                amenity.setCreatedAt(new Date());
                amenityDAO.insertAmenity(amenity);
                response.sendRedirect(request.getContextPath() + "/admin/amenities?action=list&success=Add success!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());

            request.setAttribute("formAction", formAction);
            request.setAttribute("pageTitle", ("edit".equals(formAction) ? "Edit" : "Add") + " Room Amenity");

            List<Room> roomList = amenityDAO.getAllRooms();
            request.setAttribute("roomList", roomList);

            // Rebuild the DTO with previous values
            RoomAmenityDTO amenity = new RoomAmenityDTO();
            try {
                amenity.setRoomId(Integer.parseInt(request.getParameter("roomId")));
                amenity.setName(request.getParameter("name"));
                amenity.setDescription(request.getParameter("description"));
                amenity.setIsChargeable(Boolean.parseBoolean(request.getParameter("isChargeable")));
                amenity.setUnitPrice(new BigDecimal(request.getParameter("unitPrice")));
                if ("edit".equals(formAction)) {
                    amenity.setId(Integer.parseInt(request.getParameter("id")));
                }
            } catch (Exception ex) {
                // Ignore parsing errors
            }

            request.setAttribute("amenity", amenity);
            request.setAttribute("activePage", "room-amenity");
            request.setAttribute("contentPage", "/jsp/admin/room-amenity-form.jsp");

            // Forward back to form if error occurs
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
        }
    }

    private void listAmenities(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy tham số lọc và tìm kiếm từ request
        String keyword = request.getParameter("keyword");
        String roomNumber = request.getParameter("roomNumber");
        String amenityName = request.getParameter("amenityName");

        keyword = (keyword != null && !keyword.trim().isEmpty()) ? keyword.trim() : null;
        roomNumber = (roomNumber != null && !roomNumber.trim().isEmpty()) ? roomNumber.trim() : null;

        // Lấy trang hiện tại và pageSize
        int page = 1;
        int pageSize = 3;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
            if (page <= 0) {
                page = 1;
            }
        } catch (NumberFormatException e) {
            // mặc định page = 1
        }

        int offset = (page - 1) * pageSize;

        // Tổng số bản ghi phù hợp để tính tổng trang
        int totalAmenities = amenityDAO.countAmenities(keyword, roomNumber, amenityName);
        int totalPages = (totalAmenities == 0) ? 1 : (int) Math.ceil((double) totalAmenities / pageSize);
        if (page > totalPages) {
            page = totalPages;
            offset = (page - 1) * pageSize;
        }

        // Lấy danh sách tiện ích theo phân trang và lọc
        List<RoomAmenityDTO> amenities;
        if ((keyword == null || keyword.trim().isEmpty())
                && (roomNumber == null || roomNumber.trim().isEmpty())
                && (amenityName == null || amenityName.trim().isEmpty())) {

            amenities = amenityDAO.getAllPaginated(offset, pageSize);

        } else {
            amenities = amenityDAO.searchAndFilterAmenities(keyword, roomNumber, amenityName, offset, pageSize);
        }

        List<Room> roomList = amenityDAO.getAllRooms();
        List<String> amenityNameList = amenityDAO.getAllAmenityNames();

        request.setAttribute("roomList", roomList);
        request.setAttribute("amenityNameList", amenityNameList);

        // Gán dữ liệu vào request để render ra giao diện
        request.setAttribute("amenities", amenities);
        request.setAttribute("keyword", keyword);
        request.setAttribute("roomNumber", roomNumber);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("recordsPerPage", pageSize);
        request.setAttribute("totalRecords", totalAmenities);

        // Nếu có thông báo success
        String success = request.getParameter("success");
        if (success != null && !success.isEmpty()) {
            request.setAttribute("success", success);
        }

        // Forward đến giao diện admin-template.jsp
        request.setAttribute("pageTitle", "Room Amenity Management");
        request.setAttribute("activePage", "room-amenity");
        request.setAttribute("contentPage", "/jsp/admin/room-amenity-list.jsp");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void viewAmenityDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("amenities");
            return;
        }

        try {
            // Chuyển đổi tham số id thành số nguyên
            int id = Integer.parseInt(idStr);
            RoomAmenityDAO amenityDAO = new RoomAmenityDAO();
            RoomAmenityDTO amenity = amenityDAO.getRoomAmenityById(id);

            // Kiểm tra xem tiện ích có tồn tại không
            if (amenity == null) {
                request.setAttribute("error", "Amenity not found");
                listAmenities(request, response);
                return;
            }

            // Đưa thông tin tiện ích vào request
            request.setAttribute("roomAmenity", amenity);
            request.setAttribute("pageTitle", "Amenity Details");
            request.setAttribute("activePage", "room-amenity");
            request.setAttribute("contentPage", "/jsp/admin/room-amenity-detail.jsp");

            // Forward đến trang chi tiết tiện ích
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("amenities");
        }
    }

    private void showAmenityForm(HttpServletRequest request, HttpServletResponse response, RoomAmenityDTO amenity)
            throws ServletException, IOException {

        List<Room> roomList = amenityDAO.getAllRooms();

        request.setAttribute("roomList", roomList);
        request.setAttribute("amenity", amenity);

        // Gán action để biết đang add hay edit
        request.setAttribute("formAction", (amenity != null ? "edit" : "add"));

        request.setAttribute("pageTitle", (amenity != null ? "Edit" : "Add") + " Room Amenity");
        request.setAttribute("activePage", "room-amenity");
        request.setAttribute("contentPage", "/jsp/admin/room-amenity-form.jsp");

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
