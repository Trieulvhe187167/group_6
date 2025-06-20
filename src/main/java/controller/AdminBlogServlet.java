package controller;

import dal.BlogDAO;
import dal.UserDAO;
import dal.CommentDAO;
import model.Blog;
import model.User;
import model.Comment;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.File;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@WebServlet(name = "AdminBlogServlet", urlPatterns = {"/admin/blogs"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 5,       // 5MB
    maxRequestSize = 1024 * 1024 * 10    // 10MB
)
public class AdminBlogServlet extends HttpServlet {
    
    private BlogDAO blogDAO = new BlogDAO();
    private UserDAO userDAO = new UserDAO();
    private CommentDAO commentDAO = new CommentDAO();
    private static final int RECORDS_PER_PAGE = 3;
    private static final String UPLOAD_DIR = "uploads";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || (!"ADMIN".equals(currentUser.getRole()) && 
                                   !"RECEPTIONIST".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        try {
            switch (action) {
                case "list":
                    listBlogs(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "view":
                    viewBlogDetail(request, response);
                    break;
                default:
                    listBlogs(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            listBlogs(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || (!"ADMIN".equals(currentUser.getRole()) && 
                                   !"RECEPTIONIST".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "";
        
        try {
            switch (action) {
                case "create":
                    createBlog(request, response, currentUser);
                    break;
                case "update":
                    updateBlog(request, response);
                    break;
                case "delete":
                    deleteBlog(request, response);
                    break;
                case "publish":
                    publishBlog(request, response);
                    break;
                case "unpublish":
                    unpublishBlog(request, response);
                    break;
                default:
                    response.sendRedirect("blogs");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            listBlogs(request, response);
        }
    }
    
    private void listBlogs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String authorIdStr = request.getParameter("authorId");
        int page = 1;
        
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        
        // Get all blogs (implement filtering in DAO)
        List<Blog> allBlogs = blogDAO.getAllBlogs(search, status, authorIdStr);
        
        // Calculate pagination
        int totalRecords = allBlogs.size();
        int totalPages = (int) Math.ceil((double) totalRecords / RECORDS_PER_PAGE);
        
        if (page < 1) page = 1;
        if (page > totalPages && totalPages > 0) page = totalPages;
        
        int start = (page - 1) * RECORDS_PER_PAGE;
        int end = Math.min(start + RECORDS_PER_PAGE, totalRecords);
        
        List<Blog> blogs = allBlogs.subList(start, end);
        
        // Get statistics
        int totalBlogs = blogDAO.getTotalBlogs();
        int publishedCount = blogDAO.getPublishedCount();
        int draftCount = blogDAO.getDraftCount();
        int totalComments = blogDAO.getTotalComments();
        
        // Get authors for filter
        List<User> authors = userDAO.getAuthors();
        
        request.setAttribute("blogs", blogs);
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("authorId", authorIdStr);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("recordsPerPage", RECORDS_PER_PAGE);
        request.setAttribute("totalBlogs", totalBlogs);
        request.setAttribute("publishedCount", publishedCount);
        request.setAttribute("draftCount", draftCount);
        request.setAttribute("totalComments", totalComments);
        request.setAttribute("authors", authors);
        
        // Set page info
        request.setAttribute("pageTitle", "Blog Management");
        request.setAttribute("activePage", "blogs");
        request.setAttribute("contentPage", "/jsp/admin/admin-blogs-content.jsp");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get authors for dropdown
        List<User> authors = userDAO.getAuthors();
        
        request.setAttribute("authors", authors);
        request.setAttribute("isEdit", false);
        request.setAttribute("pageTitle", "Add New Blog");
        request.setAttribute("activePage", "blogs");
        request.setAttribute("contentPage", "/jsp/admin/admin-blog-form.jsp");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("blogs");
            return;
        }
        
        Blog blog = blogDAO.getBlogById(idStr);
        if (blog == null) {
            request.getSession().setAttribute("error", "Blog not found");
            response.sendRedirect("blogs");
            return;
        }
        
        // Get authors for dropdown
        List<User> authors = userDAO.getAuthors();
        
        request.setAttribute("blog", blog);
        request.setAttribute("authors", authors);
        request.setAttribute("isEdit", true);
        request.setAttribute("pageTitle", "Edit Blog");
        request.setAttribute("activePage", "blogs");
        request.setAttribute("contentPage", "/jsp/admin/admin-blog-form.jsp");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void viewBlogDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("blogs");
            return;
        }
        
        Blog blog = blogDAO.getBlogById(idStr);
        if (blog == null) {
            request.getSession().setAttribute("error", "Blog not found");
            response.sendRedirect("blogs");
            return;
        }
        
        // Get comments for this blog
        List<Comment> comments = commentDAO.getCommentsByBlogId(Integer.parseInt(idStr));
        
        request.setAttribute("blog", blog);
        request.setAttribute("comments", comments);
        request.setAttribute("pageTitle", "Blog Details - " + blog.getTitle());
        request.setAttribute("activePage", "blogs");
        request.setAttribute("contentPage", "/jsp/admin/admin-blog-detail.jsp");
        
        request.getRequestDispatcher("/jsp/admin/admin-template.jsp").forward(request, response);
    }
    
    private void createBlog(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        
        String title = request.getParameter("title");
        String slug = request.getParameter("slug");
        String content = request.getParameter("content");
        String status = request.getParameter("status");
        String authorIdStr = request.getParameter("authorId");
        
        // Validate required fields
        if (title == null || title.trim().isEmpty() ||
            slug == null || slug.trim().isEmpty() ||
            content == null || content.trim().isEmpty()) {
            request.setAttribute("error", "All required fields must be filled");
            showAddForm(request, response);
            return;
        }
        
        // Check if slug already exists
        if (blogDAO.isSlugExists(slug, null)) {
            request.setAttribute("error", "Slug already exists. Please choose a different one.");
            showAddForm(request, response);
            return;
        }
        
        // Handle file upload
        String imageUrl = handleFileUpload(request);
        
        // Create blog object
        Blog blog = new Blog();
        blog.setTitle(title.trim());
        blog.setSlug(slug.trim().toLowerCase());
        blog.setContent(content);
        blog.setStatus(status != null ? status : "DRAFT");
        blog.setImageUrl(imageUrl);
        
        // Set author ID
        if (authorIdStr != null && !authorIdStr.isEmpty()) {
            blog.setAuthorId(Integer.parseInt(authorIdStr));
        } else {
            blog.setAuthorId(currentUser.getId());
        }
        
        if (blogDAO.insertBlog(blog)) {
            request.getSession().setAttribute("success", "Blog created successfully");
            
            // Check if save and continue
            String saveAndContinue = request.getParameter("saveAndContinue");
            if ("true".equals(saveAndContinue)) {
                // Get the created blog ID and redirect to edit
                Blog createdBlog = blogDAO.getBlogBySlug(slug);
                if (createdBlog != null) {
                    response.sendRedirect("blogs?action=edit&id=" + createdBlog.getId());
                } else {
                    response.sendRedirect("blogs");
                }
            } else {
                response.sendRedirect("blogs");
            }
        } else {
            request.setAttribute("error", "Failed to create blog");
            showAddForm(request, response);
        }
    }
    
    private void updateBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        String title = request.getParameter("title");
        String slug = request.getParameter("slug");
        String content = request.getParameter("content");
        String status = request.getParameter("status");
        
        if (idStr == null) {
            response.sendRedirect("blogs");
            return;
        }
        
        // Validate required fields
        if (title == null || title.trim().isEmpty() ||
            slug == null || slug.trim().isEmpty() ||
            content == null || content.trim().isEmpty()) {
            request.setAttribute("error", "All required fields must be filled");
            showEditForm(request, response);
            return;
        }
        
        // Check if slug already exists (excluding current blog)
        if (blogDAO.isSlugExists(slug, Integer.parseInt(idStr))) {
            request.setAttribute("error", "Slug already exists. Please choose a different one.");
            showEditForm(request, response);
            return;
        }
        
        // Get existing blog
        Blog blog = blogDAO.getBlogById(idStr);
        if (blog == null) {
            request.getSession().setAttribute("error", "Blog not found");
            response.sendRedirect("blogs");
            return;
        }
        
        // Handle file upload
        String imageUrl = handleFileUpload(request);
        if (imageUrl != null) {
            blog.setImageUrl(imageUrl);
        }
        
        // Update blog object
        blog.setTitle(title.trim());
        blog.setSlug(slug.trim().toLowerCase());
        blog.setContent(content);
        blog.setStatus(status);
        
        if (blogDAO.updateBlog(blog)) {
            request.getSession().setAttribute("success", "Blog updated successfully");
            
            // Check if save and continue
            String saveAndContinue = request.getParameter("saveAndContinue");
            if ("true".equals(saveAndContinue)) {
                response.sendRedirect("blogs?action=edit&id=" + idStr);
            } else {
                response.sendRedirect("blogs");
            }
        } else {
            request.setAttribute("error", "Failed to update blog");
            showEditForm(request, response);
        }
    }
    
    private void deleteBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("blogs");
            return;
        }
        
        try {
            int id = Integer.parseInt(idStr);
            if (blogDAO.deleteBlog(id)) {
                request.getSession().setAttribute("success", "Blog archived successfully");
            } else {
                request.getSession().setAttribute("error", "Failed to archive blog");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid blog ID");
        }
        
        response.sendRedirect("blogs");
    }
    
    private void publishBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("blogs");
            return;
        }
        
        Blog blog = blogDAO.getBlogById(idStr);
        if (blog != null) {
            blog.setStatus("PUBLISHED");
            if (blogDAO.updateBlog(blog)) {
                request.getSession().setAttribute("success", "Blog published successfully");
            } else {
                request.getSession().setAttribute("error", "Failed to publish blog");
            }
        }
        
        response.sendRedirect("blogs?action=view&id=" + idStr);
    }
    
    private void unpublishBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect("blogs");
            return;
        }
        
        Blog blog = blogDAO.getBlogById(idStr);
        if (blog != null) {
            blog.setStatus("DRAFT");
            if (blogDAO.updateBlog(blog)) {
                request.getSession().setAttribute("success", "Blog unpublished successfully");
            } else {
                request.getSession().setAttribute("error", "Failed to unpublish blog");
            }
        }
        
        response.sendRedirect("blogs?action=view&id=" + idStr);
    }
    
    private String handleFileUpload(HttpServletRequest request) throws IOException, ServletException {
        Part filePart = request.getPart("image");
        
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        
        // Validate file type
        String contentType = filePart.getContentType();
        if (!contentType.startsWith("image/")) {
            throw new ServletException("Only image files are allowed");
        }
        
        // Generate unique filename
        String extension = fileName.substring(fileName.lastIndexOf("."));
        String uniqueFileName = UUID.randomUUID().toString() + extension;
        
        // Create upload directory if it doesn't exist
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }
        
        // Save file
        filePart.write(uploadPath + File.separator + uniqueFileName);
        
        return uniqueFileName;
    }
}