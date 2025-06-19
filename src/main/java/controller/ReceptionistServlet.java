package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/admin/receptionist")
public class ReceptionistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Highlight "receptionist" in the sidebar
        request.setAttribute("activePage", "receptionist");

        // Forward to the receptionist content JSP
        request.setAttribute("contentPage", "/jsp/admin/receptionist.jsp");

        // Forward using the main layout that includes the contentPage
        request.getRequestDispatcher("/jsp/admin/admin-layout.jsp").forward(request, response);
    }
}