<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/blogs">Blog Management</a></li>
            <li class="breadcrumb-item active">${isEdit ? 'Edit' : 'Add'} Blog</li>
        </ol>
    </nav>
    
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>${isEdit ? 'Edit' : 'Add New'} Blog</h1>
        <a href="${pageContext.request.contextPath}/admin/blogs" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
    
    <!-- Error Messages -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <!-- Blog Form -->
    <div class="card">
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/admin/blogs" 
                  enctype="multipart/form-data" onsubmit="return validateForm()">
                <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                <c:if test="${isEdit}">
                    <input type="hidden" name="id" value="${blog.id}">
                </c:if>
                
                <div class="row">
                    <div class="col-md-8">
                        <!-- Title -->
                        <div class="form-group">
                            <label for="title">Title <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="title" name="title" 
                                       value="${blog.title}" required maxlength="100"
                                   onkeyup="generateSlug()">
                           <small class="form-text text-muted">Maximum 100 characters</small>
                        </div>
                        
                        <!-- Slug -->
                        <div class="form-group">
                            <label for="slug">Slug (URL) <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">/blog/</span>
                                </div>
                                 <input type="text" class="form-control" id="slug" name="slug"
                                       value="${blog.slug}" required maxlength="100"
                                       pattern="[a-z0-9\-]+">
                            </div>
                            <small class="form-text text-muted">
                               URL-friendly version of title (lowercase, no spaces, use hyphens). Maximum 100 characters.
                            </small>
                        </div>
                        
                        <!-- Content -->
                        <div class="form-group">
                            <label for="content">Content <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="content" name="content" 
                                      rows="15" required>${blog.content}</textarea>
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <!-- Status -->
                        <div class="form-group">
                            <label for="status">Status <span class="text-danger">*</span></label>
                            <select class="form-control" id="status" name="status" required>
                                <option value="DRAFT" ${blog.status == 'DRAFT' ? 'selected' : ''}>Draft</option>
                                <option value="PUBLISHED" ${blog.status == 'PUBLISHED' ? 'selected' : ''}>Published</option>
                                <c:if test="${isEdit}">
                                    <option value="ARCHIVED" ${blog.status == 'ARCHIVED' ? 'selected' : ''}>Archived</option>
                                </c:if>
                            </select>
                        </div>
                        
                        <!-- Author (for admin to assign) -->
                        <c:if test="${sessionScope.user.role == 'ADMIN'}">
                            <div class="form-group">
                                <label for="authorId">Author</label>
                                <select class="form-control" id="authorId" name="authorId">
                                    <option value="${sessionScope.user.id}">Me (${sessionScope.user.fullName})</option>
                                    <c:forEach var="author" items="${authors}">
                                        <c:if test="${author.id != sessionScope.user.id}">
                                            <option value="${author.id}" 
                                                    ${blog.authorId == author.id ? 'selected' : ''}>
                                                ${author.fullName}
                                            </option>
                                        </c:if>
                                    </c:forEach>
                                </select>
                            </div>
                        </c:if>
                        
                        <!-- Featured Image -->
                        <div class="form-group">
                            <label for="image">Featured Image</label>
                            
                            <c:if test="${isEdit && not empty blog.imageUrl}">
                                <div class="mb-2">
                                   <img src="${pageContext.request.contextPath}/assets/images/blog/${blog.imageUrl}"  
                                         alt="Current image" class="img-fluid img-thumbnail">
                                    <small class="d-block text-muted mt-1">Current image</small>
                                </div>
                            </c:if>
                            
                            <div class="custom-file">
                                <input type="file" class="custom-file-input" id="image" name="image"
                                       accept="image/*" onchange="previewImage(this)">
                                <label class="custom-file-label" for="image">Choose image</label>
                            </div>
                            <small class="form-text text-muted">
                                Recommended size: 1200x600px. Max 5MB. JPG, PNG, GIF
                            </small>
                            
                            <!-- Image Preview -->
                            <div id="imagePreview" class="mt-2" style="display: none;">
                                <img id="preview" src="" alt="Preview" class="img-fluid img-thumbnail">
                            </div>
                        </div>
                        
                        <!-- Meta Information -->
                        <div class="card bg-light">
                            <div class="card-body">
                                <h6 class="card-title">Information</h6>
                                <c:if test="${isEdit}">
                                    <p class="mb-1">
                                        <small><strong>Created:</strong> 
                                            <fmt:formatDate value="${blog.createdAt}" 
                                                          pattern="dd/MM/yyyy HH:mm"/>
                                        </small>
                                    </p>
                                    <p class="mb-1">
                                        <small><strong>Updated:</strong> 
                                            <fmt:formatDate value="${blog.updatedAt}" 
                                                          pattern="dd/MM/yyyy HH:mm"/>
                                        </small>
                                    </p>
                                    <p class="mb-0">
                                        <small><strong>Comments:</strong> ${blog.commentCount}</small>
                                    </p>
                                </c:if>
                                <c:if test="${not isEdit}">
                                    <p class="mb-0 text-muted">
                                        <small>Blog will be created with current date and time</small>
                                    </p>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Form Actions -->
                <div class="mt-4">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> ${isEdit ? 'Update' : 'Create'} Blog
                    </button>

                    <a href="${pageContext.request.contextPath}/admin/blogs" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Include Summernote CSS/JS -->
<link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-bs4.min.js"></script>

<script>
// Initialize TinyMCE
tinymce.init({
    selector: '#content',
    height: 500,
    menubar: false,
    plugins: [
        'advlist autolink lists link image charmap print preview anchor',
        'searchreplace visualblocks code fullscreen',
        'insertdatetime media table paste code help wordcount'
    ],
    toolbar: 'undo redo | formatselect | ' +
        'bold italic underline | alignleft aligncenter ' +
        'alignright alignjustify | bullist numlist outdent indent | ' +
        'link image | removeformat | help',
    content_style: 'body { font-family:Helvetica,Arial,sans-serif; font-size:14px }'
});

// Generate slug from title
function generateSlug() {
    var title = document.getElementById('title').value;
    var slug = title.toLowerCase()
        .replace(/[^\w\s-]/g, '') // Remove special characters
        .replace(/\s+/g, '-')      // Replace spaces with hyphens
        .replace(/--+/g, '-')      // Replace multiple hyphens with single hyphen
        .trim();                   // Trim whitespace
    document.getElementById('slug').value = slug;
}

// Preview image before upload
function previewImage(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('preview').src = e.target.result;
            document.getElementById('imagePreview').style.display = 'block';
        }
        reader.readAsDataURL(input.files[0]);
        
        // Update label with filename
        var fileName = input.files[0].name;
        var label = input.nextElementSibling;
        label.textContent = fileName;
    }
}

// Form validation
function validateForm() {
    // Get TinyMCE content
    var content = tinymce.get('content').getContent();
    if (content.trim() === '') {
        alert('Please enter blog content');
        return false;
    }
    
    // Validate slug
    var slug = document.getElementById('slug').value;
    if (!/^[a-z0-9\-]+$/.test(slug)) {
        alert('Slug can only contain lowercase letters, numbers, and hyphens');
        return false;
    }
    
    return true;
}

// Update file input label when page loads (for edit mode)
$(document).ready(function() {
    $('#content').summernote({
        height: 400,
        toolbar: [
            ['style', ['style']],
            ['font', ['bold', 'italic', 'underline', 'clear']],
            ['para', ['ul', 'ol', 'paragraph']],
            ['table', ['table']],
            ['insert', ['link', 'picture']],
            ['view', ['fullscreen', 'codeview', 'help']]
        ]
    });
});
</script>