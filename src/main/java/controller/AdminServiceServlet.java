package controller;

import dal.ServiceDAO;
import dal.UserDAO;
import model.Service;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AdminServiceServlet", urlPatterns = {"/admin/services"})
public class AdminServiceServlet extends HttpServlet {

    private ServiceDAO serviceDAO = new ServiceDAO();
    private UserDAO userDAO = new UserDAO();
    private static final int RECORDS_PER_PAGE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        switch (action) {
            case "list":
                listServices(request, response);
                break;
            case "add":
                showAddForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "view":
                viewServiceDetail(request, response);
                break;
            default:
                listServices(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

        switch (action) {
            case "create":
                createService(request, response, currentUser);
                break;
            case "update":
                updateService(request, response);
                break;
            case "delete":
                deleteService(request, response);
                break;
            default:
                response.sendRedirect("services");
        }
    }

    private void listServices(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = request.getParameter("search");
        String status = request.getParameter("status");
        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        List<Service> all = serviceDAO.getAllServices(search, status);
        int totalRecords = all.size();
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        if (page < 1) {
            page = 1;
        }
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }
        int start = (page - 1) * RECORDS_PER_PAGE;
        int end = Math.min(start + RECORDS_PER_PAGE, totalRecords);
        List<Service> services = totalRecords > 0 ? all.subList(start, end) : new ArrayList<>();

        request.setAttribute("services", services);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("recordsPerPage", RECORDS_PER_PAGE);

        request.setAttribute("pageTitle", "Service Management");
        request.setAttribute("activePage", "services");
        request.setAttribute("contentPage", "/jsp/admin/admin-services-content.jsp");

        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("isEdit", false);
        request.setAttribute("pageTitle", "Add New Service");
        request.setAttribute("activePage", "services");
        request.setAttribute("contentPage", "/jsp/admin/admin-service-form.jsp");
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("services");
            return;
        }
        Service service = serviceDAO.getServiceById(Integer.parseInt(idStr));
        if (service == null) {
            request.getSession().setAttribute("error", "Service not found");
            response.sendRedirect("services");
            return;
        }
        request.setAttribute("service", service);
        request.setAttribute("isEdit", true);
        request.setAttribute("pageTitle", "Edit Service");
        request.setAttribute("activePage", "services");
        request.setAttribute("contentPage", "/jsp/admin/admin-service-form.jsp");
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void viewServiceDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("services");
            return;
        }
        Service service = serviceDAO.getServiceById(Integer.parseInt(idStr));
        if (service == null) {
            request.getSession().setAttribute("error", "Service not found");
            response.sendRedirect("services");
            return;
        }
        request.setAttribute("service", service);
        request.setAttribute("pageTitle", "Service Details - " + service.getName());
        request.setAttribute("activePage", "services");
        request.setAttribute("contentPage", "/jsp/admin/admin-service-detail.jsp");
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }

    private void createService(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String status = request.getParameter("status");

        if (name == null || name.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty()) {
            request.setAttribute("error", "Name and price are required");
            showAddForm(request, response);
            return;
        }

        try {
            double price = Double.parseDouble(priceStr);
            Service service = new Service();
            service.setName(name.trim());
            service.setDescription(description != null ? description.trim() : null);
            service.setPrice(price);
            service.setStatus(status != null ? status : "ACTIVE");
            service.setCreatedBy(currentUser.getId());

            if (serviceDAO.createService(service)) {
                request.getSession().setAttribute("success", "Service created successfully");
                response.sendRedirect("services");
            } else {
                request.setAttribute("error", "Failed to create service");
                showAddForm(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price format");
            showAddForm(request, response);
        }
    }

    private void updateService(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String status = request.getParameter("status");

        if (idStr == null) {
            response.sendRedirect("services");
            return;
        }

        if (name == null || name.trim().isEmpty() || priceStr == null || priceStr.trim().isEmpty()) {
            request.setAttribute("error", "Name and price are required");
            showEditForm(request, response);
            return;
        }

        Service service = serviceDAO.getServiceById(Integer.parseInt(idStr));
        if (service == null) {
            request.getSession().setAttribute("error", "Service not found");
            response.sendRedirect("services");
            return;
        }

        try {
            double price = Double.parseDouble(priceStr);
            service.setName(name.trim());
            service.setDescription(description != null ? description.trim() : null);
            service.setPrice(price);
            service.setStatus(status);

            if (serviceDAO.updateService(service)) {
                request.getSession().setAttribute("success", "Service updated successfully");
                response.sendRedirect("services");
            } else {
                request.setAttribute("error", "Failed to update service");
                request.setAttribute("service", service);
                showEditForm(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid price format");
            request.setAttribute("service", service);
            showEditForm(request, response);
        }
    }

    private void deleteService(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("services");
            return;
        }
        try {
            int id = Integer.parseInt(idStr);
            if (serviceDAO.deleteService(id)) {
                request.getSession().setAttribute("success", "Service deleted successfully");
            } else {
                request.getSession().setAttribute("error", "Failed to delete service");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid service ID");
        }
        response.sendRedirect("services");
    }
}
