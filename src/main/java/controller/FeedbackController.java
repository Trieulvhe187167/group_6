package controller;

import dal.FeedbackDAO;
import dal.ReservationDAO;
import model.Feedback;
import model.Reservation;
import model.User;
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

@WebServlet(urlPatterns = {"/customer/feedback", "/customer/feedback/*", "/customer/your-feedback"})

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
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
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

            request.setAttribute("reservations", completedReservations);
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
}

