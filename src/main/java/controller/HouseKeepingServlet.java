package controller;

import dal.HouseKeepingDAO;
import model.HousekeepingTask;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "HouseKeepingServlet", urlPatterns = {"/admin/housetkeeping"})
public class HouseKeepingServlet extends HttpServlet {

    private HouseKeepingDAO housekeepingDAO = new HouseKeepingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "list":
                    listTasks(request, response);
                    break;
                case "search":
                    searchTasksByStatus(request, response);
                    break;
                default:
                    listTasks(request, response);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            switch (action) {
                case "update":
                    updateTaskStatus(request, response);
                    break;
                case "delete":
                    deleteTask(request, response);
                    break;
                case "search":
                    searchTasksByStatus(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/housekeeping");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void listTasks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<HousekeepingTask> tasks = housekeepingDAO.getAllTasks();
        request.setAttribute("tasks", tasks);
        request.getRequestDispatcher("/jsp/HouseKeeping.jsp").forward(request, response);
    }

    private void searchTasksByStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String status = request.getParameter("status");

        List<HousekeepingTask> tasks = housekeepingDAO.searchTasksByStatus(status);
        request.setAttribute("tasks", tasks);
        request.setAttribute("searchStatus", status);
        request.setAttribute("isSearch", true);

        request.getRequestDispatcher("/jsp/HouseKeeping.jsp").forward(request, response);
    }

    private void updateTaskStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        int taskId = Integer.parseInt(request.getParameter("taskId"));
        String newStatus = request.getParameter("newStatus");

        boolean updated = housekeepingDAO.updateTaskStatusById(taskId, newStatus);

        if (updated) {
            response.sendRedirect(request.getContextPath() + "/admin/housekeeping?success=updated");
        } else {
            request.setAttribute("error", "Failed to update task status.");
            listTasks(request, response); // reload page with error
        }
    }

    private void deleteTask(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        int taskId = Integer.parseInt(request.getParameter("taskId"));

        boolean deleted = housekeepingDAO.deleteTaskById(taskId);

        if (deleted) {
            response.sendRedirect(request.getContextPath() + "/admin/housekeeping?success=deleted");
        } else {
            request.setAttribute("error", "Failed to delete task.");
            listTasks(request, response);
        }
    }
}
