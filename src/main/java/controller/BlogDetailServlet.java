package controller;

import dal.BlogDAO;
import model.Blog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "BlogDetailServlet", urlPatterns = {"/BlogDetailServlet"})
public class BlogDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        BlogDAO dao = new BlogDAO();
        Blog blog = dao.getBlogById(id);

        request.setAttribute("blog", blog);
        // Forward đến JSP chi tiết
        request.getRequestDispatcher("/jsp/blogDetail.jsp")
       .forward(request, response);
    }
}
