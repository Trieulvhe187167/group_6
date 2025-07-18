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

        // Admin role
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "list";
        }

        RoomAmenityDTO errorAmenity = (RoomAmenityDTO) session.getAttribute("errorAmenity");
        String errorMessage = (String) session.getAttribute("errorMessage");

        if (errorAmenity != null) {
            session.removeAttribute("errorAmenity");
        }
        if (errorMessage != null) {
            session.removeAttribute("errorMessage");
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
                    if (errorAmenity != null && "add".equals(errorAmenity.getFormAction())) {
                        request.setAttribute("amenity", errorAmenity);
                        request.setAttribute("error", errorMessage);
                        request.setAttribute("formAction", "add");
                        request.setAttribute("pageTitle", "Add Room Amenity");
                    } else {
                        request.setAttribute("amenity", new RoomAmenityDTO());
                        request.setAttribute("formAction", "add");
                        request.setAttribute("pageTitle", "Add Room Amenity");
                    }
                    showAmenityForm(request, response);
                    break;

                case "edit":
                    if (errorAmenity != null && "edit".equals(errorAmenity.getFormAction())) {
                        request.setAttribute("amenity", errorAmenity);
                        request.setAttribute("error", errorMessage);
                        request.setAttribute("formAction", "edit");
                        request.setAttribute("pageTitle", "Edit Room Amenity");
                    } else {
                        int id = Integer.parseInt(request.getParameter("id"));
                        RoomAmenityDTO amenityFromDb = amenityDAO.getRoomAmenityById(id);
                        if (amenityFromDb == null) {
                            request.setAttribute("error", "Amenity not found with ID: " + id);
                            listAmenities(request, response);
                            return;
                        }
                        request.setAttribute("amenity", amenityFromDb);
                        request.setAttribute("formAction", "edit");
                        request.setAttribute("pageTitle", "Edit Room Amenity");
                    }
                    showAmenityForm(request, response);
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

        RoomAmenityDTO amenity = new RoomAmenityDTO();
        int id = 0;

        try {
            // Lấy các giá trị từ form
            amenity.setRoomId(Integer.parseInt(request.getParameter("roomId")));
            amenity.setName(request.getParameter("name").trim());
            amenity.setDescription(request.getParameter("description").trim());
            amenity.setIsChargeable(Boolean.parseBoolean(request.getParameter("isChargeable")));
            amenity.setUnitPrice(new BigDecimal(request.getParameter("unitPrice")));

            if ("edit".equals(formAction)) {
                id = Integer.parseInt(request.getParameter("id"));
                amenity.setId(id);
            }
            amenity.setFormAction(formAction);

            // Check Duplicate
            boolean isDuplicate;
            if ("edit".equals(formAction)) {
                isDuplicate = amenityDAO.checkAmenityDuplicateExceptId(amenity.getRoomId(), amenity.getName(), amenity.getDescription(), amenity.getId());
            } else {
                isDuplicate = amenityDAO.checkAmenityDuplicate(amenity.getRoomId(), amenity.getName(), amenity.getDescription());
            }

            // If Duplicate
            if (isDuplicate) {
                String errorMessage = "Amenity with the same room, name, and description already exists.";

                HttpSession session = request.getSession();
                session.setAttribute("errorAmenity", amenity);
                session.setAttribute("errorMessage", errorMessage);

                // Redirect back to the corresponding GET request to display the form with the error
                if ("edit".equals(formAction)) {
                    response.sendRedirect(request.getContextPath() + "/admin/amenities?action=edit&id=" + amenity.getId());
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/amenities?action=add");
                }
                return;
            }

            // If no error
            if ("edit".equals(formAction)) {
                amenityDAO.updateAmenity(amenity);
                response.sendRedirect(request.getContextPath() + "/admin/amenities?action=list&success=" + URLEncoder.encode("Update success!", "UTF-8"));
            } else {
                amenity.setCreatedAt(new Date());
                amenityDAO.insertAmenity(amenity);
                response.sendRedirect(request.getContextPath() + "/admin/amenities?action=list&success=" + URLEncoder.encode("Add success!", "UTF-8"));
            }

        } catch (NumberFormatException e) {
            String errorMessage = "Invalid number format for Room ID, Amenity ID, or Unit Price. Please enter valid numbers.";
            e.printStackTrace();

            HttpSession session = request.getSession();
            session.setAttribute("errorAmenity", amenity);
            session.setAttribute("errorMessage", errorMessage);

            if ("edit".equals(formAction)) {
                String requestedId = request.getParameter("id");
                response.sendRedirect(request.getContextPath() + "/admin/amenities?action=edit&id=" + (requestedId != null ? requestedId : "0"));
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/amenities?action=add");
            }
            return;
        } catch (Exception e) {
            // Xử lý các lỗi khác
            String errorMessage = "An unexpected error occurred: " + e.getMessage();
            e.printStackTrace();

            HttpSession session = request.getSession();
            session.setAttribute("errorAmenity", amenity);
            session.setAttribute("errorMessage", errorMessage);

            if ("edit".equals(formAction)) {
                String requestedId = request.getParameter("id");
                response.sendRedirect(request.getContextPath() + "/admin/amenities?action=edit&id=" + (requestedId != null ? requestedId : "0"));
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/amenities?action=add");
            }
            return;
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

    private void showAmenityForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Luôn cần danh sách phòng cho dropdown
        List<Room> roomList = amenityDAO.getAllRooms();
        request.setAttribute("roomList", roomList);

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
