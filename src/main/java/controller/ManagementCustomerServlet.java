package controller;

import dal.CustomerDAO;
import model.Customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ManagementCustomerServlet", urlPatterns = "/managementCustomer")
public class ManagementCustomerServlet extends HttpServlet {

    private CustomerDAO dao = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<Customer> customers = dao.getAllCustomers();
            req.setAttribute("customers", customers);
            // forward tới Web Pages/jsp/ManagerCustomer.jsp
            req.getRequestDispatcher("/jsp/ManagerCustomer.jsp")
               .forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("create".equals(action)) {
                Customer c = new Customer();
                c.setUsername(req.getParameter("username"));
                c.setPasswordHash(req.getParameter("password"));
                c.setFullName(req.getParameter("fullName"));
                c.setEmail(req.getParameter("email"));
                c.setPhone(req.getParameter("phone"));
                dao.createCustomer(c);
            } else if ("update".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Customer c = dao.getCustomerById(id);
                c.setFullName(req.getParameter("fullName"));
                c.setEmail(req.getParameter("email"));
                c.setPhone(req.getParameter("phone"));
                dao.updateCustomer(c);
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                dao.deleteCustomer(id);
            }
            // redirect về doGet
            resp.sendRedirect(req.getContextPath() + "/managementCustomer");
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }
}