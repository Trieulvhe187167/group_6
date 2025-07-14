<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
.blog-content {
    font-size: 1.1rem;
    line-height: 1.8;
}

.blog-content p {
    margin-bottom: 1rem;
}

.blog-content h1, .blog-content h2, .blog-content h3, 
.blog-content h4, .blog-content h5, .blog-content h6 {
    margin-top: 1.5rem;
    margin-bottom: 1rem;
}

.blog-content img {
    max-width: 100%;
    height: auto;
}

.blog-content ul, .blog-content ol {
    margin-bottom: 1rem;
    padding-left: 2rem;
}
</style>
<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/blogs">Blog Management</a></li>
            <li class="breadcrumb-item active">Blog Details</li>
        </ol>
    </nav>
    
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1>Blog Details</h1>
        <div>
            <a href="${pageContext.request.contextPath}/admin/blogs?action=edit&id=${blog.id}" 
               class="btn btn-warning">
                <i class="fas fa-edit"></i> Edit Blog
            </a>
            <a href="${pageContext.request.contextPath}/admin/blogs" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to List
            </a>
        </div>
    </div>
    
    <div class="row">
        <!-- Blog Content -->
        <div class="col-md-8">
            <div class="card">
                <div class="card-body">
                    <!-- Title and Meta -->
                    <h2 class="mb-3">${blog.title}</h2>
                    
                    <div class="mb-3">
                        <span class="text-muted">
                            <i class="fas fa-user"></i> By ${blog.authorName}
                        </span>
                        <span class="text-muted mx-2">|</span>
                        <span class="text-muted">
                            <i class="fas fa-calendar"></i> 
                            <fmt:formatDate value="${blog.createdAt}" pattern="dd MMMM yyyy"/>
                        </span>
                        <span class="text-muted mx-2">|</span>
                        <span class="text-muted">
                            <i class="fas fa-comments"></i> ${blog.commentCount} Comments
                        </span>
                    </div>
                    
                    <!-- Status Badge -->
                    <div class="mb-3">
                        <c:choose>
                            <c:when test="${blog.status == 'PUBLISHED'}">
                                <span class="badge badge-success">Published</span>
                            </c:when>
                            <c:when test="${blog.status == 'DRAFT'}">
                                <span class="badge badge-warning">Draft</span>
                            </c:when>
                            <c:when test="${blog.status == 'ARCHIVED'}">
                                <span class="badge badge-secondary">Archived</span>
                            </c:when>
                        </c:choose>
                    </div>
                    
                    <!-- Featured Image -->
                    <c:if test="${not empty blog.imageUrl}">
                        <div class="mb-4">
                            <img src="${pageContext.request.contextPath}/assets/images/blog/${blog.imageUrl}"  
                                 alt="${blog.title}" class="img-fluid rounded">
                        </div>
                    </c:if>
                    
                    <!-- Content -->
                    <div class="blog-content">
                        ${blog.content}
                    </div>
                </div>
            </div>
            
            <!-- Comments Section -->
            <div class="card mt-4">
                <div class="card-header">
                    <h4 class="mb-0">Comments (${comments.size()})</h4>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty comments}">
                            <c:forEach var="comment" items="${comments}">
                                <div class="media mb-3 p-3 border rounded">
                                    <img src="${pageContext.request.contextPath}/assets/images/user-avatar.png" 
                                         class="mr-3 rounded-circle" alt="User" width="50">
                                    <div class="media-body">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <h6 class="mt-0 mb-1">${comment.authorName}</h6>
                                                <small class="text-muted">
                                                    <fmt:formatDate value="${comment.createdAt}" 
                                                                  pattern="dd/MM/yyyy HH:mm"/>
                                                </small>
                                            </div>
                                            <div>
                                                <c:choose>
                                                    <c:when test="${comment.status == 'APPROVED'}">
                                                        <span class="badge badge-success">Approved</span>
                                                    </c:when>
                                                    <c:when test="${comment.status == 'PENDING'}">
                                                        <span class="badge badge-warning">Pending</span>
                                                    </c:when>
                                                    <c:when test="${comment.status == 'REJECTED'}">
                                                        <span class="badge badge-danger">Rejected</span>
                                                    </c:when>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <p class="mt-2 mb-2">${comment.content}</p>
                                        <div>
                                            <c:if test="${comment.status == 'PENDING'}">
                                                <button class="btn btn-sm btn-success" 
                                                        onclick="updateCommentStatus(${comment.id}, 'APPROVED')">
                                                    <i class="fas fa-check"></i> Approve
                                                </button>
                                                <button class="btn btn-sm btn-danger" 
                                                        onclick="updateCommentStatus(${comment.id}, 'REJECTED')">
                                                    <i class="fas fa-times"></i> Reject
                                                </button>
                                            </c:if>
                                            <c:if test="${comment.status == 'APPROVED'}">
                                                <button class="btn btn-sm btn-warning" 
                                                        onclick="updateCommentStatus(${comment.id}, 'REJECTED')">
                                                    <i class="fas fa-ban"></i> Hide
                                                </button>
                                            </c:if>
                                            <c:if test="${comment.status == 'REJECTED'}">
                                                <button class="btn btn-sm btn-success" 
                                                        onclick="updateCommentStatus(${comment.id}, 'APPROVED')">
                                                    <i class="fas fa-check"></i> Unhide
                                                </button>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted text-center">No comments yet.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        
        <!-- Sidebar -->
        <div class="col-md-4">
            <!-- Blog Information -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Blog Information</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>ID:</strong> #${blog.id}
                    </div>
                    <div class="mb-3">
                        <strong>Slug:</strong><br>
                        <code>/blog/${blog.slug}</code>
                    </div>
                    <div class="mb-3">
                        <strong>Author:</strong><br>
                        ${blog.authorName}
                    </div>
                    <div class="mb-3">
                        <strong>Status:</strong><br>
                        <c:choose>
                            <c:when test="${blog.status == 'PUBLISHED'}">
                                <span class="badge badge-success">Published</span>
                            </c:when>
                            <c:when test="${blog.status == 'DRAFT'}">
                                <span class="badge badge-warning">Draft</span>
                            </c:when>
                            <c:when test="${blog.status == 'ARCHIVED'}">
                                <span class="badge badge-secondary">Archived</span>
                            </c:when>
                        </c:choose>
                    </div>
                    <div class="mb-3">
                        <strong>Created:</strong><br>
                        <fmt:formatDate value="${blog.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                    </div>
                    <div class="mb-3">
                        <strong>Updated:</strong><br>
                        <fmt:formatDate value="${blog.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                    </div>
                    <div class="mb-3">
                        <strong>Total Comments:</strong><br>
                        ${blog.commentCount}
                    </div>
                </div>
            </div>
            
            <!-- Quick Actions -->
            <div class="card mt-3">
                <div class="card-header">
                    <h5 class="mb-0">Quick Actions</h5>
                </div>
                <div class="card-body">
                    <a href="${pageContext.request.contextPath}/admin/blogs?action=edit&id=${blog.id}" 
                       class="btn btn-warning btn-block">
                        <i class="fas fa-edit"></i> Edit Blog
                    </a>
                    
                    <c:choose>
                        <c:when test="${blog.status == 'DRAFT'}">
                            <form method="post" action="${pageContext.request.contextPath}/admin/blogs" 
                                  class="mt-2">
                                <input type="hidden" name="action" value="publish">
                                <input type="hidden" name="id" value="${blog.id}">
                                <button type="submit" class="btn btn-success btn-block">
                                    <i class="fas fa-check"></i> Publish Blog
                                </button>
                            </form>
                        </c:when>
                        <c:when test="${blog.status == 'PUBLISHED'}">
                            <form method="post" action="${pageContext.request.contextPath}/admin/blogs" 
                                  class="mt-2">
                                <input type="hidden" name="action" value="unpublish">
                                <input type="hidden" name="id" value="${blog.id}">
                                <button type="submit" class="btn btn-warning btn-block">
                                    <i class="fas fa-eye-slash"></i> Unpublish
                                </button>
                            </form>
                        </c:when>
                    </c:choose>
                    
                    <c:if test="${blog.status != 'ARCHIVED'}">
                        <button type="button" class="btn btn-danger btn-block mt-2"
                                onclick="confirmArchive()">
                            <i class="fas fa-archive"></i> Archive Blog
                        </button>
                    </c:if>
                    
                    <a href="${pageContext.request.contextPath}/BlogDetailServlet?slug=${blog.slug}" 
                       target="_blank" class="btn btn-info btn-block mt-2">
                        <i class="fas fa-external-link-alt"></i> View on Site
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Archive Confirmation Modal -->
<div class="modal fade" id="archiveModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Archive</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to archive this blog?</p>
                <p class="font-weight-bold">${blog.title}</p>
                <p class="text-warning">This action will hide the blog from public view.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/admin/blogs" 
                      style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="${blog.id}">
                    <button type="submit" class="btn btn-danger">Archive</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function confirmArchive() {
    $('#archiveModal').modal('show');
}

function updateCommentStatus(commentId, status) {
    if (confirm('Are you sure you want to update this comment status?')) {
        // Create a form and submit
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/admin/comments';
        
        var actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'updateStatus';
        form.appendChild(actionInput);
        
        var idInput = document.createElement('input');
        idInput.type = 'hidden';
        idInput.name = 'commentId';
        idInput.value = commentId;
        form.appendChild(idInput);
        
        var statusInput = document.createElement('input');
        statusInput.type = 'hidden';
        statusInput.name = 'status';
        statusInput.value = status;
        form.appendChild(statusInput);
        
        var blogIdInput = document.createElement('input');
        blogIdInput.type = 'hidden';
        blogIdInput.name = 'blogId';
        blogIdInput.value = '${blog.id}';
        form.appendChild(blogIdInput);
        
        document.body.appendChild(form);
        form.submit();
    }
}
</script>
