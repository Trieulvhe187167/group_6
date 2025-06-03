/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;

import dal.DBContext;
import dal.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
<<<<<<<< HEAD:src/main/java/controller/ManagerUserServlet.java
import java.sql.Connection;
import java.util.List;
import java.util.Optional;
import model.User;

/**
 *
 * @author he187
 */
@WebServlet(name="ManagerUserServlet", urlPatterns={"/ManagerUserServlet"})
public class ManagerUserServlet extends HttpServlet {
========
import dal.EventDAO;
import model.Event;
import java.io.IOException;
import java.util.List;
/**
 *
 * @author dmx
 */
@WebServlet(name="EventServlet", urlPatterns={"/EventServlet"})
public class EventServlet extends HttpServlet {
>>>>>>>> develop:src/main/java/controller/EventServlet.java
   
    /** 
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
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
<<<<<<<< HEAD:src/main/java/controller/ManagerUserServlet.java
            out.println("<title>Servlet ManagerUserServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ManagerUserServlet at " + request.getContextPath () + "</h1>");
========
            out.println("<title>Servlet EventServlet</title>");  
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EventServlet at " + request.getContextPath () + "</h1>");
>>>>>>>> develop:src/main/java/controller/EventServlet.java
            out.println("</body>");
            out.println("</html>");
        }
    } 

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /** 
     * Handles the HTTP <code>GET</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
<<<<<<<< HEAD:src/main/java/controller/ManagerUserServlet.java
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        UserDAO userDAO = new UserDAO();
        List<User> users = userDAO.getAllUsers();

        request.setAttribute("users", users);
        request.getRequestDispatcher("/jsp/ManagerCustomer.jsp").forward(request, response);
    } 

========
      protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Event> events = new EventDAO().getAllEvents();
        req.setAttribute("events", events);
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
>>>>>>>> develop:src/main/java/controller/EventServlet.java
    /** 
     * Handles the HTTP <code>POST</code> method.
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
<<<<<<<< HEAD:src/main/java/controller/ManagerUserServlet.java
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String role = request.getParameter("role");

        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(role);

        UserDAO userDAO = new UserDAO();
        boolean success = userDAO.createUser(user);

        if (success) {
            request.getRequestDispatcher("/ManagerUserServlet").forward(request, response); // về trang danh sách
        } else {
            request.setAttribute("error", "Không thể tạo user");
            request.getRequestDispatcher("/jsp/create_user.jsp").forward(request, response);
        }
    
========
        processRequest(request, response);
>>>>>>>> develop:src/main/java/controller/EventServlet.java
    }

    /** 
     * Returns a short description of the servlet.
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
