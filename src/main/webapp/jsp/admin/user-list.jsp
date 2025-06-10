<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">User Management</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">${isTrashView ? 'Deleted Users' : 'User Management'}</h1>
        <div>
            <c:if test="${!isTrashView}">
                <a href="${pageContext.request.contextPath}/admin/users?action=trash" class="btn btn-secondary">
                    <i class="fas fa-trash"></i> View Trash
                </a>
            </c:if>
            <c:if test="${isTrashView}">
                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-primary">
                    <i class="fas fa-arrow-left"></i> Back to Users
                </a>
            </c:if>
            <c:if test="${!isTrashView}">
                <a href="${pageContext.request.contextPath}/admin/users?action=form" class="btn btn-success">
                    <i class="fas fa-plus"></i> Add New User
                </a>
            </c:if>
        </div>
    </div>
    
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
    
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <!-- Filters and Search -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/users" class="form-inline">
                <c:if test="${isTrashView}">
                    <input type="hidden" name="action" value="trash">
                </c:if>
                
                <!-- Role Filter -->
                <div class="form-group mr-3">
                    <label class="mr-2">Role:</label>
                    <select name="role" class="form-control" onchange="this.form.submit()">
                        <option value="ALL" ${roleFilter == 'ALL' ? 'selected' : ''}>All Roles</option>
                        <option value="ADMIN" ${roleFilter == 'ADMIN' ? 'selected' : ''}>Admin</option>
                        <option value="RECEPTIONIST" ${roleFilter == 'RECEPTIONIST' ? 'selected' : ''}>Receptionist</option>
                        <option value="HOUSEKEEPER" ${roleFilter == 'HOUSEKEEPER' ? 'selected' : ''}>Housekeeper</option>
                        <option value="GUEST" ${roleFilter == 'GUEST' ? 'selected' : ''}>Guest</option>
                    </select>
                </div>
                
                <!-- Search -->
                <c:if test="${!isTrashView}">
                    <div class="form-group mr-3">
                        <label class="mr-2">Search:</label>
                        <input type="text" name="search" class="form-control" 
                               placeholder="Name, email, phone..." value="${searchKeyword}">
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i> Search
                    </button>
                    <c:if test="${not empty searchKeyword}">
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary ml-2">
                            <i class="fas fa-times"></i> Clear
                        </a>
                    </c:if>
                </c:if>
            </form>
        </div>
    </div>
    
    <!-- Users Table -->
    <div class="table-container">
        <c:choose>
            <c:when test="${not empty users}">
                <div class="mb-3">
                    <small class="text-muted">
                        Showing ${(currentPage - 1) * 5 + 1} - 
                        ${currentPage * 5 > totalRecords ? totalRecords : currentPage * 5} 
                        of ${totalRecords} users
                    </small>
                </div>
                
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Total Bookings</th>
                            <th>Created Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="user" items="${users}" varStatus="status">
                            <tr>
                                <td>${(currentPage - 1) * 5 + status.index + 1}</td>
                                <td>${user.username}</td>
                                <td>${user.fullName}</td>
                                <td>${user.email}</td>
                                <td>${user.phone}</td>
                                <td>
                                    <span class="badge ${user.roleBadgeClass}">
                                        ${user.roleDisplayName}
                                    </span>
                                </td>
                                <td>
                                    <span class="badge ${user.statusBadgeClass}">
                                        ${user.statusDisplayName}
                                    </span>
                                </td>
                                <td>${user.totalBookings}</td>
                                <td>
                                    <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy"/>
                                </td>
                                <td>
                                    <c:if test="${!isTrashView}">
                                        <a href="${pageContext.request.contextPath}/admin/users?action=view&id=${user.id}" 
                                           class="btn btn-sm btn-info" title="View">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/users?action=form&id=${user.id}" 
                                           class="btn btn-sm btn-warning" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <c:if test="${user.id != sessionScope.user.id}">
                                            <button onclick="confirmDelete(${user.id}, '${user.fullName}')" 
                                                    class="btn btn-sm btn-danger" title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </c:if>
                                    </c:if>
                                    <c:if test="${isTrashView}">
                                        <button onclick="confirmRestore(${user.id}, '${user.fullName}')" 
                                                class="btn btn-sm btn-success" title="Restore">
                                            <i class="fas fa-undo"></i>
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&role=${roleFilter}&search=${searchKeyword}${isTrashView ? '&action=trash' : ''}">
                                    Previous
                                </a>
                            </li>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <c:if test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="?page=${i}&role=${roleFilter}&search=${searchKeyword}${isTrashView ? '&action=trash' : ''}">
                                            ${i}
                                        </a>
                                    </li>
                                </c:if>
                                <c:if test="${i == currentPage - 3 || i == currentPage + 3}">
                                    <li class="page-item disabled">
                                        <span class="page-link">...</span>
                                    </li>
                                </c:if>
                            </c:forEach>
                            
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&role=${roleFilter}&search=${searchKeyword}${isTrashView ? '&action=trash' : ''}">
                                    Next
                                </a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5">
                    <i class="fas fa-users fa-3x text-muted mb-3"></i>
                    <p class="text-muted">No users found</p>
                    <c:if test="${!isTrashView}">
                        <a href="${pageContext.request.contextPath}/admin/users?action=form" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Add First User
                        </a>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete user "<span id="deleteUserName"></span>"?</p>
                <p class="text-warning">This action will move the user to trash.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <a id="deleteConfirmLink" href="#" class="btn btn-danger">Delete</a>
            </div>
        </div>
    </div>
</div>

<!-- Restore Confirmation Modal -->
<div class="modal fade" id="restoreModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Restore</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to restore user "<span id="restoreUserName"></span>"?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <a id="restoreConfirmLink" href="#" class="btn btn-success">Restore</a>
            </div>
        </div>
    </div>
</div>

<script>
function confirmDelete(userId, userName) {
    document.getElementById('deleteUserName').textContent = userName;
    document.getElementById('deleteConfirmLink').href = 
        '${pageContext.request.contextPath}/admin/users?action=delete&id=' + userId;
    $('#deleteModal').modal('show');
}

function confirmRestore(userId, userName) {
    document.getElementById('restoreUserName').textContent = userName;
    document.getElementById('restoreConfirmLink').href = 
        '${pageContext.request.contextPath}/admin/users?action=restore&id=' + userId;
    $('#restoreModal').modal('show');
}
</script>