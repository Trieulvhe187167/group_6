package controller;

import dal.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        UserDAO userDAO = new UserDAO();
        User user = userDAO.login(username, password);
        
        if (user != null) {
            
            // Create session and store user info
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            
            // Redirect based on role
            switch (user.getRole()) {
                case "ADMIN":
                    response.sendRedirect("/admin-dashboard");
                    break;
                case "RECEPTIONIST":
                    response.sendRedirect("reception-dashboard.jsp");
                    break;
                case "HOUSEKEEPER":
                    response.sendRedirect("/housekeeper-dashboard");
                    break;
                case "ROOM_INSPECTOR":
                    response.sendRedirect("/inspector-dashboard");
                    break;
                case "CUSTOMER":
                    response.sendRedirect("/index.jsp");
                    break;
                default:
                    request.setAttribute("errorMsg", "Role invalid!");
                    request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
            }
        } else {
            request.setAttribute("errorMsg", "Wrong username or password!");
            request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("jsp/login.jsp");
    }
}
