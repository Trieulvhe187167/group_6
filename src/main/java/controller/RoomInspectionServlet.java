/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.*;
import model.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.*;
import java.math.BigDecimal;
import java.util.*;

@WebServlet("/inspector/inspection")
@MultipartConfig(maxFileSize = 16177215) // 16MB
public class RoomInspectionServlet extends HttpServlet {

    private RoomInspectionDAO inspectionDAO = new RoomInspectionDAO();
    private ReservationDAO reservationDAO = new ReservationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"ROOM_INSPECTOR".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("start".equals(action)) {
                showStartInspection(request, response);
            } else if ("view".equals(action)) {
                viewInspection(request, response);
            } else if ("edit".equals(action)) {
                editInspection(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/inspector/dashboard");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"ROOM_INSPECTOR".equals(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("create".equals(action)) {
                createInspection(request, response, user);
            } else if ("addItem".equals(action)) {
                addInspectionItem(request, response);
            } else if ("addDamage".equals(action)) {
                addRoomDamage(request, response);
            } else if ("deleteItem".equals(action)) {
                deleteInspectionItem(request, response);
            } else if ("deleteDamage".equals(action)) {
                deleteRoomDamage(request, response);
            } else if ("complete".equals(action)) {
                completeInspection(request, response);
            } else if ("saveProgress".equals(action)) {
                saveProgress(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"" + e.getMessage() + "\"}");
        }
    }

    private void showStartInspection(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, Exception {

        int reservationId = Integer.parseInt(request.getParameter("reservationId"));

        // Get reservation details
        Reservation reservation = reservationDAO.getReservationById(reservationId);
        if (reservation == null) {
            throw new Exception("Reservation not found");
        }

        // Check if inspection already exists
        RoomInspection existingInspection = inspectionDAO.getInspectionByReservationId(reservationId);
        if (existingInspection != null) {
            response.sendRedirect(request.getContextPath()
                    + "/inspector/inspection?action=edit&id=" + existingInspection.getId());
            return;
        }

        // Get room amenities
        List<RoomAmenity> amenities = inspectionDAO.getRoomAmenities(reservation.getRoomId());

        request.setAttribute("reservation", reservation);
        request.setAttribute("amenities", amenities);
        request.setAttribute("pageTitle", "Start Room Inspection");
        request.setAttribute("activePage", "inspection");
        request.setAttribute("contentPage", "/jsp/inspector/start-inspection.jsp");
        request.getRequestDispatcher("/jsp/inspector/inspector-template.jsp").forward(request, response);
    }

    private void createInspection(HttpServletRequest request, HttpServletResponse response, User inspector)
            throws Exception {

        int reservationId = Integer.parseInt(request.getParameter("reservationId"));
        String roomCondition = request.getParameter("roomCondition");
        int cleanlinessScore = Integer.parseInt(request.getParameter("cleanlinessScore"));
        String notes = request.getParameter("notes");

        RoomInspection inspection = new RoomInspection();
        inspection.setReservationId(reservationId);
        inspection.setInspectorId(inspector.getId());
        inspection.setRoomCondition(roomCondition);
        inspection.setCleanlinessScore(cleanlinessScore);
        inspection.setNotes(notes);

        int inspectionId = inspectionDAO.startInspection(inspection);

        response.sendRedirect(request.getContextPath()
                + "/inspector/inspection?action=edit&id=" + inspectionId);
    }

    private void editInspection(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, Exception {

        int inspectionId = Integer.parseInt(request.getParameter("id"));

        RoomInspection inspection = inspectionDAO.getInspectionById(inspectionId);
        if (inspection == null) {
            throw new Exception("Inspection not found");
        }

        // Get room amenities for adding items
        List<RoomAmenity> amenities = inspectionDAO.getRoomAmenities(inspection.getReservation().getRoomId());

        request.setAttribute("inspection", inspection);
        request.setAttribute("amenities", amenities);
        request.setAttribute("pageTitle", "Edit Inspection - Room " + inspection.getReservation().getRoomNumber());

        request.setAttribute("activePage", "inspection");
        request.setAttribute("contentPage", "/jsp/inspector/edit-inspection.jsp");
        request.getRequestDispatcher("/jsp/inspector/inspector-template.jsp").forward(request, response);
    }

    private void addInspectionItem(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        int inspectionId = Integer.parseInt(request.getParameter("inspectionId"));
        String itemName = request.getParameter("itemName");
        String itemCategory = request.getParameter("itemCategory");
        int quantity = Integer.parseInt(request.getParameter("quantity"));
        BigDecimal unitPrice = new BigDecimal(request.getParameter("unitPrice"));
        String notes = request.getParameter("notes");

        InspectionItem item = new InspectionItem();
        item.setInspectionId(inspectionId);
        item.setItemName(itemName);
        item.setItemCategory(itemCategory);
        item.setQuantity(quantity);
        item.setUnitPrice(unitPrice);
        item.setNotes(notes);

        inspectionDAO.addInspectionItem(item);

        response.setContentType("application/json");
        response.getWriter().write("{\"success\": true, \"message\": \"Item added successfully\"}");
    }

    private void addRoomDamage(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        int inspectionId = Integer.parseInt(request.getParameter("inspectionId"));
        String damageType = request.getParameter("damageType");
        String description = request.getParameter("description");
        BigDecimal estimatedCost = new BigDecimal(request.getParameter("estimatedCost"));
        String severity = request.getParameter("severity");

        // Handle photo upload
        Part photoPart = request.getPart("photo");
        String photoUrl = null;
        if (photoPart != null && photoPart.getSize() > 0) {
            photoUrl = saveUploadedFile(photoPart, inspectionId);
        }

        RoomDamage damage = new RoomDamage();
        damage.setInspectionId(inspectionId);
        damage.setDamageType(damageType);
        damage.setDescription(description);
        damage.setEstimatedCost(estimatedCost);
        damage.setSeverity(severity);
        damage.setPhotoUrl(photoUrl);

        inspectionDAO.addRoomDamage(damage);

        response.setContentType("application/json");
        response.getWriter().write("{\"success\": true, \"message\": \"Damage recorded successfully\"}");
    }

    private void deleteInspectionItem(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        int itemId = Integer.parseInt(request.getParameter("itemId"));
        inspectionDAO.deleteInspectionItem(itemId);

        response.setContentType("application/json");
        response.getWriter().write("{\"success\": true}");
    }

    private void deleteRoomDamage(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        int damageId = Integer.parseInt(request.getParameter("damageId"));
        inspectionDAO.deleteRoomDamage(damageId);

        response.setContentType("application/json");
        response.getWriter().write("{\"success\": true}");
    }

    private void completeInspection(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        int inspectionId = Integer.parseInt(request.getParameter("inspectionId"));

        // Mark inspection as completed
        inspectionDAO.completeInspection(inspectionId, user.getId());

        session.setAttribute("success", "Inspection completed successfully!");
        response.sendRedirect(request.getContextPath() + "/inspector/dashboard");
    }

    private void saveProgress(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        int inspectionId = Integer.parseInt(request.getParameter("inspectionId"));
        String notes = request.getParameter("notes");

        // Update notes
        inspectionDAO.updateInspectionNotes(inspectionId, notes);

        response.setContentType("application/json");
        response.getWriter().write("{\"success\": true, \"message\": \"Progress saved\"}");
    }

    private String saveUploadedFile(Part part, int inspectionId) throws IOException {
        String fileName = "damage_" + inspectionId + "_" + System.currentTimeMillis() + "_" + getFileName(part);
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "damages";

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        part.write(uploadPath + File.separator + fileName);

        return "damages/" + fileName;
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }

    private void viewInspection(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, Exception {

        int inspectionId = Integer.parseInt(request.getParameter("id"));

        RoomInspection inspection = inspectionDAO.getInspectionById(inspectionId);
        if (inspection == null) {
            throw new Exception("Inspection not found");
        }

        request.setAttribute("inspection", inspection);
        request.setAttribute("pageTitle", "View Inspection - Room " + inspection.getReservation().getRoomNumber());
        request.setAttribute("activePage", "inspection");
        request.setAttribute("contentPage", "/jsp/inspector/view-inspection.jsp");
        request.getRequestDispatcher("/jsp/inspector/inspector-template.jsp").forward(request, response);
    }

}