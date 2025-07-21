package controller;

import dal.EventDAO;
import dal.UserDAO;
import model.Event;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.File;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.List;
import java.util.ArrayList;
import java.util.UUID;

@WebServlet(name = "AdminEventServlet", urlPatterns = {"/admin/events"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 5, // 5MB
        maxRequestSize = 1024 * 1024 * 10 // 10MB
)
public class AdminEventServlet extends HttpServlet {

    private EventDAO eventDAO = new EventDAO();
    private UserDAO userDAO = new UserDAO();
    private static final int RECORDS_PER_PAGE = 2;
    private static final String UPLOAD_DIR = "assets" + File.separator + "images" + File.separator + "uploads" + File.separator + "events";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || (!"ADMIN".equals(currentUser.getRole())
                && !"RECEPTIONIST".equals(currentUser.getRole()))) {
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
                    listEvents(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "view":
                    viewEventDetail(request, response);
                    break;
                default:
                    listEvents(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            listEvents(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || (!"ADMIN".equals(currentUser.getRole())
                && !"RECEPTIONIST".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        try {
            switch (action) {
                case "create":
                    createEvent(request, response, currentUser);
                    break;
                case "update":
                    updateEvent(request, response);
                    break;
                case "delete":
                    deleteEvent(request, response);
                    break;
                case "cancel":
                    cancelEvent(request, response);
                    break;
                case "complete":
                    completeEvent(request, response);
                    break;
                default:
                    response.sendRedirect("events");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "An error occurred: " + e.getMessage());
            response.sendRedirect("events");
        }
        String startAtStr = request.getParameter("startAt");
        String endAtStr = request.getParameter("endAt");

        if (startAtStr != null && endAtStr != null) {
            LocalDateTime startAt = LocalDateTime.parse(startAtStr);
            LocalDateTime endAt = LocalDateTime.parse(endAtStr);
            LocalDateTime now = LocalDateTime.now();

            if (startAt.isBefore(now) || endAt.isBefore(now)) {
                request.setAttribute("error", "Start and end dates cannot be in the past.");
                request.getRequestDispatcher("admin-event-form.jsp").forward(request, response);
                return;
            }
            if (endAt.isBefore(startAt)) {
                request.setAttribute("error", "The end date must be after or equal to the start date.");
                request.getRequestDispatcher("admin-event-form.jsp").forward(request, response);
                return;
            }
        }
    }

    private void listEvents(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String location = request.getParameter("location");
        String dateRange = request.getParameter("dateRange");
        int page = 1;

        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        // Auto-update event statuses based on current time
        eventDAO.autoUpdateEventStatuses();

        // Get all events with filters
        List<Event> allEvents = eventDAO.getAllEventsWithFilters(search, status, location, dateRange);

        // Calculate pagination
        int totalRecords = allEvents.size();
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);

        if (page < 1) {
            page = 1;
        }
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }

        int start = (page - 1) * RECORDS_PER_PAGE;
        int end = Math.min(start + RECORDS_PER_PAGE, totalRecords);

        List<Event> events = totalRecords > 0 ? allEvents.subList(start, end) : new ArrayList<>();

        // Get statistics
        int totalEvents = eventDAO.getTotalEvents();
        int upcomingCount = eventDAO.getUpcomingEventsCount();
        int ongoingCount = eventDAO.getOngoingEventsCount();
        int completedCount = eventDAO.getCompletedEventsCount();

        // Get unique locations for filter
        List<String> locations = eventDAO.getUniqueLocations();

        request.setAttribute("events", events);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("location", location);
        request.setAttribute("dateRange", dateRange);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("recordsPerPage", RECORDS_PER_PAGE);
        request.setAttribute("totalEvents", totalEvents);
        request.setAttribute("upcomingCount", upcomingCount);
        request.setAttribute("ongoingCount", ongoingCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("locations", locations);

        // Set page info
        request.setAttribute("pageTitle", "Event Management");
        request.setAttribute("activePage", "events");
        request.setAttribute("contentPage", "/jsp/admin/admin-events-content.jsp");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("isEdit", false);
        request.setAttribute("pageTitle", "Add New Event");
        request.setAttribute("activePage", "events");
        request.setAttribute("contentPage", "/jsp/admin/admin-event-form.jsp");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("events");
            return;
        }

        Event event = eventDAO.getEventById(Integer.parseInt(idStr));
        if (event == null) {
            request.getSession().setAttribute("error", "Event not found");
            response.sendRedirect("events");
            return;
        }

        request.setAttribute("event", event);
        request.setAttribute("isEdit", true);
        request.setAttribute("pageTitle", "Edit Event");
        request.setAttribute("activePage", "events");
        request.setAttribute("contentPage", "/jsp/admin/admin-event-form.jsp");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void viewEventDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("events");
            return;
        }

        Event event = eventDAO.getEventById(Integer.parseInt(idStr));
        if (event == null) {
            request.getSession().setAttribute("error", "Event not found");
            response.sendRedirect("events");
            return;
        }

        // Get event registrations/attendees if needed
        // int attendeeCount = eventDAO.getEventAttendeeCount(event.getId());
        request.setAttribute("event", event);
        // request.setAttribute("attendeeCount", attendeeCount);
        request.setAttribute("pageTitle", "Event Details - " + event.getTitle());
        request.setAttribute("activePage", "events");
        request.setAttribute("contentPage", "/jsp/admin/admin-event-detail.jsp");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void createEvent(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String location = request.getParameter("location");
        String startAtStr = request.getParameter("startAt");
        String endAtStr = request.getParameter("endAt");
        String status = request.getParameter("status");

        // Validate required fields
        if (title == null || title.trim().isEmpty()
                || startAtStr == null || startAtStr.trim().isEmpty()
                || endAtStr == null || endAtStr.trim().isEmpty()) {
            request.setAttribute("error", "Title, start time, and end time are required");
            showAddForm(request, response);
            return;
        }

        try {
            // Parse datetime strings to Timestamp
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Timestamp startAt = new Timestamp(dateFormat.parse(startAtStr).getTime());
            Timestamp endAt = new Timestamp(dateFormat.parse(endAtStr).getTime());

            // Validate datetime
            if (endAt.before(startAt)) {
                request.setAttribute("error", "End time must be after start time");
                showAddForm(request, response);
                return;
            }

            // Handle file upload
            String imageUrl = handleFileUpload(request);

            // Create event object
            Event event = new Event();
            event.setTitle(title.trim());
            event.setDescription(description != null ? description.trim() : null);
            event.setLocation(location != null ? location.trim() : null);
            event.setStartAt(startAt);
            event.setEndAt(endAt);
            event.setStatus(status != null ? status : "SCHEDULED");
            event.setImageUrl(imageUrl);
            event.setCreatedBy(currentUser.getId());

            if (eventDAO.insertEvent(event)) {
                request.getSession().setAttribute("success", "Event created successfully");

                // Check if save and continue
                String saveAndContinue = request.getParameter("saveAndContinue");
                if ("true".equals(saveAndContinue)) {
                    // Get the created event ID and redirect to edit
                    Event createdEvent = eventDAO.getLatestEventByUser(currentUser.getId());
                    if (createdEvent != null) {
                        response.sendRedirect("events?action=edit&id=" + createdEvent.getId());
                    } else {
                        response.sendRedirect("events");
                    }
                } else {
                    response.sendRedirect("events");
                }
            } else {
                request.setAttribute("error", "Failed to create event");
                showAddForm(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid date format or system error");
            showAddForm(request, response);
        }
    }

    private void updateEvent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String location = request.getParameter("location");
        String startAtStr = request.getParameter("startAt");
        String endAtStr = request.getParameter("endAt");
        String status = request.getParameter("status");

        if (idStr == null) {
            response.sendRedirect("events");
            return;
        }

        // Validate required fields
        if (title == null || title.trim().isEmpty()
                || startAtStr == null || startAtStr.trim().isEmpty()
                || endAtStr == null || endAtStr.trim().isEmpty()) {
            request.setAttribute("error", "Title, start time, and end time are required");
            showEditForm(request, response);
            return;
        }

        try {
            // Get existing event
            Event event = eventDAO.getEventById(Integer.parseInt(idStr));
            if (event == null) {
                request.getSession().setAttribute("error", "Event not found");
                response.sendRedirect("events");
                return;
            }

            // Parse datetime strings to Timestamp
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Timestamp startAt = new Timestamp(dateFormat.parse(startAtStr).getTime());
            Timestamp endAt = new Timestamp(dateFormat.parse(endAtStr).getTime());

            // Validate datetime
            if (endAt.before(startAt)) {
                request.setAttribute("error", "End time must be after start time");
                request.setAttribute("event", event);
                showEditForm(request, response);
                return;
            }

            // Handle file upload
            String imageUrl = handleFileUpload(request);
            if (imageUrl != null) {
                event.setImageUrl(imageUrl);
            }

            // Update event object
            event.setTitle(title.trim());
            event.setDescription(description != null ? description.trim() : null);
            event.setLocation(location != null ? location.trim() : null);
            event.setStartAt(startAt);
            event.setEndAt(endAt);
            event.setStatus(status);

            if (eventDAO.updateEvent(event)) {
                request.getSession().setAttribute("success", "Event updated successfully");

                // Check if save and continue
                String saveAndContinue = request.getParameter("saveAndContinue");
                if ("true".equals(saveAndContinue)) {
                    response.sendRedirect("events?action=edit&id=" + idStr);
                } else {
                    response.sendRedirect("events");
                }
            } else {
                request.setAttribute("error", "Failed to update event");
                showEditForm(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid date format or system error");
            showEditForm(request, response);
        }
    }

    private void deleteEvent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("events");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            if (eventDAO.deleteEvent(id)) {
                request.getSession().setAttribute("success", "Event deleted successfully");
            } else {
                request.getSession().setAttribute("error", "Failed to delete event");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid event ID");
        }

        response.sendRedirect("events");
    }

    private void cancelEvent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("events");
            return;
        }

        Event event = eventDAO.getEventById(Integer.parseInt(idStr));
        if (event != null) {
            event.setStatus("CANCELLED");
            if (eventDAO.updateEvent(event)) {
                request.getSession().setAttribute("success", "Event cancelled successfully");
            } else {
                request.getSession().setAttribute("error", "Failed to cancel event");
            }
        }

        response.sendRedirect("events?action=view&id=" + idStr);
    }

    private void completeEvent(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("events");
            return;
        }

        Event event = eventDAO.getEventById(Integer.parseInt(idStr));
        if (event != null) {
            event.setStatus("COMPLETED");
            if (eventDAO.updateEvent(event)) {
                request.getSession().setAttribute("success", "Event marked as completed");
            } else {
                request.getSession().setAttribute("error", "Failed to complete event");
            }
        }

        response.sendRedirect("events?action=view&id=" + idStr);
    }

    private String handleFileUpload(HttpServletRequest request) throws IOException, ServletException {
        Part filePart = request.getPart("image");

        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        // Validate file type
        String contentType = filePart.getContentType();
        if (!contentType.startsWith("image/")) {
            throw new ServletException("Only image files are allowed");
        }

        // Generate unique filename
        String extension = fileName.substring(fileName.lastIndexOf("."));
        String uniqueFileName = UUID.randomUUID().toString() + extension;

        // Create upload directory if it doesn't exist
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        // Save file
        filePart.write(uploadPath + File.separator + uniqueFileName);

        return uniqueFileName;
    }
}
