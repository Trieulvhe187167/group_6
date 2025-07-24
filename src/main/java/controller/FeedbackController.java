package controller;

import dal.FeedbackDAO;
import dal.ReservationDAO;
import dal.ContactMessageDAO;
import model.Feedback;
import model.Reservation;
import model.User;
import model.ContactMessage;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import jakarta.servlet.annotation.MultipartConfig;
import com.google.gson.Gson;

@WebServlet(urlPatterns = {"/customer/feedback", "/customer/feedback/*", "/customer/your-feedback", "/receptionist/feedback", "/receptionist/feedback/*", "/admin/feedback"})
@MultipartConfig
public class FeedbackController extends HttpServlet {
    
    private FeedbackDAO feedbackDAO;
    private ReservationDAO reservationDAO;
    
    @Override
    public void init() throws ServletException {
        feedbackDAO = new FeedbackDAO();
        reservationDAO = new ReservationDAO();
    }
    
   @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {

    System.out.println("=== FEEDBACK CONTROLLER CALLED ===");
    System.out.println("=== REQUEST URI: " + request.getRequestURI());
    System.out.println("=== SERVLET PATH: " + request.getServletPath());
    System.out.println("=== QUERY STRING: " + request.getQueryString());
    
    HttpSession session = request.getSession();
    User user = (User) session.getAttribute("user");

    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Check if this is a receptionist or admin request
    String requestURI = request.getRequestURI();
    if (requestURI.contains("/receptionist/feedback")) {
        // Check if user is receptionist or admin
        if ("RECEPTIONIST".equals(user.getRole()) || "ADMIN".equals(user.getRole())) {
            handleReceptionistRequest(request, response, user);
            return;
        } else {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
    }
    
    // Check if this is an admin request
    if (requestURI.contains("/admin/feedback")) {
        // Check if user is admin
        if ("ADMIN".equals(user.getRole())) {
            handleAdminRequest(request, response, user);
            return;
        } else {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
    }

    // Trong doGet, thêm điều kiện cho /customer/your-feedback
    if (requestURI.contains("/customer/your-feedback")) {
        listUserFeedback(request, response, user);
        return;
    }

    // Customer feedback logic
    String action = request.getParameter("action");
    String filter = request.getParameter("filter");
    String sort = request.getParameter("sort");
    
    System.out.println("DEBUG: Action: " + action);
    System.out.println("DEBUG: Filter: " + filter);
    System.out.println("DEBUG: Sort: " + sort);
    
    // Check if there are filter/sort parameters - if so, this is a list request
    if (filter != null || sort != null) {
        System.out.println("DEBUG: Filter/sort parameters detected - showing feedback list");
        listUserFeedback(request, response, user);
        return;
    }
    
    if (action == null) {
        action = "view";
    }

    switch (action) {
        case "view":
            System.out.println("DEBUG: Showing feedback form");
            showFeedbackForm(request, response, user);
            break;
        case "list":
            System.out.println("DEBUG: Showing feedback list");
            listUserFeedback(request, response, user);
            break;
        case "edit":
            System.out.println("DEBUG: Showing edit form");
            showEditForm(request, response, user);
            break;
        case "delete":
            System.out.println("DEBUG: Deleting feedback");
            deleteFeedback(request, response, user);
            break;
        default:
            System.out.println("DEBUG: Default case - showing feedback form");
            showFeedbackForm(request, response, user);
            break;
    }
}

    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("=== [DEBUG] ĐÃ VÀO HÀM doPost FeedbackController ===");
        System.out.println("action: " + request.getParameter("action"));
        System.out.println("customerEmail: " + request.getParameter("customerEmail"));
        System.out.println("customerName: " + request.getParameter("customerName"));
        System.out.println("subject: " + request.getParameter("subject"));
        System.out.println("message: " + request.getParameter("message"));
        System.out.println("feedbackId: " + request.getParameter("feedbackId"));
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String requestURI = request.getRequestURI();
        if (requestURI.contains("/receptionist/feedback")) {
            if ("RECEPTIONIST".equals(user.getRole()) || "ADMIN".equals(user.getRole())) {
                handleReceptionistPostRequest(request, response, user);
                return;
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                return;
            }
        }

        if (requestURI.contains("/admin/feedback")) {
            if ("ADMIN".equals(user.getRole())) {
                String action = request.getParameter("action");
                if ("disable".equals(action) || "enable".equals(action)) {
                    handleAdminRequest(request, response, user);
                    return;
                }
                // Nếu không có action hợp lệ, redirect về trang feedback
                response.sendRedirect(request.getContextPath() + "/admin/feedback");
                return;
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                return;
            }
        }

        // Customer feedback logic (nếu có)
        String action = request.getParameter("action");
        if (action == null) {
            action = "submit";
        }
        switch (action) {
            case "submit":
                submitFeedback(request, response, user);
                break;
            case "update":
                updateFeedback(request, response, user);
                break;
            default:
                submitFeedback(request, response, user);
                break;
        }
    }
    
    /**
     * Hiển thị form feedback
     */
    private void showFeedbackForm(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        System.out.println("=== SHOW FEEDBACK FORM METHOD CALLED ===");
        
        try {
            // Lấy danh sách reservation của user để chọn
            List<Reservation> reservations = reservationDAO.getReservationsByUserId(user.getId());
            
            // Lọc chỉ những reservation đã hoàn thành và chưa có feedback
            List<Reservation> completedReservations = reservations.stream()
                .filter(r -> "completed".equalsIgnoreCase(r.getStatus()) && 
                           !feedbackDAO.hasUserFeedbackForReservation(user.getId(), r.getId()))
                .collect(java.util.stream.Collectors.toList());
            
            String selectedId = request.getParameter("id");
            request.setAttribute("selectedId", selectedId);

            // Nếu có selectedId, chỉ hiển thị booking đó
            if (selectedId != null && !selectedId.trim().isEmpty()) {
                try {
                    int selectedIdInt = Integer.parseInt(selectedId);
                    List<Reservation> filteredReservations = completedReservations.stream()
                        .filter(r -> r.getId() == selectedIdInt)
                        .collect(java.util.stream.Collectors.toList());
                    request.setAttribute("reservations", filteredReservations);
                } catch (NumberFormatException e) {
                    // Nếu selectedId không phải số, hiển thị tất cả
                    request.setAttribute("reservations", completedReservations);
                }
            } else {
            request.setAttribute("reservations", completedReservations);
            }
            request.getRequestDispatcher("/jsp/customer/customer-feedback.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading feedback form: " + e.getMessage());
            request.getRequestDispatcher("/jsp/customer/customer-feedback.jsp").forward(request, response);
        }
    }
    
    /**
     * Xử lý submit feedback
     */
    private void submitFeedback(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        try {
            // Lấy thông tin từ form
        

            String reservationIdStr = request.getParameter("reservationId");
            String ratingStr = request.getParameter("rating"); // May be decimal (e.g., 4.2) from average
            String comment = request.getParameter("comment");
            
            // NOTE: In the JSP, ensure only one <input name="rating"> is present (the average)
            // Validate dữ liệu
            if (reservationIdStr == null || reservationIdStr.trim().isEmpty()) {
                request.setAttribute("error", "Please select a booking to review.");
                showFeedbackForm(request, response, user);
                return;
            }
            
            if (ratingStr == null || ratingStr.trim().isEmpty()) {
                request.setAttribute("error", "Please provide a rating.");
                showFeedbackForm(request, response, user);
                return;
            }
            
            if (comment == null || comment.trim().isEmpty() || comment.trim().length() < 5) {
                request.setAttribute("error", "Please provide a more detailed feedback comment (at least 5 characters).");
                showFeedbackForm(request, response, user);
                return;
            }
            
            int reservationId = Integer.parseInt(reservationIdStr);
            int rating;
            try {
                double ratingDouble = Double.parseDouble(ratingStr);
                rating = (int) Math.round(ratingDouble); // Round to nearest int (1-5)
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Invalid rating format.");
                showFeedbackForm(request, response, user);
                return;
            }
            
            // Kiểm tra rating hợp lệ
            if (rating < 1 || rating > 5) {
                request.setAttribute("error", "Rating must be between 1 and 5.");
                showFeedbackForm(request, response, user);
                return;
            }
            
            // Kiểm tra reservation có tồn tại và thuộc về user không
            Reservation reservation = reservationDAO.getReservationById(reservationId);
            if (reservation == null || reservation.getUserId() != user.getId()) {
                request.setAttribute("error", "Invalid reservation selected.");
                showFeedbackForm(request, response, user);
                return;
            }
            
            // Kiểm tra đã feedback chưa
            if (feedbackDAO.hasUserFeedbackForReservation(user.getId(), reservationId)) {
                request.setAttribute("error", "You have already provided feedback for this booking.");
                showFeedbackForm(request, response, user);
                return;
            }
            
            // Tạo feedback object
            Feedback feedback = new Feedback();
            feedback.setReservationId(reservationId);
            feedback.setUserId(user.getId());
            feedback.setRating(rating);
            
            // Tạo comment chi tiết bao gồm tất cả thông tin
            StringBuilder fullComment = new StringBuilder();
            fullComment.append("\nFeedback:\n").append(comment.trim());
            
            feedback.setComment(fullComment.toString());
            
            // Lưu feedback
            boolean success = feedbackDAO.addFeedback(feedback);
            
            // Update reservation rating if feedback was added
            if (success) {
                request.setAttribute("success", "Thank you for your feedback! We appreciate your input.");
                // Redirect để tránh resubmit
                response.sendRedirect(request.getContextPath() + "/customer/feedback?success=true");
                return;
            } else {
                request.setAttribute("error", "Failed to submit feedback. Please try again.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid input format. Please check your data.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while submitting feedback: " + e.getMessage());
        }
        
        showFeedbackForm(request, response, user);
    }
    
    /**
     * Hiển thị danh sách feedback của user
     */
   private void listUserFeedback(HttpServletRequest request, HttpServletResponse response, User user) 
        throws ServletException, IOException {

    System.out.println("=== LIST USER FEEDBACK METHOD CALLED ===");
    System.out.println("=== USER ID: " + user.getId() + " ===");
    
    int userId = user.getId();

    String filter = request.getParameter("filter");
    String sort = request.getParameter("sort");
    
    System.out.println("=== FILTER: " + filter + ", SORT: " + sort + " ===");
    
    // Set defaults if not provided
    if (filter == null || filter.trim().isEmpty()) {
        filter = "all";
    }
    if (sort == null || sort.trim().isEmpty()) {
        sort = "date_desc"; // Changed default to be more specific
    }
    
    System.out.println("=== FINAL FILTER: " + filter + ", FINAL SORT: " + sort + " ===");

    try {
        // Get data from DAO with filter and sort
        List<Reservation> reservations = reservationDAO.getReservationsByUserIdWithFeedbackFiltered(userId, filter, sort);
        List<Map<String, Object>> feedbackBookings = new ArrayList<>();

        for (Reservation r : reservations) {
            Map<String, Object> entry = new HashMap<>();
            entry.put("id", r.getId());
            entry.put("roomNumber", r.getRoomNumber());
            entry.put("checkIn", r.getCheckIn());
            entry.put("checkOut", r.getCheckOut());
            entry.put("status", r.getStatus());
            entry.put("createdAt", r.getCreatedAt()); // Add this for sorting

            // Use rating and comment from the reservation object
            int reservationRating = r.getRating();
            String reservationComment = r.getComment();
            if (reservationRating > 0) {
                entry.put("rating", reservationRating);
                entry.put("comment", reservationComment);
            } else {
                entry.put("rating", 0);
                entry.put("comment", "");
            }
            feedbackBookings.add(entry);
        }
        
        // Manual sorting if DAO doesn't handle it properly
        switch (sort) {
            case "date_desc":
                feedbackBookings.sort((a, b) -> {
                    java.sql.Timestamp dateA = (java.sql.Timestamp) a.get("createdDate");
                    java.sql.Timestamp dateB = (java.sql.Timestamp) b.get("createdDate");
                    if (dateA == null && dateB == null) return 0;
                    if (dateA == null) return 1;
                    if (dateB == null) return -1;
                    return dateB.compareTo(dateA); // Descending
                });
                break;
            case "date_asc":
                feedbackBookings.sort((a, b) -> {
                    java.sql.Timestamp dateA = (java.sql.Timestamp) a.get("createdDate");
                    java.sql.Timestamp dateB = (java.sql.Timestamp) b.get("createdDate");
                    if (dateA == null && dateB == null) return 0;
                    if (dateA == null) return 1;
                    if (dateB == null) return -1;
                    return dateA.compareTo(dateB); // Ascending
                });
                break;
            case "rating_desc":
                feedbackBookings.sort((a, b) -> {
                    Integer ratingA = (Integer) a.get("rating");
                    Integer ratingB = (Integer) b.get("rating");
                    return ratingB.compareTo(ratingA); // Descending
                });
                break;
            case "rating_asc":
                feedbackBookings.sort((a, b) -> {
                    Integer ratingA = (Integer) a.get("rating");
                    Integer ratingB = (Integer) b.get("rating");
                    return ratingA.compareTo(ratingB); // Ascending
                });
                break;
            case "room_asc":
                feedbackBookings.sort((a, b) -> {
                    String roomA = (String) a.get("roomNumber");
                    String roomB = (String) b.get("roomNumber");
                    if (roomA == null && roomB == null) return 0;
                    if (roomA == null) return 1;
                    if (roomB == null) return -1;
                    return roomA.compareTo(roomB);
                });
                break;
            case "room_desc":
                feedbackBookings.sort((a, b) -> {
                    String roomA = (String) a.get("roomNumber");
                    String roomB = (String) b.get("roomNumber");
                    if (roomA == null && roomB == null) return 0;
                    if (roomA == null) return 1;
                    if (roomB == null) return -1;
                    return roomB.compareTo(roomA);
                });
                break;
            default:
                // Default to date descending
                feedbackBookings.sort((a, b) -> {
                    java.sql.Timestamp dateA = (java.sql.Timestamp) a.get("createdDate");
                    java.sql.Timestamp dateB = (java.sql.Timestamp) b.get("createdDate");
                    if (dateA == null && dateB == null) return 0;
                    if (dateA == null) return 1;
                    if (dateB == null) return -1;
                    return dateB.compareTo(dateA);
                });
                break;
        }
        
        // Set attributes for JSP
        request.setAttribute("feedbackBookings", feedbackBookings);
        request.setAttribute("currentFilter", filter);
        request.setAttribute("currentSort", sort);
        
        // Lấy tất cả feedbackId của user, truy vấn replies cho từng feedbackId
        ContactMessageDAO contactMessageDAO = new ContactMessageDAO();
        Map<String, List<ContactMessage>> feedbackReplies = new HashMap<>();
        for (Map<String, Object> entry : feedbackBookings) {
            int feedbackId = (int) entry.get("id");
            List<ContactMessage> replies = contactMessageDAO.getMessagesByFeedbackId(feedbackId);
            feedbackReplies.put(String.valueOf(feedbackId), replies);
        }
        String feedbackRepliesJson = new Gson().toJson(feedbackReplies);
        request.setAttribute("feedbackRepliesJson", feedbackRepliesJson);

        request.getRequestDispatcher("/jsp/customer/your-feedback.jsp").forward(request, response);
        
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("error", "Error loading feedback: " + e.getMessage());
        request.getRequestDispatcher("/jsp/customer/your-feedback.jsp").forward(request, response);
    }
}
    
    /**
     * Hiển thị form edit feedback
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        try {
            String feedbackIdStr = request.getParameter("id");
            
            if (feedbackIdStr == null || feedbackIdStr.trim().isEmpty()) {
                request.setAttribute("error", "Feedback ID is required.");
                listUserFeedback(request, response, user);
                return;
            }
            
            int feedbackId = Integer.parseInt(feedbackIdStr);
            Feedback feedback = feedbackDAO.getFeedbackById(feedbackId);
            
            if (feedback == null || feedback.getUserId() != user.getId()) {
                request.setAttribute("error", "Feedback not found or you don't have permission to edit it.");
                listUserFeedback(request, response, user);
                return;
            }
            
            request.setAttribute("feedback", feedback);
            request.getRequestDispatcher("/jsp/customer/edit-feedback.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid feedback ID format.");
            listUserFeedback(request, response, user);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading feedback: " + e.getMessage());
            listUserFeedback(request, response, user);
        }
    }
    
    /**
     * Cập nhật feedback
     */
    private void updateFeedback(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        try {
            String feedbackIdStr = request.getParameter("id");
            String ratingStr = request.getParameter("rating");
            String comment = request.getParameter("comment");
            
            if (feedbackIdStr == null || feedbackIdStr.trim().isEmpty()) {
                request.setAttribute("error", "Feedback ID is required.");
                listUserFeedback(request, response, user);
                return;
            }
            
            int feedbackId = Integer.parseInt(feedbackIdStr);
            int rating = Integer.parseInt(ratingStr);
            
            // Validate
            if (rating < 1 || rating > 5) {
                request.setAttribute("error", "Rating must be between 1 and 5.");
                showEditForm(request, response, user);
                return;
            }
            
            if (comment == null || comment.trim().isEmpty()) {
                request.setAttribute("error", "Comment is required.");
                showEditForm(request, response, user);
                return;
            }
            
            // Kiểm tra feedback tồn tại và thuộc về user
            Feedback existingFeedback = feedbackDAO.getFeedbackById(feedbackId);
            if (existingFeedback == null || existingFeedback.getUserId() != user.getId()) {
                request.setAttribute("error", "Feedback not found or you don't have permission to edit it.");
                listUserFeedback(request, response, user);
                return;
            }
            
            // Cập nhật feedback
            existingFeedback.setRating(rating);
            existingFeedback.setComment(comment.trim());
            
            boolean success = feedbackDAO.updateFeedback(existingFeedback);
            
            if (success) {
                request.setAttribute("success", "Feedback updated successfully.");
                response.sendRedirect(request.getContextPath() + "/customer/feedback?action=list&success=updated");
                return;
            } else {
                request.setAttribute("error", "Failed to update feedback. Please try again.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid input format.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while updating feedback: " + e.getMessage());
        }
        
        showEditForm(request, response, user);
    }
    
    /**
     * Xóa feedback
     */
    private void deleteFeedback(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        try {
            String feedbackIdStr = request.getParameter("id");
            
            if (feedbackIdStr == null || feedbackIdStr.trim().isEmpty()) {
                request.setAttribute("error", "Feedback ID is required.");
                listUserFeedback(request, response, user);
                return;
            }
            
            int feedbackId = Integer.parseInt(feedbackIdStr);
            
            // Kiểm tra feedback tồn tại và thuộc về user
            Feedback feedback = feedbackDAO.getFeedbackById(feedbackId);
            if (feedback == null || feedback.getUserId() != user.getId()) {
                request.setAttribute("error", "Feedback not found or you don't have permission to delete it.");
                listUserFeedback(request, response, user);
                return;
            }
            
            boolean success = feedbackDAO.deleteFeedback(feedbackId);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/customer/feedback?action=list&success=deleted");
                return;
            } else {
                request.setAttribute("error", "Failed to delete feedback. Please try again.");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid feedback ID format.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred while deleting feedback: " + e.getMessage());
        }
        
        listUserFeedback(request, response, user);
    }
    
    // ==================== RECEPTIONIST METHODS ====================
    
    /**
     * Xử lý request từ receptionist
     */
    private void handleReceptionistRequest(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                listAllFeedbacks(request, response);
                break;
            case "view":
                viewFeedbackDetail(request, response);
                break;
            case "contact":
                showContactForm(request, response);
                break;
            default:
                listAllFeedbacks(request, response);
                break;
        }
    }
    
    /**
     * Hiển thị danh sách tất cả feedback cho receptionist
     */
    private void listAllFeedbacks(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            String ratingFilter = request.getParameter("rating");
            String dateFilter = request.getParameter("date");
            String statusFilter = request.getParameter("status");
            List<Feedback> feedbacks = feedbackDAO.getAllFeedbacksWithDetails();
            // Lọc theo rating
            if (ratingFilter != null && !ratingFilter.isEmpty()) {
                try {
                    int rating = Integer.parseInt(ratingFilter);
                    feedbacks = feedbacks.stream()
                        .filter(f -> f.getRating() == rating)
                        .collect(java.util.stream.Collectors.toList());
                } catch (NumberFormatException e) {
                    // Bỏ qua nếu rating không hợp lệ
                }
            }
            // Lọc theo ngày
            if (dateFilter != null && !dateFilter.isEmpty()) {
                try {
                    java.sql.Date filterDate = java.sql.Date.valueOf(dateFilter);
                    feedbacks = feedbacks.stream()
                        .filter(f -> f.getCreatedAt() != null && 
                                     f.getCreatedAt().toLocalDateTime().toLocalDate().isEqual(filterDate.toLocalDate()))
                        .collect(java.util.stream.Collectors.toList());
                } catch (Exception e) {
                    // Bỏ qua nếu date không hợp lệ
                }
            }
            // Lọc theo status (new, replied)
            if (statusFilter != null && !statusFilter.isEmpty()) {
                List<ContactMessage> allReplies = new dal.ContactMessageDAO().getAllMessages();
                java.util.Set<Integer> feedbacksWithReply = allReplies.stream()
                    .filter(msg -> msg.getFeedbackId() != null)
                    .map(model.ContactMessage::getFeedbackId)
                    .collect(java.util.stream.Collectors.toSet());
                if ("new".equals(statusFilter)) {
                    feedbacks = feedbacks.stream()
                        .filter(f -> !feedbacksWithReply.contains(f.getId()))
                        .collect(java.util.stream.Collectors.toList());
                } else if ("replied".equals(statusFilter)) {
                    feedbacks = feedbacks.stream()
                        .filter(f -> feedbacksWithReply.contains(f.getId()))
                        .collect(java.util.stream.Collectors.toList());
                }
            }
            
            // Calculate statistics
            int totalFeedbacks = feedbacks.size();
            double averageRating = 0;
            int recentFeedbacks = 0;
            int pendingReplies = 0;
            
            if (!feedbacks.isEmpty()) {
                // Calculate average rating
                double totalRating = feedbacks.stream()
                    .mapToInt(f -> f.getRating())
                    .sum();
                averageRating = Math.round((totalRating / totalFeedbacks) * 10.0) / 10.0;
                
                // Calculate recent feedbacks (last 7 days)
                long sevenDaysAgo = System.currentTimeMillis() - (7 * 24 * 60 * 60 * 1000L);
                recentFeedbacks = (int) feedbacks.stream()
                    .filter(f -> f.getCreatedAt() != null && f.getCreatedAt().getTime() > sevenDaysAgo)
                    .count();
                
                // For now, assume all feedbacks need replies (you can modify this logic)
                pendingReplies = totalFeedbacks;
            }
            
            request.setAttribute("feedbacks", feedbacks);
            request.setAttribute("totalFeedbacks", totalFeedbacks);
            request.setAttribute("averageRating", averageRating);
            request.setAttribute("recentFeedbacks", recentFeedbacks);
            request.setAttribute("pendingReplies", pendingReplies);
            request.setAttribute("activePage", "feedback");
            request.setAttribute("contentPage", "feedback-content.jsp");
            
            // Lấy tất cả feedbackId của user, truy vấn replies cho từng feedbackId
            ContactMessageDAO contactMessageDAO2 = new ContactMessageDAO();
            Map<String, List<ContactMessage>> feedbackRepliesReception = new HashMap<>();
            for (Feedback f : feedbacks) {
                List<ContactMessage> replies = contactMessageDAO2.getMessagesByFeedbackId(f.getId());
                feedbackRepliesReception.put(String.valueOf(f.getId()), replies);
            }
            String feedbackRepliesJsonReception = new Gson().toJson(feedbackRepliesReception);
            request.setAttribute("feedbackRepliesJson", feedbackRepliesJsonReception);

            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading feedbacks: " + e.getMessage());
            request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị chi tiết feedback (không cần thiết nữa vì dùng modal)
     */
    private void viewFeedbackDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String feedbackIdStr = request.getParameter("id");
        if (feedbackIdStr == null || feedbackIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/receptionist/feedback");
            return;
        }
        int feedbackId = Integer.parseInt(feedbackIdStr);

        // Lấy chi tiết feedback
        Feedback feedback = feedbackDAO.getFeedbackById(feedbackId);
        // Lấy các reply liên quan
        List<ContactMessage> replies = getRepliesForFeedback(feedbackId);

        request.setAttribute("feedback", feedback);
        request.setAttribute("replies", replies);
        request.setAttribute("activePage", "feedback");
        request.setAttribute("contentPage", "feedback-detail.jsp");

        request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
    }
    
    /**
     * Hiển thị form contact (không cần thiết nữa vì dùng modal)
     */
    private void showContactForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect to main feedback page since we use modal now
        response.sendRedirect(request.getContextPath() + "/receptionist/feedback");
    }
    
    /**
     * Xử lý POST request từ receptionist
     */
    private void handleReceptionistPostRequest(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/receptionist/feedback");
            return;
        }
        switch (action) {
            case "sendMessage":
                sendContactMessage(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/receptionist/feedback");
                break;
        }
    }
    
    /**
     * Gửi tin nhắn contact
     */
    private void sendContactMessage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        System.out.println("=== FEEDBACK CONTROLLER CALLED ===");
        System.out.println("=== REQUEST URI: " + request.getRequestURI());
        System.out.println("=== SERVLET PATH: " + request.getServletPath());
        System.out.println("=== QUERY STRING: " + request.getQueryString());
        System.out.println("=== POST PARAMS ===");
        System.out.println("customerEmail: " + request.getParameter("customerEmail"));
        System.out.println("customerName: " + request.getParameter("customerName"));
        System.out.println("subject: " + request.getParameter("subject"));
        System.out.println("message: " + request.getParameter("message"));
        System.out.println("feedbackId: " + request.getParameter("feedbackId"));
        try {
            String customerEmail = request.getParameter("customerEmail");
            String customerName = request.getParameter("customerName");
            String subject = request.getParameter("subject");
            String message = request.getParameter("message");
            String feedbackIdStr = request.getParameter("feedbackId");
            Integer feedbackId = null;
            if (feedbackIdStr != null && !feedbackIdStr.trim().isEmpty()) {
                try {
                    feedbackId = Integer.parseInt(feedbackIdStr);
                } catch (NumberFormatException ex) {
                    feedbackId = null;
                }
            }

            if (customerEmail == null || customerEmail.trim().isEmpty() ||
                subject == null || subject.trim().isEmpty() ||
                message == null || message.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Missing required fields");
                return;
            }

            ContactMessageDAO contactDAO = new ContactMessageDAO();
            ContactMessage contactMsg = new ContactMessage();
            contactMsg.setName("Hotel Staff");
            contactMsg.setEmail("staff@luxuryhotel.com");
            contactMsg.setPhone("(+84) 3 1234 5678");
            contactMsg.setMessage("Subject: " + subject + "\n\nMessage: " + message + "\n\nRelated to Feedback ID: " + feedbackId);
            contactMsg.setFeedbackId(feedbackId);

            System.out.println("[DEBUG] Trước khi gọi contactDAO.addMessage");
            boolean result = contactDAO.addMessage(contactMsg);
            System.out.println("[DEBUG] Sau khi gọi contactDAO.addMessage, result = " + result);

            if (result) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("Message sent successfully");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("Failed to send message");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("An error occurred: " + e.getMessage());
        }
    }

    // Thêm chức năng lấy reply cho feedback (cho admin)
    private List<ContactMessage> getRepliesForFeedback(int feedbackId) {
        ContactMessageDAO contactDAO = new ContactMessageDAO();
        return contactDAO.getMessagesByFeedbackId(feedbackId);
    }

    // Thêm chức năng ẩn/hiện feedback (cho admin)
    private void setFeedbackDisabled(int feedbackId, boolean disabled) {
        FeedbackDAO feedbackDAO = new FeedbackDAO();
        feedbackDAO.setFeedbackDisabled(feedbackId, disabled);
    }
    
    // ==================== ADMIN METHODS ====================
    
    /**
     * Xử lý request từ admin
     */
    private void handleAdminRequest(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        switch (action) {
            case "disable":
                setFeedbackDisabled(request, response, true);
                break;
            case "enable":
                setFeedbackDisabled(request, response, false);
                break;
            case "list":
                listAllFeedbacksForAdmin(request, response);
                break;
            case "view":
                viewFeedbackDetailForAdmin(request, response);
                break;
            default:
                listAllFeedbacksForAdmin(request, response);
                break;
        }
    }

    private void setFeedbackDisabled(HttpServletRequest request, HttpServletResponse response, boolean disabled)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            int id = Integer.parseInt(idStr);
            feedbackDAO.setFeedbackDisabled(id, disabled);
        }
        response.sendRedirect(request.getContextPath() + "/admin/feedback");
    }
    
    /**
     * Hiển thị danh sách tất cả feedback cho admin
     */
    private void listAllFeedbacksForAdmin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Get filter parameters
            String statusFilter = request.getParameter("status");
            String ratingFilter = request.getParameter("rating");
            String dateFrom = request.getParameter("dateFrom");
            
            // Get all feedbacks with details
            List<Feedback> feedbacks = feedbackDAO.getAllFeedbacksWithDetails();
            
            // Map feedbackId -> replies
            Map<String, List<ContactMessage>> feedbackReplies = new HashMap<>();
            ContactMessageDAO contactMessageDAO = new ContactMessageDAO();
            for (Feedback f : feedbacks) {
                List<ContactMessage> replies = contactMessageDAO.getMessagesByFeedbackId(f.getId());
                feedbackReplies.put(String.valueOf(f.getId()), replies);
            }
            String feedbackRepliesJson = new Gson().toJson(feedbackReplies);
            request.setAttribute("feedbackRepliesJson", feedbackRepliesJson);
            
            // Apply filters
            if (statusFilter != null && !statusFilter.isEmpty()) {
                if ("active".equals(statusFilter)) {
                    feedbacks = feedbacks.stream()
                        .filter(f -> !f.isDisabled())
                        .collect(java.util.stream.Collectors.toList());
                } else if ("disabled".equals(statusFilter)) {
                    feedbacks = feedbacks.stream()
                        .filter(f -> f.isDisabled())
                        .collect(java.util.stream.Collectors.toList());
                }
            }
            
            if (ratingFilter != null && !ratingFilter.isEmpty()) {
                int rating = Integer.parseInt(ratingFilter);
                feedbacks = feedbacks.stream()
                    .filter(f -> f.getRating() == rating)
                    .collect(java.util.stream.Collectors.toList());
            }
            
            if (dateFrom != null && !dateFrom.isEmpty()) {
                java.sql.Date fromDate = java.sql.Date.valueOf(dateFrom);
                feedbacks = feedbacks.stream()
                    .filter(f -> f.getCreatedAt() != null && 
                               f.getCreatedAt().toLocalDateTime().toLocalDate().isAfter(fromDate.toLocalDate()))
                    .collect(java.util.stream.Collectors.toList());
            }
            
            // Calculate statistics
            int totalFeedbacks = feedbacks.size();
            double averageRating = 0;
            int activeFeedbacks = totalFeedbacks; // All feedbacks are active
            int disabledFeedbacks = 0; // No disabled feedbacks
            
            if (!feedbacks.isEmpty()) {
                // Calculate average rating
                double totalRating = feedbacks.stream()
                    .mapToInt(f -> f.getRating())
                    .sum();
                averageRating = Math.round((totalRating / totalFeedbacks) * 10.0) / 10.0;
            }
            
            // Set attributes
            request.setAttribute("feedbacks", feedbacks);
            request.setAttribute("totalFeedbacks", totalFeedbacks);
            request.setAttribute("activeFeedbacks", activeFeedbacks);
            request.setAttribute("disabledFeedbacks", disabledFeedbacks);
            request.setAttribute("averageRating", averageRating);
            request.setAttribute("activePage", "feedback");
            request.setAttribute("contentPage", "admin-feedback-content.jsp");
            request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading feedbacks: " + e.getMessage());
            request.getRequestDispatcher("/jsp/admin/admin-layout.jsp").forward(request, response);
        }
    }
    
    /**
     * Hiển thị chi tiết feedback cho admin (không cần thiết nữa vì dùng modal)
     */
    private void viewFeedbackDetailForAdmin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Redirect to main feedback page since we use modal now
        response.sendRedirect(request.getContextPath() + "/admin/feedback");
    }
    
    /**
     * Xử lý POST request từ admin
     */
    private void handleAdminPostRequest(HttpServletRequest request, HttpServletResponse response, User user) 
            throws ServletException, IOException {
        
        // No POST actions needed since enable/disable is not implemented
        response.setStatus(HttpServletResponse.SC_OK);
        response.getWriter().write("No actions available");
    }
}



