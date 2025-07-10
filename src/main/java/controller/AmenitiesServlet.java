// New AmenitiesServlet.java
package controller;

import dal.*;
import model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import com.google.gson.Gson;
import java.math.BigDecimal;

@WebServlet(name = "AmenitiesServlet", urlPatterns = {"/receptionist/amenities"})
public class AmenitiesServlet extends HttpServlet {

    private RoomAmenityDAO amenityDAO = new RoomAmenityDAO();
    private ReservationDAO reservationDAO = new ReservationDAO();
    private CheckInOutDAO checkInOutDAO = new CheckInOutDAO();
    private ActivityDAO activityDAO = new ActivityDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check receptionist authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        try {
            // Get recent amenity logs
            List<AmenityUsageLog> recentLogs = amenityDAO.getRecentAmenityLogs(20);

            // Set attributes
            request.setAttribute("recentLogs", recentLogs);
            request.setAttribute("currentUser", currentUser);

            // Set template attributes
            request.setAttribute("pageTitle", "Room Amenities Management");
            request.setAttribute("activePage", "amenities");
            // No need to set contentPage anymore as we're using direct includes

            // Forward to template
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading amenities page: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("getRoomsByFloor".equals(action)) {
            getRoomsByFloor(request, response);
        } else if ("getRoomAmenityStatus".equals(action)) {
            getRoomAmenityStatus(request, response);
        } else if ("saveAmenityUsage".equals(action)) {
            saveAmenityUsage(request, response);
        } else if ("addAmenity".equals(action)) {
            addAmenity(request, response);
        }
    }

    private void getRoomsByFloor(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int floor = Integer.parseInt(request.getParameter("floor"));
            List<Room> rooms = amenityDAO.getRoomsByFloor(floor);

            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(rooms));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void getRoomAmenityStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));

            // 1. Lấy reservation hiện tại
            Reservation reservation = reservationDAO.getCurrentReservationByRoom(roomId);

            if (reservation == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"error\":\"No current reservation found\"}");
                return;
            }

            // 2. Tính số ngày lưu trú
            long daysStayed = (new Date().getTime() - reservation.getCheckIn().getTime()) / (1000 * 60 * 60 * 24);
            if (daysStayed < 1) {
                daysStayed = 1;
            }

            // 3. Lấy danh sách InspectionItem theo reservationId
            List<InspectionItem> allItems = amenityDAO.getInspectionItemsByReservation(reservation.getId());

            // 4. Tách MINIBAR và ROOM
            List<InspectionItem> minibarItems = new ArrayList<>();
            List<InspectionItem> roomAmenities = new ArrayList<>();

            for (InspectionItem item : allItems) {
                if ("MINIBAR".equalsIgnoreCase(item.getItemCategory())) {
                    minibarItems.add(item);
                } else {
                    roomAmenities.add(item);
                }
            }

            // 5. Chuẩn bị kết quả JSON
            Map<String, Object> result = new HashMap<>();
            Map<String, Object> reservationInfo = new HashMap<>();
            reservationInfo.put("id", reservation.getId());
            reservationInfo.put("customerName", reservation.getCustomerName());
            reservationInfo.put("checkIn", reservation.getCheckIn());
            reservationInfo.put("daysStayed", daysStayed);

            result.put("reservation", reservationInfo);
            result.put("minibarItems", minibarItems);
            result.put("roomAmenities", roomAmenities);

            response.setContentType("application/json");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Internal server error\"}");
        }
    }

    private void saveAmenityUsage(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            Gson gson = new Gson();
            Map<String, Object> usageData = gson.fromJson(request.getReader(), Map.class);

            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");

            int reservationId = ((Double) usageData.get("reservationId")).intValue();
            List<Map<String, Object>> amenityUsage = (List<Map<String, Object>>) usageData.get("amenityUsage");

            boolean success = true;

            // 1. Tạo hoặc lấy Inspection hiện tại
            int inspectionId = amenityDAO.getOrCreateInspection(reservationId, currentUser.getId());

            for (Map<String, Object> usage : amenityUsage) {
                int amenityId = ((Double) usage.get("amenityId")).intValue();
                Object quantityObj = usage.get("quantity");
                if (quantityObj == null) {
                    continue;
                }
                int quantity = ((Double) quantityObj).intValue();
                if (quantity <= 0) {
                    continue;
                }

                // Lấy thông tin tiện ích
                RoomAmenity amenity = amenityDAO.getAmenityById(amenityId);
                if (amenity != null) {
                    String name = amenity.getName();
                    String category = amenity.getCategory();
                    BigDecimal unitPrice = BigDecimal.valueOf(amenity.getUnitPrice());

                    boolean inserted = inspectionDAO.insertInspectionItem(
                            inspectionId,
                            name,
                            category,
                            quantity,
                            unitPrice,
                            null // có thể thêm ghi chú nếu cần
                    );
                    if (!inserted) {
                        success = false;
                        break;
                    }
                }
            }

            if (success) {
                // Log activity
                Activity activity = new Activity();
                activity.setType("AMENITY_USAGE");
                activity.setReservationId(reservationId);
                activity.setUserId(currentUser.getId());
                activity.setDescription("Receptionist logged amenity usage for reservation #" + reservationId);
                activity.setIpAddress(request.getRemoteAddr());
                activityDAO.logActivity(activity);
            }

            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }

    private void addAmenity(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            Gson gson = new Gson();
            Map<String, Object> amenityData = gson.fromJson(request.getReader(), Map.class);

            HttpSession session = request.getSession();
            User currentUser = (User) session.getAttribute("user");

            RoomAmenity amenity = new RoomAmenity();
            amenity.setName((String) amenityData.get("name"));
            amenity.setDescription((String) amenityData.get("description"));
            amenity.setCategory((String) amenityData.get("category"));

            Object isChargeableObj = amenityData.get("isChargeable");
            boolean isChargeable = isChargeableObj != null && (Boolean) isChargeableObj;
            amenity.setIsChargeable(isChargeable);

            if (amenity.getIsChargeable()) {
                amenity.setUnitPrice(((Double) amenityData.get("unitPrice")).doubleValue());
            } else {
                amenity.setUnitPrice(0);
            }

            amenity.setCreatedBy(currentUser.getId());

            boolean success = amenityDAO.createAmenity(amenity);

            response.setContentType("application/json");
            response.getWriter().write("{\"success\":" + success + "}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false}");
        }
    }

//    private RoomAmenity getAmenityById(int amenityId) {
//        // This would need to be implemented in the DAO
//        // For now, return null and handle in the calling method
//        try {
//            return amenityDAO.getAmenityById(amenityId);
//        } catch (Exception e) {
//            e.printStackTrace();
//            return null;
//        }
//    }
}
