/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dal.CustomerSupportDAO;
import model.*;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "CustomerSupport2Servlet", urlPatterns = {"/receptionist/support"})
public class CustomerSupport2Servlet extends HttpServlet {

    private CustomerSupportDAO supportDAO = new CustomerSupportDAO();

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
            out.println("<title>Servlet CustomerSupport2Servlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CustomerSupport2Servlet at " + request.getContextPath() + "</h1>");
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
        //rocessRequest(request, response);

        // Check receptionist authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            showSupportList(request, response);
        } else if (action.equals("detail")) {
            showSupportDetail(request, response);
        } else {
            showSupportList(request, response);
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
        //processRequest(request, response);

        // Check receptionist authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("reply".equals(action)) {
            handleReply(request, response);
        } else if ("updateStatus".equals(action)) {
            handleUpdateStatus(request, response);
        } else {
            response.sendRedirect("support");
        }
    }

    // Hiển thị danh sách tất cả yêu cầu hỗ trợ
    private void showSupportList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lấy tham số lọc và sắp xếp từ request
            String filterRoom = request.getParameter("filterRoom");
            String filterStatus = request.getParameter("filterStatus");
            String sortBy = request.getParameter("sortBy");

            // Giá trị mặc định nếu không có
            if (filterRoom == null) {
                filterRoom = "";
            }
            if (filterStatus == null) {
                filterStatus = "";
            }
            if (sortBy == null || sortBy.isEmpty()) {
                sortBy = "createdAt";
            }

            // Lấy danh sách yêu cầu hỗ trợ sau khi lọc và sắp xếp
            List<SupportRequest> requestList = supportDAO.getFilteredSupportRequests(filterRoom, filterStatus, sortBy);

            // Phân trang
            int pageSize = 5; // Số mục mỗi trang
            int currentPage = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                try {
                    currentPage = Integer.parseInt(pageParam);
                    if (currentPage < 1) {
                        currentPage = 1;
                    }
                } catch (NumberFormatException e) {
                    currentPage = 1;
                }
            }

            int totalItems = requestList.size();
            int totalPages = (int) Math.ceil((double) totalItems / pageSize);

            // Cắt danh sách theo trang
            int start = (currentPage - 1) * pageSize;
            int end = Math.min(start + pageSize, totalItems);
            List<SupportRequest> pagedList = requestList.subList(start, end);

            // Danh sách tất cả roomNumber để hiển thị dropdown lọc
            Set<String> roomList = supportDAO.getAllRoomNumbersInRequests();

            // Truyền dữ liệu ra JSP
            request.setAttribute("requestList", pagedList);
            request.setAttribute("roomList", roomList);
            request.setAttribute("filterRoom", filterRoom);
            request.setAttribute("filterStatus", filterStatus);
            request.setAttribute("sortBy", sortBy);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Unable to load support requests.");
        }

        request.setAttribute("pageTitle", "Support Requests");
        request.setAttribute("activePage", "support");
        request.setAttribute("contentPage", "support-list.jsp");
        request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
    }

    // Hiển thị chi tiết một yêu cầu và các phản hồi
    private void showSupportDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int requestId = Integer.parseInt(request.getParameter("id"));
            SupportRequest supportRequest = supportDAO.getSupportRequestById(requestId);
            List<SupportReply> replies = supportDAO.getRepliesByRequestId(requestId);

            request.setAttribute("supportRequest", supportRequest);
            request.setAttribute("replies", replies);
        } catch (Exception e) {
            request.setAttribute("error", "Invalid support request ID.");
        }

        request.setAttribute("pageTitle", "Support Request Detail");
        request.setAttribute("activePage", "support");
        request.setAttribute("contentPage", "support-detail.jsp");
        request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
    }

    // Gửi phản hồi và cập nhật trạng thái
    private void handleReply(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            int staffId = ((model.User) request.getSession().getAttribute("user")).getId();
            String message = request.getParameter("message");
            String status = request.getParameter("status");

            // Insert reply
            supportDAO.insertReply(requestId, staffId, message);

            // Update status nếu status khác null
            if (status != null && !status.trim().isEmpty()) {
                supportDAO.updateSupportRequestStatus(requestId, status);
            }

        } catch (Exception e) {
            e.printStackTrace(); // Debug
            request.setAttribute("error", "Failed to send reply.");
        }

        response.sendRedirect("support?action=detail&id=" + request.getParameter("requestId"));
    }

    // Update support request status
    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            String status = request.getParameter("status");

            // Validate status value (whitelist)
            List<String> validStatuses = Arrays.asList("Pending", "In Progress", "Resolved", "Rejected");
            if (!validStatuses.contains(status)) {
                request.setAttribute("error", "Invalid status value.");
                response.sendRedirect("support?action=detail&id=" + requestId);
                return;
            }

            supportDAO.updateSupportRequestStatus(requestId, status);

            // Redirect to detail page
            response.sendRedirect("support?action=detail&id=" + requestId);
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("error", "Invalid request ID format.");
            response.sendRedirect("support");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to update support request status.");
            response.sendRedirect("support?action=detail&id=" + request.getParameter("requestId"));
        }
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
