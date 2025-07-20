package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;

@WebServlet(name="HousekeeperProfileServlet", urlPatterns={"/housekeeper/profile"})
public class HousekeeperProfileServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null || !"HOUSEKEEPER".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        User user = userDAO.getEmployeeByIdWithDetails(currentUser.getId());
        request.setAttribute("user", user);
        request.setAttribute("pageTitle", "My Profile");
        request.setAttribute("activePage", "profile");
        request.setAttribute("contentPage", "/jsp/housekeeper/housekeeper-profile-content.jsp");

        request.getRequestDispatcher("/jsp/housekeeper/housekeeper-template.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}