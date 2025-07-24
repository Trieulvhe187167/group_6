package controller;

import dal.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name="ChangePasswordServlet", urlPatterns={
        "/customer/change-password",
        "/housekeeper/change-password",
        "/inspector/change-password"
})
public class ChangePasswordServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
       if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
       String role = user.getRole();
        String redirectBase;
        switch (role) {
            case "CUSTOMER":
                redirectBase = "/customer/profile";
                break;
            case "HOUSEKEEPER":
                redirectBase = "/housekeeper/profile";
                break;
            case "ROOM_INSPECTOR":
                redirectBase = "/inspector/profile";
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
                return;
        }

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (currentPassword == null || newPassword == null || confirmPassword == null ||
            currentPassword.isEmpty() || newPassword.isEmpty() || confirmPassword.isEmpty()) {
            session.setAttribute("error", "All password fields are required.");
            response.sendRedirect(request.getContextPath() + redirectBase + "#security");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            session.setAttribute("error", "New password and confirmation do not match.");
           response.sendRedirect(request.getContextPath() + redirectBase + "#security");
            return;
        }

        if (!newPassword.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@#$%^&+=!]).{8,}$")) {
            session.setAttribute("error", "Password must be at least 8 characters with uppercase, lowercase, digit and special character.");
             response.sendRedirect(request.getContextPath() + redirectBase + "#security");
            return;
        }

        boolean success = userDAO.changePassword(user.getId(), currentPassword, newPassword);
        if (success) {
            session.setAttribute("success", "Password changed successfully.");
        } else {
            session.setAttribute("error", "Current password is incorrect.");
        }
       response.sendRedirect(request.getContextPath() + redirectBase + "#security");
    }
}