package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;

public abstract class ReceptionistBaseServlet extends HttpServlet {
    
    protected boolean checkReceptionistAuth(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null || !"RECEPTIONIST".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return false;
        }
        return true;
    }
    
    protected void forwardToTemplate(HttpServletRequest request, HttpServletResponse response, 
            String pageTitle, String activePage, String contentPage) throws ServletException, IOException {
        request.setAttribute("pageTitle", pageTitle);
        request.setAttribute("activePage", activePage);
        request.setAttribute("contentPage", contentPage);
        request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
    }
    
    protected void handleError(HttpServletRequest request, HttpServletResponse response, 
            Exception e, String errorMessage) throws ServletException, IOException {
        e.printStackTrace();
        request.setAttribute("error", errorMessage + ": " + e.getMessage());
        request.getRequestDispatcher("/jsp/reception/receptionist-template.jsp").forward(request, response);
    }
} 