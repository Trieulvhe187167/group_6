package controller;

import dal.BlogDAO;
import model.Blog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "BlogListServlet", urlPatterns = {"/BlogListServlet"})
public class BlogListServlet extends HttpServlet {
  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    List<Blog> blogs = new BlogDAO().getPublishedBlogs();
    req.setAttribute("blogs", blogs);
    // forward ??n /jsp/blog.jsp
    req.getRequestDispatcher("/jsp/blog.jsp")
       .forward(req, resp);
  }
}
