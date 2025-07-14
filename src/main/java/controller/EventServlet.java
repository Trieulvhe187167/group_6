package controller;

import dal.EventDAO;
import model.Event;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;

@WebServlet(name = "EventServlet", urlPatterns = {"/events", "/event/*"})
public class EventServlet extends HttpServlet {
    
    private EventDAO eventDAO = new EventDAO();
    private static final int RECORDS_PER_PAGE = 3;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        String action = request.getParameter("action");
        
        try {
            // Auto-update event statuses for all actions
            eventDAO.autoUpdateEventStatuses();
            
            // Route based on path or action
            if (pathInfo != null && pathInfo.startsWith("/detail/")) {
                // Event detail: /event/detail/123
                handleEventDetail(request, response, pathInfo);
            } else if ("search".equals(action)) {
                // Search events: /events?action=search&q=keyword
                handleEventSearch(request, response);
            } else {
                // List events: /events or /events?status=upcoming
                handleEventList(request, response);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing request");
        }
    }
    
    /**
     * Handle event list display
     */
    private void handleEventList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get filter parameters
        String statusFilter = request.getParameter("status");
        String searchQuery = request.getParameter("q");
        int page = 1;
        
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        // Get all events
        List<Event> allEvents = eventDAO.getAllEvents();
        
        // Apply filters
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("all")) {
            allEvents = filterByStatus(allEvents, statusFilter);
        }
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            allEvents = searchEvents(allEvents, searchQuery);
        }
        
        // Sort events
        allEvents = sortEvents(allEvents);
        
        // Pagination
        int totalRecords = allEvents.size();
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;
        
        int start = (page - 1) * RECORDS_PER_PAGE;
        int end = Math.min(start + RECORDS_PER_PAGE, totalRecords);
        
        List<Event> events = totalRecords > 0 ? allEvents.subList(start, end) : new ArrayList<>();
        
        // Set attributes
        request.setAttribute("events", events);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("searchQuery", searchQuery);
        
        // Forward to JSP
        request.getRequestDispatcher("/jsp/events.jsp").forward(request, response);
    }
    
    /**
     * Handle event detail display
     */
    private void handleEventDetail(HttpServletRequest request, HttpServletResponse response, String pathInfo)
            throws ServletException, IOException {
        
        // Extract ID from path: /detail/123
        String idStr = pathInfo.substring("/detail/".length());
        
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/events");
            return;
        }
        
        try {
            int eventId = Integer.parseInt(idStr);
            
            // Get event details
            Event event = eventDAO.getEventById(eventId);
            
            if (event == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Event not found");
                return;
            }
            
            // Get other events
            List<Event> allEvents = eventDAO.getAllEvents();
            List<Event> otherEvents = getOtherEvents(allEvents, eventId);
            
            // Set attributes
            request.setAttribute("event", event);
            request.setAttribute("otherEvents", otherEvents);
            
            // Forward to JSP
            request.getRequestDispatcher("/jsp/eventDetail.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid event ID");
        }
    }
    
    /**
     * Handle event search
     */
    private void handleEventSearch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String searchQuery = request.getParameter("q");
        
        if (searchQuery == null || searchQuery.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/events");
            return;
        }
        
        int page = 1;
        
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        // Search events
        List<Event> allEvents = eventDAO.getAllEvents();
        List<Event> searchResults = searchEvents(allEvents, searchQuery);
        
        // Sort results
        searchResults = sortEventsByRelevance(searchResults);
        
        // Pagination
        int totalRecords = searchResults.size();
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;
        
        int start = (page - 1) * RECORDS_PER_PAGE;
        int end = Math.min(start + RECORDS_PER_PAGE, totalRecords);
        
        List<Event> events = totalRecords > 0 ? searchResults.subList(start, end) : new ArrayList<>();
        
        // Set attributes
        request.setAttribute("events", events);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("searchQuery", searchQuery);
        request.setAttribute("isSearchMode", true);
        
        // Forward to events.jsp
        request.getRequestDispatcher("/jsp/events.jsp").forward(request, response);
    }
    
    /**
     * Filter events by status
     */
    private List<Event> filterByStatus(List<Event> events, String statusFilter) {
        java.util.Date now = new java.util.Date();
        
        return events.stream().filter(event -> {
            switch (statusFilter) {
                case "upcoming":
                    return "SCHEDULED".equals(event.getStatus()) && event.getStartAt().after(now);
                case "ongoing":
                    return "ONGOING".equals(event.getStatus()) || 
                           ("SCHEDULED".equals(event.getStatus()) && 
                            event.getStartAt().before(now) && event.getEndAt().after(now));
                case "past":
                    return "COMPLETED".equals(event.getStatus()) || 
                           event.getEndAt().before(now);
                default:
                    return true;
            }
        }).collect(Collectors.toList());
    }
    
    /**
     * Search events by query
     */
    private List<Event> searchEvents(List<Event> events, String query) {
        String lowerQuery = query.toLowerCase().trim();
        String[] keywords = lowerQuery.split("\\s+");
        
        return events.stream().filter(event -> {
            String searchableText = "";
            if (event.getTitle() != null) searchableText += event.getTitle().toLowerCase() + " ";
            if (event.getLocation() != null) searchableText += event.getLocation().toLowerCase() + " ";
            if (event.getDescription() != null) searchableText += event.getDescription().toLowerCase();
            
            for (String keyword : keywords) {
                if (!searchableText.contains(keyword)) {
                    return false;
                }
            }
            return true;
        }).collect(Collectors.toList());
    }
    
    /**
     * Sort events by date and status
     */
    private List<Event> sortEvents(List<Event> events) {
        java.util.Date now = new java.util.Date();
        
        List<Event> ongoing = new ArrayList<>();
        List<Event> upcoming = new ArrayList<>();
        List<Event> past = new ArrayList<>();
        
        for (Event event : events) {
            if ("ONGOING".equals(event.getStatus()) || 
                ("SCHEDULED".equals(event.getStatus()) && 
                 event.getStartAt().before(now) && event.getEndAt().after(now))) {
                ongoing.add(event);
            } else if ("SCHEDULED".equals(event.getStatus()) && event.getStartAt().after(now)) {
                upcoming.add(event);
            } else {
                past.add(event);
            }
        }
        
        ongoing.sort((e1, e2) -> e1.getStartAt().compareTo(e2.getStartAt()));
        upcoming.sort((e1, e2) -> e1.getStartAt().compareTo(e2.getStartAt()));
        past.sort((e1, e2) -> e2.getStartAt().compareTo(e1.getStartAt()));
        
        List<Event> sorted = new ArrayList<>();
        sorted.addAll(ongoing);
        sorted.addAll(upcoming);
        sorted.addAll(past);
        
        return sorted;
    }
    
    /**
     * Sort events by relevance for search results
     */
    private List<Event> sortEventsByRelevance(List<Event> events) {
        java.util.Date now = new java.util.Date();
        
        return events.stream().sorted((e1, e2) -> {
            int status1 = getStatusPriority(e1, now);
            int status2 = getStatusPriority(e2, now);
            
            if (status1 != status2) {
                return status2 - status1;
            }
            
            if (e1.getStartAt().after(now) && e2.getStartAt().after(now)) {
                return e1.getStartAt().compareTo(e2.getStartAt());
            } else if (e1.getStartAt().before(now) && e2.getStartAt().before(now)) {
                return e2.getStartAt().compareTo(e1.getStartAt());
            }
            
            return 0;
        }).collect(Collectors.toList());
    }
    
    /**
     * Get status priority for sorting
     */
    private int getStatusPriority(Event event, java.util.Date now) {
        if ("CANCELLED".equals(event.getStatus())) {
            return 0;
        }
        
        if ("ONGOING".equals(event.getStatus()) || 
            ("SCHEDULED".equals(event.getStatus()) && 
             event.getStartAt().before(now) && event.getEndAt().after(now))) {
            return 3;
        }
        
        if ("SCHEDULED".equals(event.getStatus()) && event.getStartAt().after(now)) {
            return 2;
        }
        
        return 1;
    }
    
    /**
     * Get other events for sidebar
     */
    private List<Event> getOtherEvents(List<Event> allEvents, int currentEventId) {
        java.util.Date now = new java.util.Date();
        
        List<Event> otherEvents = allEvents.stream()
            .filter(e -> e.getId() != currentEventId)
            .filter(e -> !"CANCELLED".equals(e.getStatus()))
            .filter(e -> !"COMPLETED".equals(e.getStatus()) || e.getEndAt().after(now))
            .collect(Collectors.toList());
        
        otherEvents.sort((e1, e2) -> {
            boolean e1Future = e1.getStartAt().after(now);
            boolean e2Future = e2.getStartAt().after(now);
            
            if (e1Future && !e2Future) return -1;
            if (!e1Future && e2Future) return 1;
            
            return e1.getStartAt().compareTo(e2.getStartAt());
        });
        
        return otherEvents.size() > 5 ? otherEvents.subList(0, 5) : otherEvents;
    }
}