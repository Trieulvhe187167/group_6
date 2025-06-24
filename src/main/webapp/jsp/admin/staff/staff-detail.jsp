<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
.stat-box {
    padding: 20px;
    border-radius: 8px;
    background: #f8f9fa;
    margin-bottom: 10px;
}

.stat-box h3 {
    margin-bottom: 10px;
    font-weight: 600;
}

.avatar-circle {
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.progress {
    font-size: 12px;
    font-weight: 600;
}

.dropdown-menu {
    min-width: 100%;
}

.dropdown-item {
    padding: 8px 16px;
    transition: all 0.3s ease;
}

.dropdown-item:hover {
    background-color: #f8f9fa;
    transform: translateX(5px);
}

.dropdown-item i {
    width: 20px;
    margin-right: 8px;
}

.pending-changes-badge {
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.7; }
    100% { opacity: 1; }
}
</style>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/staff">Staff Management</a></li>
            <li class="breadcrumb-item active">Staff Details</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">Staff Details</h1>
        <div>
            <a href="${pageContext.request.contextPath}/admin/staff?action=form&id=${staff.id}" 
               class="btn btn-warning">
                <i class="fas fa-edit"></i> Edit Staff
            </a>
            <a href="${pageContext.request.contextPath}/admin/staff" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to List
            </a>
        </div>
    </div>
    
    <!-- Self-account protection alert -->
    <c:if test="${staff.id == sessionScope.user.id}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <i class="fas fa-info-circle"></i>
            <strong>Note:</strong> This is your current account. Some actions may be restricted for security reasons.
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <!-- Alert for verification status -->
    <c:if test="${not empty param.verificationSent}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle"></i>
            <strong>Verification Sent!</strong> The staff member will receive an email to approve the requested changes.
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <div class="row">
        <!-- Staff Information -->
        <div class="col-md-8">
            <!-- Profile Information -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-user-tie"></i> Profile Information</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-3 text-center">
                            <div class="avatar-circle mx-auto mb-3" style="width: 100px; height: 100px; background: ${staff.roleBadgeClass == 'badge-danger' ? '#dc3545' : staff.roleBadgeClass == 'badge-primary' ? '#007bff' : staff.roleBadgeClass == 'badge-info' ? '#17a2b8' : '#ffc107'}; color: white; display: flex; align-items: center; justify-content: center; border-radius: 50%; font-size: 36px; font-weight: bold;">
                                ${staff.initial}
                            </div>
                            <h5>${staff.fullName}</h5>
                            <span class="badge ${staff.roleBadgeClass} mb-2">${staff.roleDisplayName}</span>
                            <c:if test="${staff.id == sessionScope.user.id}">
                                <br><span class="badge badge-info">Current User</span>
                            </c:if>
                        </div>
                        <div class="col-md-9">
                            <table class="table table-borderless">
                                <tr>
                                    <th width="30%">Username:</th>
                                    <td><code>${staff.username}</code></td>
                                </tr>
                                <tr>
                                    <th>Email:</th>
                                    <td>
                                        <a href="mailto:${staff.email}">${staff.email}</a>
                                        <button class="btn btn-sm btn-outline-primary ml-2" 
                                                onclick="requestQuickChange('email', '${staff.email}', ${staff.id}, 'staff')"
                                                title="Request email change">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Phone:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty staff.phone}">
                                                <a href="tel:${staff.phone}">${staff.phone}</a>
                                                <button class="btn btn-sm btn-outline-primary ml-2" 
                                                        onclick="requestQuickChange('phone', '${staff.phone}', ${staff.id}, 'staff')"
                                                        title="Request phone change">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not provided</span>
                                                <button class="btn btn-sm btn-outline-success ml-2" 
                                                        onclick="requestQuickChange('phone', '', ${staff.id}, 'staff')"
                                                        title="Add phone number">
                                                    <i class="fas fa-plus"></i>
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Role:</th>
                                    <td>
                                        <span class="badge ${staff.roleBadgeClass} p-2">
                                            ${staff.roleDisplayName}
                                        </span>
                                        <c:if test="${staff.role == 'ADMIN'}">
                                            <small class="text-muted ml-2">
                                                <i class="fas fa-shield-alt"></i> Protected role
                                            </small>
                                        </c:if>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Department:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty staff.department}">
                                                ${staff.department}
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not assigned</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Hire Date:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty staff.hireDate}">
                                                <fmt:formatDate value="${staff.hireDate}" pattern="dd/MM/yyyy"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not specified</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Salary:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${staff.salary > 0}">
                                                <span class="badge badge-success">${staff.formattedSalary}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not specified</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Status:</th>
                                    <td>
                                        <span class="badge ${staff.statusBadgeClass}">
                                            ${staff.statusDisplayName}
                                        </span>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Work Performance -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-chart-line"></i> Work Performance</h5>
                </div>
                <div class="card-body">
                    <div class="row text-center">
                        <div class="col-md-4">
                            <div class="stat-box">
                                <h3 class="text-primary">${staff.totalBookings}</h3>
                                <p class="mb-0">
                                    <c:choose>
                                        <c:when test="${staff.role == 'RECEPTIONIST'}">Bookings Created</c:when>
                                        <c:when test="${staff.role == 'ROOM_INSPECTOR'}">Inspections Done</c:when>
                                        <c:when test="${staff.role == 'HOUSEKEEPER'}">Rooms Cleaned</c:when>
                                        <c:otherwise>Tasks Completed</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="stat-box">
                                <h3 class="text-success">
                                    <c:choose>
                                        <c:when test="${not empty staff.hireDate}">
                                            <fmt:formatDate value="${staff.hireDate}" pattern="yyyy"/>
                                        </c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </h3>
                                <p class="mb-0">Year Joined</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="stat-box">
                                <h3 class="text-info">
                                    <c:choose>
                                        <c:when test="${not empty staff.hireDate}">
                                            <c:set var="today" value="<%= new java.util.Date() %>" />
                                            <fmt:formatDate value="${today}" pattern="yyyy" var="currentYear"/>
                                            <fmt:formatDate value="${staff.hireDate}" pattern="yyyy" var="hireYear"/>
                                            ${currentYear - hireYear}
                                        </c:when>
                                        <c:otherwise>N/A</c:otherwise>
                                    </c:choose>
                                </h3>
                                <p class="mb-0">Years of Service</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Role Responsibilities -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-tasks"></i> Role Responsibilities</h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${staff.role == 'ADMIN'}">
                            <ul class="list-unstyled">
                                <li><i class="fas fa-check text-success mr-2"></i> Full system administration access</li>
                                <li><i class="fas fa-check text-success mr-2"></i> User and role management</li>
                                <li><i class="fas fa-check text-success mr-2"></i> System configuration and settings</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Financial reports and analytics</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Staff management and scheduling</li>
                            </ul>
                        </c:when>
                        <c:when test="${staff.role == 'RECEPTIONIST'}">
                            <ul class="list-unstyled">
                                <li><i class="fas fa-check text-success mr-2"></i> Guest check-in and check-out</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Reservation management</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Customer service and support</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Payment processing</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Front desk operations</li>
                            </ul>
                        </c:when>
                        <c:when test="${staff.role == 'HOUSEKEEPER'}">
                            <ul class="list-unstyled">
                                <li><i class="fas fa-check text-success mr-2"></i> Room cleaning and maintenance</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Inventory management</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Laundry services</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Guest amenity restocking</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Housekeeping task coordination</li>
                            </ul>
                        </c:when>
                        <c:when test="${staff.role == 'ROOM_INSPECTOR'}">
                            <ul class="list-unstyled">
                                <li><i class="fas fa-check text-success mr-2"></i> Room quality inspections</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Damage assessment and reporting</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Minibar and amenity auditing</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Maintenance issue identification</li>
                                <li><i class="fas fa-check text-success mr-2"></i> Guest satisfaction monitoring</li>
                            </ul>
                        </c:when>
                    </c:choose>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions & Info -->
        <div class="col-md-4">
            <!-- Quick Actions -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-bolt"></i> Quick Actions</h5>
                </div>
                <div class="card-body">
                    <a href="${pageContext.request.contextPath}/admin/staff?action=form&id=${staff.id}" 
                       class="btn btn-warning btn-block mb-2">
                        <i class="fas fa-edit"></i> Edit Profile
                    </a>
                    
                    <c:if test="${staff.role == 'RECEPTIONIST'}">
                        <a href="${pageContext.request.contextPath}/admin/bookings?createdBy=${staff.id}" 
                           class="btn btn-info btn-block mb-2">
                            <i class="fas fa-calendar-check"></i> View Created Bookings
                        </a>
                    </c:if>
                    
                    <c:if test="${staff.role == 'HOUSEKEEPER'}">
                        <a href="${pageContext.request.contextPath}/admin/housekeeping?assignedTo=${staff.id}" 
                           class="btn btn-info btn-block mb-2">
                            <i class="fas fa-broom"></i> View Assigned Tasks
                        </a>
                    </c:if>
                    
                    <c:if test="${staff.role == 'ROOM_INSPECTOR'}">
                        <a href="${pageContext.request.contextPath}/admin/inspections?inspector=${staff.id}" 
                           class="btn btn-info btn-block mb-2">
                            <i class="fas fa-clipboard-check"></i> View Inspections
                        </a>
                    </c:if>
                    
                    <!-- VERIFICATION SYSTEM BUTTONS -->
                    <div class="dropdown">
                        <button class="btn btn-secondary btn-block dropdown-toggle mb-2" type="button" 
                                id="staffChangeRequestDropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <i class="fas fa-shield-alt"></i> Secure Account Changes
                        </button>
                        <div class="dropdown-menu w-100" aria-labelledby="staffChangeRequestDropdown">
                            <a class="dropdown-item" href="#" onclick="requestChange('email', ${staff.id}, 'staff')">
                                <i class="fas fa-envelope text-primary"></i> Change Email Address
                            </a>
                            <a class="dropdown-item" href="#" onclick="requestChange('phone', ${staff.id}, 'staff')">
                                <i class="fas fa-phone text-success"></i> Change Phone Number
                            </a>
                            <a class="dropdown-item" href="#" onclick="requestChange('password', ${staff.id}, 'staff')">
                                <i class="fas fa-key text-warning"></i> Reset Password
                            </a>
                        </div>
                    </div>
                    
                    <c:if test="${staff.status}">
                        <button class="btn btn-secondary btn-block mb-2" onclick="resetPassword(${staff.id})">
                            <i class="fas fa-key"></i> Reset Password (Direct)
                        </button>
                    </c:if>
                    
                    <!-- Only show delete button if it's not the current logged-in user -->
                    <c:if test="${staff.status && staff.id != sessionScope.user.id}">
                        <button onclick="confirmDelete(${staff.id}, '${staff.fullName}')" 
                                class="btn btn-danger btn-block">
                            <i class="fas fa-trash"></i> Delete Staff
                        </button>
                    </c:if>
                    
                    <!-- Show protection message for current user -->
                    <c:if test="${staff.id == sessionScope.user.id}">
                        <div class="alert alert-warning mt-2">
                            <i class="fas fa-shield-alt"></i>
                            <small>You cannot delete your own account for security reasons.</small>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Pending Changes Section for Staff -->
            <c:if test="${not empty pendingChanges}">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-clock text-warning"></i> Pending Changes
                        <span class="badge badge-warning ml-2">${pendingChanges.size()}</span>
                    </h5>
                </div>
                <div class="card-body">
                    <c:forEach var="change" items="${pendingChanges}">
                        <div class="alert alert-${change.status == 'PENDING' ? 'warning' : (change.status == 'APPROVED' ? 'success' : 'danger')} mb-2">
                            <div class="d-flex justify-content-between align-items-start">
                                <div class="flex-grow-1">
                                    <div class="d-flex align-items-center mb-1">
                                        <i class="fas ${change.changeType == 'EMAIL' ? 'fa-envelope' : (change.changeType == 'PHONE' ? 'fa-phone' : 'fa-key')} mr-2"></i>
                                        <strong>${change.changeTypeDisplayName}</strong>
                                        <c:if test="${change.status == 'PENDING' && change.hoursUntilExpiry < 12}">
                                            <span class="badge badge-danger ml-2">Urgent</span>
                                        </c:if>
                                    </div>
                                    <small class="text-muted d-block">
                                        <i class="fas fa-calendar-alt mr-1"></i>
                                        Requested: <fmt:formatDate value="${change.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </small>
                                    <c:if test="${change.status == 'PENDING'}">
                                        <small class="text-muted d-block">
                                            <i class="fas fa-clock mr-1"></i>
                                            Expires: <fmt:formatDate value="${change.tokenExpiry}" pattern="dd/MM/yyyy HH:mm"/>
                                            <c:if test="${change.hoursUntilExpiry < 12}">
                                                <span class="text-danger font-weight-bold">(${change.hoursUntilExpiry}h left)</span>
                                            </c:if>
                                        </small>
                                    </c:if>
                                </div>
                                <span class="badge ${change.statusBadgeClass}">${change.status}</span>
                            </div>
                            <c:if test="${not empty change.changeReason}">
                                <div class="mt-2">
                                    <small><strong>Reason:</strong> ${change.changeReason}</small>
                                </div>
                            </c:if>
                            <c:if test="${change.status == 'PENDING'}">
                                <div class="mt-2">
                                    <button class="btn btn-sm btn-outline-info" onclick="sendReminder(${change.id})">
                                        <i class="fas fa-bell"></i> Send Reminder
                                    </button>
                                    <button class="btn btn-sm btn-outline-secondary ml-1" onclick="viewChangeDetails('${change.verificationToken}')">
                                        <i class="fas fa-eye"></i> View Link
                                    </button>
                                    <c:if test="${staff.id == sessionScope.user.id}">
                                        <a href="${pageContext.request.contextPath}/verify-change?token=${change.verificationToken}" 
                                           class="btn btn-sm btn-outline-primary ml-1" target="_blank">
                                            <i class="fas fa-external-link-alt"></i> Open Verification
                                        </a>
                                    </c:if>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </div>
            </c:if>

            <!-- Employment Information -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-briefcase"></i> Employment Information</h5>
                </div>
                <div class="card-body">
                    <table class="table table-sm table-borderless">
                        <tr>
                            <th>Employee ID:</th>
                            <td class="text-right">
                                <code>EMP${String.format("%04d", staff.id)}</code>
                            </td>
                        </tr>
                        <tr>
                            <th>Department:</th>
                            <td class="text-right">
                                <c:choose>
                                    <c:when test="${not empty staff.department}">
                                        <span class="badge badge-primary">${staff.department}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Not assigned</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>Employment Type:</th>
                            <td class="text-right">
                                <span class="badge badge-success">Full-time</span>
                            </td>
                        </tr>
                        <tr>
                            <th>Shift:</th>
                            <td class="text-right">
                                <c:choose>
                                    <c:when test="${staff.role == 'RECEPTIONIST'}">
                                        <span class="badge badge-info">24/7 Rotation</span>
                                    </c:when>
                                    <c:when test="${staff.role == 'HOUSEKEEPER'}">
                                        <span class="badge badge-info">Day Shift</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-info">Regular Hours</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <!-- Account Information -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-info-circle"></i> Account Information</h5>
                </div>
                <div class="card-body">
                    <table class="table table-sm table-borderless">
                        <tr>
                            <th>Joined:</th>
                            <td class="text-right">
                                <fmt:formatDate value="${staff.createdAt}" pattern="dd/MM/yyyy"/>
                            </td>
                        </tr>
                        <tr>
                            <th>Last Updated:</th>
                            <td class="text-right">
                                <fmt:formatDate value="${staff.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                        </tr>
                        <tr>
                            <th>Account Status:</th>
                            <td class="text-right">
                                <span class="badge ${staff.statusBadgeClass}">
                                    ${staff.statusDisplayName}
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <th>Profile Complete:</th>
                            <td class="text-right">
                                <div class="progress" style="height: 20px;">
                                    <div class="progress-bar bg-success" role="progressbar" 
                                         style="width: ${staff.profileCompletionPercentage}%"
                                         aria-valuenow="${staff.profileCompletionPercentage}" 
                                         aria-valuemin="0" aria-valuemax="100">
                                        ${staff.profileCompletionPercentage}%
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Quick Change Modal -->
<div class="modal fade" id="quickChangeModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Quick Change Request</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="quickChangeForm">
                    <input type="hidden" id="quickChangeType" name="changeType">
                    <input type="hidden" id="quickUserId" name="userId" value="${staff.id}">
                    <input type="hidden" id="quickUserType" name="userType" value="staff">
                    
                    <div class="form-group">
                        <label id="quickChangeLabel">New Value:</label>
                        <input type="text" class="form-control" id="quickNewValue" name="newValue" required>
                        <small class="form-text text-muted" id="quickChangeHelp"></small>
                    </div>
                    
                    <div class="form-group">
                        <label>Reason for Change:</label>
                        <textarea class="form-control" id="quickChangeReason" name="reason" rows="3" 
                                  placeholder="Please provide a reason for this change..." required></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" onclick="submitQuickChange()">
                    <i class="fas fa-paper-plane"></i> Send Verification Email
                </button>
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
                <p>Are you sure you want to delete staff member "<strong><span id="deleteStaffName"></span></strong>"?</p>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i>
                    This action will move the staff member to trash. You can restore them later if needed.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <a id="deleteConfirmLink" href="#" class="btn btn-danger">
                    <i class="fas fa-trash"></i> Delete Staff
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Change Details Modal -->
<div class="modal fade" id="changeDetailsModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Verification Link</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Staff member can use this link to approve or reject the change:</p>
                <div class="input-group">
                    <input type="text" class="form-control" id="verificationLink" readonly>
                    <div class="input-group-append">
                        <button class="btn btn-outline-secondary" onclick="copyToClipboard()">
                            <i class="fas fa-copy"></i> Copy
                        </button>
                    </div>
                </div>
                <small class="text-muted">This link has also been sent to the staff member's email address.</small>
            </div>
        </div>
    </div>
</div>

<script>
// Function to initiate change request
function requestChange(changeType, userId, userType) {
    var changeTypeDisplay = {
        'email': 'Email Address',
        'phone': 'Phone Number', 
        'password': 'Password'
    }[changeType];
    
    var confirmMessage = 'Are you sure you want to request a ' + changeTypeDisplay + ' change?\n\n' +
                        'This will send a verification email to the staff member for approval.';
    
    if (confirm(confirmMessage)) {
        window.location.href = '${pageContext.request.contextPath}/admin/change-request?action=form&userId=' + 
                              userId + '&type=' + changeType + '&userType=' + userType;
    }
}

// Quick change function
function requestQuickChange(changeType, currentValue, userId, userType) {
    document.getElementById('quickChangeType').value = changeType;
    document.getElementById('quickUserId').value = userId;
    document.getElementById('quickUserType').value = userType;
    
    var label = document.getElementById('quickChangeLabel');
    var input = document.getElementById('quickNewValue');
    var help = document.getElementById('quickChangeHelp');
    
    switch(changeType) {
        case 'email':
            label.textContent = 'New Email Address:';
            input.type = 'email';
            input.value = currentValue;
            input.placeholder = 'Enter new email address';
            help.textContent = 'Staff member will receive verification email at their current address';
            break;
        case 'phone':
            label.textContent = 'New Phone Number:';
            input.type = 'tel';
            input.value = currentValue;
            input.placeholder = 'Enter new phone number (e.g., 0123456789)';
            help.textContent = 'Format: 0123456789 (10 digits starting with 0)';
            break;
        case 'password':
            label.textContent = 'New Password:';
            input.type = 'password';
            input.value = '';
            input.placeholder = 'Enter new password';
            help.textContent = 'Minimum 8 characters with uppercase, lowercase, digit, and special character';
            break;
    }
    
    $('#quickChangeModal').modal('show');
}

// Submit quick change
function submitQuickChange() {
    var form = document.getElementById('quickChangeForm');
    var formData = new FormData(form);
    
    // Validate input
    var changeType = formData.get('changeType');
    var newValue = formData.get('newValue');
    
    if (changeType === 'email' && !newValue.match(/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/)) {
        alert('Please enter a valid email address');
        return;
    }
    
    if (changeType === 'phone' && newValue && !newValue.match(/^0\d{9}$/)) {
        alert('Phone number must start with 0 and be exactly 10 digits');
        return;
    }
    
    if (changeType === 'password' && !newValue.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!]).{8,}$/)) {
        alert('Password must be at least 8 characters with uppercase, lowercase, digit, and special character');
        return;
    }
    
    // Submit form
    var button = event.target;
    button.disabled = true;
    button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending...';
    
    fetch('${pageContext.request.contextPath}/admin/change-request', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=request-' + changeType + '-change&' + 
              'userId=' + formData.get('userId') + '&' +
              'userType=' + formData.get('userType') + '&' +
              'new' + changeType.charAt(0).toUpperCase() + changeType.slice(1) + '=' + encodeURIComponent(newValue) + '&' +
              'reason=' + encodeURIComponent(formData.get('reason'))
    })
    .then(response => {
        if (response.redirected) {
            window.location.href = response.url + '&verificationSent=true';
        } else {
            return response.text();
        }
    })
    .catch(error => {
        alert('Error sending change request: ' + error.message);
    })
    .finally(() => {
        button.disabled = false;
        button.innerHTML = '<i class="fas fa-paper-plane"></i> Send Verification Email';
        $('#quickChangeModal').modal('hide');
    });
}

// Send reminder function
function sendReminder(changeId) {
    if (confirm('Send a reminder email to the staff member about this pending change?')) {
        var button = event.target;
        var originalText = button.innerHTML;
        button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending...';
        button.disabled = true;
        
        fetch('${pageContext.request.contextPath}/admin/change-request', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=send-reminder&changeId=' + changeId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showAlert('success', 'Reminder sent successfully!');
                setTimeout(() => window.location.reload(), 1500);
            } else {
                showAlert('error', 'Failed to send reminder: ' + (data.error || 'Unknown error'));
            }
        })
        .catch(error => {
            showAlert('error', 'Error sending reminder: ' + error.message);
        })
        .finally(() => {
            button.innerHTML = originalText;
            button.disabled = false;
        });
    }
}

// View change details
function viewChangeDetails(token) {
    var link = '${pageContext.request.contextPath}/verify-change?token=' + token;
    document.getElementById('verificationLink').value = link;
    $('#changeDetailsModal').modal('show');
}

// Copy to clipboard
function copyToClipboard() {
    var input = document.getElementById('verificationLink');
    input.select();
    document.execCommand('copy');
    showAlert('success', 'Verification link copied to clipboard!');
}

// Show alert function
function showAlert(type, message) {
    var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
    var icon = type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-circle';
    
    var alertHtml = '<div class="alert ' + alertClass + ' alert-dismissible fade show" role="alert">' +
                   '<i class="' + icon + '"></i> ' + message +
                   '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' +
                   '</div>';
    
    $('.container-fluid').prepend(alertHtml);
    
    setTimeout(function() {
        $('.alert').fadeOut('slow');
    }, 5000);
}

// Other existing functions
function confirmDelete(staffId, staffName) {
    document.getElementById('deleteStaffName').textContent = staffName;
    document.getElementById('deleteConfirmLink').href = 
        '${pageContext.request.contextPath}/admin/staff?action=delete&id=' + staffId;
    $('#deleteModal').modal('show');
}

function resetPassword(staffId) {
    if (confirm('Are you sure you want to reset the password for this staff member?')) {
        alert('Password reset functionality to be implemented');
    }
}
</script>