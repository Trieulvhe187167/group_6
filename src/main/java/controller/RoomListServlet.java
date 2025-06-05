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

@WebServlet(name = "RoomListServlet", urlPatterns = {"/RoomListServlet"})
public class RoomListServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        RoomTypeDAO dao = new RoomTypeDAO();
        List<RoomType> roomTypes;
        String keyword = request.getParameter("keyword");
        String action = request.getParameter("action");

        if (keyword != null && !keyword.trim().isEmpty()) {
            roomTypes = dao.searchRooms(keyword.trim());
        } else {
            roomTypes = dao.getAllRoomTypes();
        }
        
        // Delete
        if (action != null && action.equalsIgnoreCase("delete")) {
            String idParam = request.getParameter("id");
            String status = request.getParameter("status");
            if (idParam != null) {
                int id = Integer.parseInt(idParam);
                dao.updateRoomTypeStatus(id, status);
                // Refresh list after delete
                response.sendRedirect("RoomListServlet");
                return;
            }
        }

        // Phân trang
        int recordsPerPage = 6;
        String pageStr = request.getParameter("page");
        int currentPage = 1;
        if (pageStr != null) {
            currentPage = Integer.parseInt(pageStr);
        }

        int totalRecords = roomTypes.size();
        int totalPages = (int) Math.ceil(totalRecords * 1.0 / recordsPerPage);
        
        // Set attributes
        request.setAttribute("roomTypes", roomTypes);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("recordsPerPage", recordsPerPage);
        request.setAttribute("totalPages", totalPages);
        
        request.getRequestDispatcher("/jsp/roomList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
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

                RoomTypeDAO dao = new RoomTypeDAO();
                dao.insert(roomType);

                response.sendRedirect("RoomListServlet");
            } catch (Exception e) {
                request.setAttribute("message", "Error creating RoomType: " + e.getMessage());
                request.getRequestDispatcher("/jsp/create-roomtype.jsp").forward(request, response);
            }
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}