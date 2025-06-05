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
            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            switch (user.getRole()) {
                case "ADMIN":
                    response.sendRedirect("admin-dashboard.jsp");
                    break;
                case "RECEPTIONIST":
                    response.sendRedirect("reception-dashboard.jsp");
                    break;
                case "HOUSEKEEPER":
                    response.sendRedirect("housekeeping.jsp");
                    break;
                case "GUEST":
                    response.sendRedirect("/index.jsp");
                    break;
                default:
                    request.setAttribute("errorMsg", "Vai trò không hợp lệ!");
                    request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
            }
        } else {
            request.setAttribute("errorMsg", "Sai tên đăng nhập hoặc mật khẩu!");
            request.getRequestDispatcher("jsp/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect("jsp/login.jsp");
    }
}

