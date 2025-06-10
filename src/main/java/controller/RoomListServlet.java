package controller;

import dal.RoomTypeDAO;
import model.RoomType;
import java.util.List;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Servlet for handling room list view for users
 */
@WebServlet(name = "RoomListServlet", urlPatterns = {"/RoomListServlet"})
public class RoomListServlet extends HttpServlet {

    private static final int RECORDS_PER_PAGE = 6;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        RoomTypeDAO dao = new RoomTypeDAO();
        List<RoomType> roomTypes;
        
        // Get parameters
        String keyword = request.getParameter("keyword");
        String price = request.getParameter("price");
        String capacity = request.getParameter("capacity");
        String status = request.getParameter("status");
        
        // Get page parameter
        String pageStr = request.getParameter("page");
        int currentPage = 1;
        if (pageStr != null) {
            try {
                currentPage = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        // Apply filters and search - only show active room types to users
        if (keyword != null && !keyword.trim().isEmpty()) {
            roomTypes = dao.searchRooms(keyword.trim());
            // Filter out inactive room types
            roomTypes.removeIf(room -> !"active".equals(room.getStatus()));
            request.setAttribute("keyword", keyword);
        } else if ((price != null && !price.isEmpty())
                || (capacity != null && !capacity.isEmpty())
                || (status != null && !status.isEmpty())) {
            // For user view, always filter by active status
            roomTypes = dao.filterRoomTypes(price, capacity, "active");
            request.setAttribute("selectedPrice", price);
            request.setAttribute("selectedCapacity", capacity);
            request.setAttribute("selectedStatus", status);
        } else {
            // Only show active room types to users
            roomTypes = dao.getAllRoomTypesActive();
        }

        // Calculate pagination
        int totalRecords = roomTypes.size();
        int totalPages = (int) Math.ceil(totalRecords * 1.0 / RECORDS_PER_PAGE);

        // Set attributes
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("recordsPerPage", RECORDS_PER_PAGE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("roomTypes", roomTypes);

        // Forward to JSP
        request.getRequestDispatcher("jsp/roomList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // For user view, we don't allow POST operations like create/delete
        // Redirect to GET method
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet for displaying room list to users";
    }
}