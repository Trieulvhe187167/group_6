package controller;

import dal.RoomDAO;
import dal.RoomTypeDAO;
import dal.FeedbackDAO;
import model.Room;
import model.RoomType;
import model.RatingStats;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Calendar;
import java.util.stream.Collectors;
/**
 * Servlet for searching available rooms based on date range and criteria
 */
@WebServlet(name = "SearchAvailableRoomsServlet", urlPatterns = {"/SearchAvailableRoomsServlet"})
public class SearchAvailableRoomsServlet extends HttpServlet {

    private static final int RECORDS_PER_PAGE = 6;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get search parameters
            String roomTypeIdStr = request.getParameter("roomTypeId");
            String checkInStr = request.getParameter("checkIn");
            String checkOutStr = request.getParameter("checkOut");
            String capacityStr = request.getParameter("capacity");
            String keyword = request.getParameter("keyword");
            String priceRange = request.getParameter("price");
            
              // Persist search parameters in session for back navigation
            jakarta.servlet.http.HttpSession session = request.getSession();
            if (checkInStr != null) session.setAttribute("lastSearchCheckIn", checkInStr);
            if (checkOutStr != null) session.setAttribute("lastSearchCheckOut", checkOutStr);
            if (roomTypeIdStr != null) session.setAttribute("lastSearchRoomTypeId", roomTypeIdStr);
            if (capacityStr != null) session.setAttribute("lastSearchCapacity", capacityStr);
            
            // Store search parameters to maintain in form
            request.setAttribute("searchRoomTypeId", roomTypeIdStr);
            request.setAttribute("searchCheckIn", checkInStr);
            request.setAttribute("searchCheckOut", checkOutStr);
            request.setAttribute("searchCapacity", capacityStr);
            request.setAttribute("selectedCapacity", capacityStr);
            request.setAttribute("selectedPrice", priceRange);
            request.setAttribute("keyword", keyword);
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

           // If check-in or check-out missing, show room list only.
            if (checkInStr == null || checkInStr.trim().isEmpty()
                    || checkOutStr == null || checkOutStr.trim().isEmpty()) {

                RoomTypeDAO dao = new RoomTypeDAO();
                List<RoomType> roomTypes;

                if (roomTypeIdStr != null && !roomTypeIdStr.trim().isEmpty()) {
                    try {
                        int rtId = Integer.parseInt(roomTypeIdStr);
                        RoomType rt = dao.getRoomTypesById(rtId);
                        if (rt != null && "active".equalsIgnoreCase(rt.getStatus())) {
                            roomTypes = new ArrayList<>();
                            roomTypes.add(rt);
                        } else {
                            roomTypes = new ArrayList<>();
                        }
                    } catch (NumberFormatException e) {
                        roomTypes = new ArrayList<>();
                    }
                    request.setAttribute("searchRoomTypeId", roomTypeIdStr);
                } else if (keyword != null && !keyword.trim().isEmpty()) {
                    roomTypes = dao.searchRooms(keyword.trim());
                    roomTypes.removeIf(room -> !"active".equalsIgnoreCase(room.getStatus()));
                    request.setAttribute("keyword", keyword);
                } else if ((priceRange != null && !priceRange.isEmpty())
                        || (capacityStr != null && !capacityStr.isEmpty())) {
                    roomTypes = dao.filterRoomTypes(priceRange, capacityStr, "active");
                    request.setAttribute("selectedPrice", priceRange);
                    request.setAttribute("selectedCapacity", capacityStr);
                } else {
                    roomTypes = dao.getAllRoomTypesActive();
                }

                int totalRecords = roomTypes.size();
                int totalPages = (int) Math.ceil(totalRecords * 1.0 / RECORDS_PER_PAGE);

                int start = (currentPage - 1) * RECORDS_PER_PAGE;
                int end = Math.min(start + RECORDS_PER_PAGE, totalRecords);
                List<RoomType> paginatedRoomTypes = new ArrayList<>();
                if (start < totalRecords) {
                    paginatedRoomTypes = roomTypes.subList(start, end);
                }
                
                      // Fetch rating stats for displayed room types
                FeedbackDAO feedbackDAO = new FeedbackDAO();
                List<Integer> ids = paginatedRoomTypes.stream()
                        .map(RoomType::getId)
                        .collect(Collectors.toList());
                Map<Integer, RatingStats> statsMap = feedbackDAO.getRatingStatsForRoomTypes(ids);
                for (RoomType rt : paginatedRoomTypes) {
                    RatingStats stats = statsMap.get(rt.getId());
                    if (stats != null) {
                        rt.setAverageRating(stats.getAverageRating());
                        rt.setReviewCount(stats.getReviewCount());
                    }
                }

                request.setAttribute("roomTypes", paginatedRoomTypes);
                request.setAttribute("currentPage", currentPage);
                request.setAttribute("recordsPerPage", RECORDS_PER_PAGE);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRecords", totalRecords);
                request.setAttribute("isSearchMode", false);
                request.getRequestDispatcher("/jsp/roomList.jsp").forward(request, response);
                return;
            }

            // Parse dates
            Date checkIn = Date.valueOf(checkInStr);
            Date checkOut = Date.valueOf(checkOutStr);

            // Validate dates
            // Get today's date at 00:00:00
            Calendar cal = Calendar.getInstance();
            cal.set(Calendar.HOUR_OF_DAY, 0);
            cal.set(Calendar.MINUTE, 0);
            cal.set(Calendar.SECOND, 0);
            cal.set(Calendar.MILLISECOND, 0);
            Date today = new Date(cal.getTimeInMillis());

            // Compare dates without time component
            if (checkIn.before(today)) {
                request.setAttribute("error", "Check-in date cannot be in the past");
                request.getRequestDispatcher("/jsp/roomList.jsp").forward(request, response);
                return;
            }

            if (checkOut.before(checkIn) || checkOut.equals(checkIn)) {
                request.setAttribute("error", "Check-out date must be after check-in date");
                request.getRequestDispatcher("/jsp/roomList.jsp").forward(request, response);
                return;
            }

            // Parse capacity
            int capacity = 2; // default
            if (capacityStr != null && !capacityStr.trim().isEmpty()) {
                try {
                    capacity = Integer.parseInt(capacityStr);
                } catch (NumberFormatException e) {
                    capacity = 2;
                }
            }

            // Initialize DAOs
            RoomDAO roomDAO = new RoomDAO();
            RoomTypeDAO roomTypeDAO = new RoomTypeDAO();

            // Debug: Check total available rooms
            List<Room> allAvailableRooms = roomDAO.getAvailableRooms();
            System.out.println("Total AVAILABLE rooms in system: " + allAvailableRooms.size());

            // Get available room types
            List<RoomType> availableRoomTypes = new ArrayList<>();

            if (roomTypeIdStr != null && !roomTypeIdStr.trim().isEmpty() && !roomTypeIdStr.equals("")) {
                // Search for specific room type
                try {
                    int roomTypeId = Integer.parseInt(roomTypeIdStr);
                    RoomType roomType = roomTypeDAO.getRoomTypesById(roomTypeId);

                    if (roomType != null && "active".equals(roomType.getStatus())) {
                        // Check if this room type has available rooms
                        List<Room> availableRooms = roomDAO.getAvailableRoomsByTypeAndDate(
                                roomTypeId, checkIn, checkOut);

                        if (!availableRooms.isEmpty() && roomType.getCapacity() >= capacity) {
                            // Set available room count for display
                            roomType.setAvailableRoomCount(availableRooms.size());
                            availableRoomTypes.add(roomType);
                        }
                    }
                } catch (NumberFormatException e) {
                    // Invalid room type ID, search all
                }
            } else {
                // Search all room types
                List<RoomType> allActiveRoomTypes = roomTypeDAO.getAllRoomTypesActive();
                System.out.println("Total active room types: " + allActiveRoomTypes.size());

                // Debug reservations
                roomDAO.debugReservations(checkIn, checkOut);

                for (RoomType roomType : allActiveRoomTypes) {
                    // Skip if capacity is insufficient
                    if (roomType.getCapacity() < capacity) {
                        System.out.println("Skipping " + roomType.getName() + " - capacity " + roomType.getCapacity() + " < required " + capacity);
                        continue;
                    }

                    // First check rooms without date restriction
                    List<Room> roomsNoDate = roomDAO.getAvailableRoomsByTypeNoDateCheck(roomType.getId());

                    // Then check with date restriction
                    List<Room> availableRooms = roomDAO.getAvailableRoomsByTypeAndDate(
                            roomType.getId(), checkIn, checkOut);

                    System.out.println("Room Type: " + roomType.getName()
                            + " - Total available (no date): " + roomsNoDate.size()
                            + " - Available for dates: " + availableRooms.size());

                    if (!availableRooms.isEmpty()) {
                        // Set available room count for display
                        roomType.setAvailableRoomCount(availableRooms.size());
                        availableRoomTypes.add(roomType);
                    }
                }
            }
   // Filter by keyword if specified
            if (keyword != null && !keyword.trim().isEmpty()) {
                String lowerKeyword = keyword.toLowerCase();
                List<RoomType> filteredByKeyword = new ArrayList<>();
                for (RoomType rt : availableRoomTypes) {
                    if (rt.getName().toLowerCase().contains(lowerKeyword)) {
                        filteredByKeyword.add(rt);
                    }
                }
                availableRoomTypes = filteredByKeyword;
            }

            // Filter by price range if specified
            if (priceRange != null && !priceRange.isEmpty()) {
                List<RoomType> filteredByPrice = new ArrayList<>();
                for (RoomType rt : availableRoomTypes) {
                    boolean match = true;
                    switch (priceRange) {
                        case "1":
                            match = rt.getBasePrice().compareTo(new java.math.BigDecimal(500000)) < 0;
                            break;
                        case "2":
                            match = rt.getBasePrice().compareTo(new java.math.BigDecimal(500000)) >= 0
                                    && rt.getBasePrice().compareTo(new java.math.BigDecimal(1000000)) <= 0;
                            break;
                        case "3":
                            match = rt.getBasePrice().compareTo(new java.math.BigDecimal(1000000)) > 0;
                            break;
                    }
                    if (match) {
                        filteredByPrice.add(rt);
                    }
                }
                availableRoomTypes = filteredByPrice;
            }
            // Sort by price (ascending)
             availableRoomTypes.sort((a, b) ->
                a.getBasePrice().compareTo(b.getBasePrice()));

            // Calculate nights
            long diffInMillies = checkOut.getTime() - checkIn.getTime();
            int nights = (int) (diffInMillies / (1000 * 60 * 60 * 24));

            // Pagination
            int totalRecords = availableRoomTypes.size();
            int totalPages = (int) Math.ceil(totalRecords * 1.0 / RECORDS_PER_PAGE);

            // Get records for current page
            int start = (currentPage - 1) * RECORDS_PER_PAGE;
            int end = Math.min(start + RECORDS_PER_PAGE, totalRecords);

            List<RoomType> paginatedRoomTypes = new ArrayList<>();
            if (start < totalRecords) {
                paginatedRoomTypes = availableRoomTypes.subList(start, end);
            }
            
                // Fetch rating stats for displayed room types
            FeedbackDAO feedbackDAO = new FeedbackDAO();
            List<Integer> ids = paginatedRoomTypes.stream()
                    .map(RoomType::getId)
                    .collect(Collectors.toList());
            Map<Integer, RatingStats> statsMap = feedbackDAO.getRatingStatsForRoomTypes(ids);
            for (RoomType rt : paginatedRoomTypes) {
                RatingStats stats = statsMap.get(rt.getId());
                if (stats != null) {
                    rt.setAverageRating(stats.getAverageRating());
                    rt.setReviewCount(stats.getReviewCount());
                }
            }

            // Set attributes for JSP
            request.setAttribute("roomTypes", paginatedRoomTypes);
            request.setAttribute("checkIn", checkIn);
            request.setAttribute("checkOut", checkOut);
            request.setAttribute("checkInStr", checkInStr);
            request.setAttribute("checkOutStr", checkOutStr);
            request.setAttribute("capacity", capacity);
            request.setAttribute("roomTypeId", roomTypeIdStr);
            request.setAttribute("nights", nights);
            request.setAttribute("totalAvailableRooms", totalRecords);

            // Pagination attributes
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("recordsPerPage", RECORDS_PER_PAGE);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalRecords", totalRecords);

            // Search mode flag
            request.setAttribute("isSearchMode", true);

            // Format dates for display
            SimpleDateFormat displayFormat = new SimpleDateFormat("MMM dd, yyyy");
            request.setAttribute("checkInDisplay", displayFormat.format(checkIn));
            request.setAttribute("checkOutDisplay", displayFormat.format(checkOut));

            // Debug information
            System.out.println("Search Parameters:");
            System.out.println("- Room Type ID: " + roomTypeIdStr);
            System.out.println("- Check-in: " + checkInStr);
            System.out.println("- Check-out: " + checkOutStr);
            System.out.println("- Capacity: " + capacity);
            System.out.println("- Total available room types found: " + totalRecords);

            // Forward to room list page
            request.getRequestDispatcher("/jsp/roomList.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while searching for rooms: " + e.getMessage());
            request.getRequestDispatcher("/jsp/roomList.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
