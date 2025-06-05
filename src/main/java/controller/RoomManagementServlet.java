package controller;

import dal.RoomTypeDAO;
import dal.RoomDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "RoomManagementServlet", urlPatterns = {"/admin/rooms"})
public class RoomManagementServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Redirect to existing RoomListServlet
        response.sendRedirect(request.getContextPath() + "/RoomListServlet");
    }
}