<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!-- Add this style section to admin-blogs-content.jsp at the beginning -->
<style>
    .filter-form {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        flex-wrap: wrap;
        gap: 15px;
    }
    
    .filter-group {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        align-items: center;
        flex: 1;
    }
    
    .form-group {
        margin-bottom: 0 !important;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .form-group label {
        margin-bottom: 0;
        white-space: nowrap;
    }
    
    @media (max-width: 768px) {
        .filter-form {
            flex-direction: column;
        }
        
        .filter-group {
            width: 100%;
        }
        
        .form-group {
            width: 100%;
            flex-direction: column;
            align-items: stretch;
        }
        
        .form-group label {
            text-align: left;
            margin-bottom: 5px;
        }
        
        .form-group input,
        .form-group select {
            width: 100% !important;
        }
        
        .btn-success {
            width: 100%;
            margin-top: 10px;
        }
    }
    
    .table-container h4 {
        margin-bottom: 0;
    }
    
    .pagination-info {
        font-size: 14px;
        color: #6c757d;
    }
</style>
<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item active">Blog Management</li>
        </ol>
    </nav>
    

    
    <!-- Alert Messages -->
    <c:if test="${not empty sessionScope.success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            ${sessionScope.success}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
        <c:remove var="success" scope="session"/>
    </c:if>
    
    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${sessionScope.error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
        <c:remove var="error" scope="session"/>
    </c:if>
    
    <!-- Filter Section -->
    <div class="card mb-4">
        <div class="card-body">
                     <form id="blogFilterForm" method="get" action="${pageContext.request.contextPath}/admin/blogs" class="form-inline justify-content-between">                
                    <div class="d-flex flex-wrap">
                    <div class="form-group mr-3">
                        <label class="mr-2">Status:</label>
                        <select name="status" class="form-control">
                            <option value="">All Status</option>
                            <option value="DRAFT" ${status == 'DRAFT' ? 'selected' : ''}>Draft</option>
                            <option value="PUBLISHED" ${status == 'PUBLISHED' ? 'selected' : ''}>Published</option>
                            <option value="ARCHIVED" ${status == 'ARCHIVED' ? 'selected' : ''}>Archived</option>
                        </select>
                    </div>
                    
                    <div class="form-group mr-3">
                        <label class="mr-2">Author:</label>
                        <select name="authorId" class="form-control">
                            <option value="">All Authors</option>
                            <c:forEach var="author" items="${authors}">
                                <option value="${author.id}" ${authorId == author.id ? 'selected' : ''}>
                                    ${author.fullName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                      <div class="form-group mr-3">
                        <label class="mr-2">Search:</label>
                        <input type="text" name="search" class="form-control" 
                               placeholder="Title or content..." value="${search}">
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i> Search
                    </button>
                    
                    <c:if test="${not empty search || not empty status || not empty authorId}">
                        <a href="${pageContext.request.contextPath}/admin/blogs" 
                           class="btn btn-secondary ml-2">
                            <i class="fas fa-times"></i> Clear
                        </a>
                    </c:if>
                </div>
                
                <a href="${pageContext.request.contextPath}/admin/blogs?action=add" class="btn btn-success">
                    <i class="fas fa-plus"></i> Add New Blog
                </a>
            </form>
        </div>
    </div>
  
    <!-- Blogs Table -->
    <div class="table-container">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4>Blog List</h4>
            <span class="text-muted">
                Showing ${(currentPage - 1) * recordsPerPage + 1} - 
                ${Math.min(currentPage * recordsPerPage, totalRecords)} of ${totalRecords} blogs
            </span>
        </div>
        
        <c:choose>
            <c:when test="${not empty blogs}">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th width="5%">#</th>
               
                                <th width="25%">Title</th>
                                <th width="15%">Author</th>
                                <th width="10%">Status</th>
                                <th width="10%">Comments</th>
                                <th width="15%">Created Date</th>
                                <th width="10%">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="blog" items="${blogs}" varStatus="status">
                                <tr>
                                    <td>${(currentPage - 1) * recordsPerPage + status.count}</td>
                                   
                                    <td>
                                        <strong>${blog.title}</strong>
                                        <br>
                                        <small class="text-muted">
                                            <i class="fas fa-link"></i> ${blog.slug}
                                        </small>
                                    </td>
                                    <td>${blog.authorName}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${blog.status == 'PUBLISHED'}">
                                                <span class="badge badge-success">${blog.status}</span>
                                            </c:when>
                                            <c:when test="${blog.status == 'DRAFT'}">
                                                <span class="badge badge-warning">${blog.status}</span>
                                            </c:when>
                                            <c:when test="${blog.status == 'ARCHIVED'}">
                                                <span class="badge badge-secondary">${blog.status}</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge badge-info">${blog.commentCount}</span>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${blog.createdAt}" pattern="dd/MM/yyyy"/>
                                        <br>
                                        <small class="text-muted">
                                            <fmt:formatDate value="${blog.createdAt}" pattern="HH:mm"/>
                                        </small>
                                    </td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <a href="${pageContext.request.contextPath}/admin/blogs?action=view&id=${blog.id}" 
                                               class="btn btn-info" title="View">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/blogs?action=edit&id=${blog.id}" 
                                               class="btn btn-warning" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <c:if test="${blog.status != 'ARCHIVED'}">
                                                <button type="button" class="btn btn-danger" 
                                                        onclick="confirmDelete(${blog.id}, '${blog.title}')"
                                                        title="Archive">
                                                    <i class="fas fa-archive"></i>
                                                </button>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" 
                                   href="?page=${currentPage - 1}&search=${search}&status=${status}&authorId=${authorId}">
                                    Previous
                                </a>
                            </li>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" 
                                       href="?page=${i}&search=${search}&status=${status}&authorId=${authorId}">
                                        ${i}
                                    </a>
                                </li>
                            </c:forEach>
                            
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" 
                                   href="?page=${currentPage + 1}&search=${search}&status=${status}&authorId=${authorId}">
                                    Next
                                </a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5">
                    <i class="fas fa-blog fa-4x text-muted mb-3"></i>
                    <h4 class="text-muted">No blogs found</h4>
                    <p class="text-muted">Try adjusting your search criteria or add a new blog.</p>
                    <a href="${pageContext.request.contextPath}/admin/blogs?action=add" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Add New Blog
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
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
                <p class="font-weight-bold" id="blogTitle"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/admin/blogs" 
                      style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="deleteId">
                    <button type="submit" class="btn btn-danger">Archive</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
function confirmDelete(id, title) {
    document.getElementById('deleteId').value = id;
    document.getElementById('blogTitle').textContent = title;
    $('#deleteModal').modal('show');
}
</script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        var form = document.getElementById('blogFilterForm');
        if (!form) return;

        form.querySelectorAll('select').forEach(function (select) {
            select.addEventListener('change', function () {
                form.submit();
            });
        });

      
    });
</script>