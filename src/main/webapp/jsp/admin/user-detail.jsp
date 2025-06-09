<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/users">User Management</a></li>
            <li class="breadcrumb-item active">User Details</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">User Details</h1>
        <div>
            <a href="${pageContext.request.contextPath}/admin/users?action=form&id=${user.id}" 
               class="btn btn-warning">
                <i class="fas fa-edit"></i> Edit
            </a>
            <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to List
            </a>
        </div>
    </div>
    
    <div class="row">
        <!-- User Information -->
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Profile Information</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-3">
                            <div class="text-center">
                                <div class="avatar-circle mx-auto mb-3" style="width: 100px; height: 100px; background: #5a2b81; color: white; display: flex; align-items: center; justify-content: center; border-radius: 50%; font-size: 36px;">
                                    ${user.fullName.substring(0, 1).toUpperCase()}
                                </div>
                                <h5>${user.fullName}</h5>
                                <span class="badge ${user.roleBadgeClass}">${user.roleDisplayName}</span>
                            </div>
                        </div>
                        <div class="col-md-9">
                            <table class="table table-borderless">
                                <tr>
                                    <th width="30%">Username:</th>
                                    <td>${user.username}</td>
                                </tr>
                                <tr>
                                    <th>Email:</th>
                                    <td>
                                        <a href="mailto:${user.email}">${user.email}</a>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Phone:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty user.phone}">
                                                <a href="tel:${user.phone}">${user.phone}</a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not provided</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Status:</th>
                                    <td>
                                        <span class="badge ${user.statusBadgeClass}">
                                            ${user.statusDisplayName}
                                        </span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Created Date:</th>
                                    <td>
                                        <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Last Updated:</th>
                                    <td>
                                        <fmt:formatDate value="${user.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Activity Summary -->
            <div class="card mt-4">
                <div class="card-header">
                    <h5 class="mb-0">Activity Summary</h5>
                </div>
                <div class="card-body">
                    <div class="row text-center">
                        <div class="col-md-4">
                            <div class="stat-box">
                                <h3 class="text-primary">${user.totalBookings}</h3>
                                <p class="mb-0">Total Bookings</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="stat-box">
                                <h3 class="text-success">0</h3>
                                <p class="mb-0">Active Bookings</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="stat-box">
                                <h3 class="text-info">0</h3>
                                <p class="mb-0">Completed Stays</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Quick Actions</h5>
                </div>
                <div class="card-body">
                    <a href="${pageContext.request.contextPath}/admin/users?action=form&id=${user.id}" 
                       class="btn btn-warning btn-block mb-2">
                        <i class="fas fa-edit"></i> Edit Profile
                    </a>
                    
                    <c:if test="${user.status}">
                        <button class="btn btn-info btn-block mb-2" onclick="resetPassword(${user.id})">
                            <i class="fas fa-key"></i> Reset Password
                        </button>
                    </c:if>
                    
                    <c:if test="${user.id != sessionScope.user.id}">
                        <c:choose>
                            <c:when test="${user.status}">
                                <button onclick="confirmDelete(${user.id}, '${user.fullName}')" 
                                        class="btn btn-danger btn-block">
                                    <i class="fas fa-trash"></i> Delete User
                                </button>
                            </c:when>
                            <c:otherwise>
                                <button onclick="confirmRestore(${user.id}, '${user.fullName}')" 
                                        class="btn btn-success btn-block">
                                    <i class="fas fa-undo"></i> Restore User
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </c:if>
                </div>
            </div>
            
            <!-- Recent Activity -->
            <div class="card mt-3">
                <div class="card-header">
                    <h5 class="mb-0">Recent Activity</h5>
                </div>
                <div class="card-body">
                    <p class="text-muted text-center">No recent activity</p>
                </div>
            </div>
        </div>
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

<style>
.stat-box {
    padding: 20px;
    border-radius: 8px;
    background: #f8f9fa;
}

.stat-box h3 {
    margin-bottom: 10px;
    font-weight: 600;
}
</style>

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

function resetPassword(userId) {
    if (confirm('Are you sure you want to reset the password for this user?')) {
        // Implement password reset functionality
        alert('Password reset functionality to be implemented');
    }
}
</script>