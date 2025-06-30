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
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/customers">Customer Management</a></li>
            <li class="breadcrumb-item active">Customer Details</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">Customer Details</h1>
        <div>
            <a href="${pageContext.request.contextPath}/admin/customers?action=form&id=${customer.id}" 
               class="btn btn-warning">
                <i class="fas fa-edit"></i> Edit Customer
            </a>
            <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to List
            </a>
        </div>
    </div>
    
    <!-- Alert for verification status -->
    <c:if test="${not empty param.verificationSent}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle"></i>
            <strong>Verification Sent!</strong> The customer will receive an email to approve the requested changes.
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <div class="row">
        <!-- Customer Information -->
        <div class="col-md-8">
            <!-- Profile Information -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-user"></i> Profile Information</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-3 text-center">
                            <div class="avatar-circle mx-auto mb-3" style="width: 100px; height: 100px; background: #5a2b81; color: white; display: flex; align-items: center; justify-content: center; border-radius: 50%; font-size: 36px; font-weight: bold;">
                                ${customer.initial}
                            </div>
                            <h5>${customer.fullName}</h5>
                            <span class="badge ${customer.membershipBadgeClass} mb-2">${customer.membershipLevel}</span>
                            <c:if test="${customer.isVIP}">
                                <br><span class="badge badge-warning">VIP Customer</span>
                            </c:if>
                        </div>
                        <div class="col-md-9">
                            <table class="table table-borderless">
                                <tr>
                                    <th width="30%">Username:</th>
                                    <td><code>${customer.username}</code></td>
                                </tr>
                                <tr>
                                    <th>Email:</th>
                                    <td>
                                        <a href="mailto:${customer.email}">${customer.email}</a>
                                        <button class="btn btn-sm btn-outline-primary ml-2" 
                                                onclick="requestQuickChange('email', '${customer.email}', ${customer.id}, 'customers')"
                                                title="Request email change">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Phone:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty customer.phone}">
                                                <a href="tel:${customer.phone}">${customer.phone}</a>
                                                <button class="btn btn-sm btn-outline-primary ml-2" 
                                                        onclick="requestQuickChange('phone', '${customer.phone}', ${customer.id}, 'customers')"
                                                        title="Request phone change">
                                                    <i class="fas fa-edit"></i>
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not provided</span>
                                                <button class="btn btn-sm btn-outline-success ml-2" 
                                                        onclick="requestQuickChange('phone', '', ${customer.id}, 'customers')"
                                                        title="Add phone number">
                                                    <i class="fas fa-plus"></i>
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>ID Type:</th>
                                    <td>${customer.idTypeDisplayName}</td>
                                </tr>
                                <tr>
                                    <th>ID Number:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty customer.idNumber}">
                                                <code>${customer.idNumber}</code>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not provided</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Date of Birth:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty customer.dateOfBirth}">
                                                <fmt:formatDate value="${customer.dateOfBirth}" pattern="dd/MM/yyyy"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not provided</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Gender:</th>
                                    <td>${customer.genderDisplayName}</td>
                                </tr>
                                <tr>
                                    <th>Status:</th>
                                    <td>
                                        <span class="badge ${customer.statusBadgeClass}">
                                            ${customer.statusDisplayName}
                                        </span>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Address Information -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-map-marker-alt"></i> Address Information</h5>
                </div>
                <div class="card-body">
                    <table class="table table-borderless">
                        <tr>
                            <th width="30%">Address:</th>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty customer.address}">
                                        ${customer.address}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Not provided</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>City:</th>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty customer.city}">
                                        ${customer.city}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Not provided</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>Country:</th>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty customer.country}">
                                        ${customer.country}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted">Not provided</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <!-- Booking Statistics -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-chart-line"></i> Booking Statistics</h5>
                </div>
                <div class="card-body">
                    <div class="row text-center">
                        <div class="col-md-3">
                            <div class="stat-box">
                                <h3 class="text-primary">${customer.totalBookings}</h3>
                                <p class="mb-0">Total Bookings</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-box">
                                <h3 class="text-success">${customer.completedBookings}</h3>
                                <p class="mb-0">Completed Stays</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-box">
                                <h3 class="text-warning">${customer.formattedTotalSpent}</h3>
                                <p class="mb-0">Total Spent</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-box">
                                <h3 class="text-info">
                                    <c:choose>
                                        <c:when test="${not empty customer.lastVisit}">
                                            <fmt:formatDate value="${customer.lastVisit}" pattern="MM/yyyy"/>
                                        </c:when>
                                        <c:otherwise>
                                            Never
                                        </c:otherwise>
                                    </c:choose>
                                </h3>
                                <p class="mb-0">Last Visit</p>
                            </div>
                        </div>
                    </div>
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
                    <a href="${pageContext.request.contextPath}/admin/customers?action=form&id=${customer.id}" 
                       class="btn btn-warning btn-block mb-2">
                        <i class="fas fa-edit"></i> Edit Profile
                    </a>
                    
                    <a href="${pageContext.request.contextPath}/admin/bookings?customer=${customer.id}" 
                       class="btn btn-info btn-block mb-2">
                        <i class="fas fa-calendar-check"></i> View Bookings
                    </a>
                    
                    <button class="btn btn-success btn-block mb-2" onclick="createBooking(${customer.id})">
                        <i class="fas fa-plus"></i> Create Booking
                    </button>
                    
                    <!-- VERIFICATION SYSTEM BUTTONS -->
                    <div class="dropdown">
                        <button class="btn btn-secondary btn-block dropdown-toggle mb-2" type="button" 
                                id="changeRequestDropdown" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <i class="fas fa-shield-alt"></i> Secure Account Changes
                        </button>
                        <div class="dropdown-menu w-100" aria-labelledby="changeRequestDropdown">
                            <a class="dropdown-item" href="#" onclick="requestChange('email', ${customer.id}, 'customer')">
                                <i class="fas fa-envelope text-primary"></i> Change Email Address
                            </a>
                            <a class="dropdown-item" href="#" onclick="requestChange('phone', ${customer.id}, 'customer')">
                                <i class="fas fa-phone text-success"></i> Change Phone Number
                            </a>
                            <a class="dropdown-item" href="#" onclick="requestChange('password', ${customer.id}, 'customer')">
                                <i class="fas fa-key text-warning"></i> Reset Password
                            </a>
                        </div>
                    </div>
                    
                    <c:if test="${customer.status}">
                        <button class="btn btn-secondary btn-block mb-2" onclick="resetPassword(${customer.id})">
                            <i class="fas fa-key"></i> Reset Password (Direct)
                        </button>
                    </c:if>
                    
                    <c:if test="${customer.status}">
                        <button onclick="confirmDelete(${customer.id}, '${customer.fullName}')" 
                                class="btn btn-danger btn-block">
                            <i class="fas fa-trash"></i> Delete Customer
                        </button>
                    </c:if>
                </div>
            </div>

            <!-- Pending Changes Section -->
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
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </div>
            </c:if>

            <!-- Loyalty Information -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-star"></i> Loyalty Program</h5>
                </div>
                <div class="card-body">
                    <div class="text-center mb-3">
                        <h4 class="mb-1">
                            <span class="badge ${customer.membershipBadgeClass} p-2" style="font-size: 16px;">
                                ${customer.membershipLevel}
                            </span>
                        </h4>
                        <p class="text-muted mb-0">${customer.loyaltyDescription}</p>
                    </div>
                    
                    <table class="table table-sm table-borderless">
                        <tr>
                            <th>Loyalty Points:</th>
                            <td class="text-right">
                                <span class="badge badge-primary">${customer.loyaltyPoints}</span>
                            </td>
                        </tr>
                        <tr>
                            <th>VIP Status:</th>
                            <td class="text-right">
                                <c:choose>
                                    <c:when test="${customer.isVIP}">
                                        <span class="badge badge-warning">VIP</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-secondary">Regular</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>Profile Complete:</th>
                            <td class="text-right">
                                <div class="progress" style="height: 20px;">
                                    <div class="progress-bar" role="progressbar" 
                                         style="width: ${customer.profileCompletionPercentage}%"
                                         aria-valuenow="${customer.profileCompletionPercentage}" 
                                         aria-valuemin="0" aria-valuemax="100">
                                        ${customer.profileCompletionPercentage}%
                                    </div>
                                </div>
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
                            <th>Member Since:</th>
                            <td class="text-right">
                                <fmt:formatDate value="${customer.createdAt}" pattern="dd/MM/yyyy"/>
                            </td>
                        </tr>
                        <tr>
                            <th>Last Updated:</th>
                            <td class="text-right">
                                <fmt:formatDate value="${customer.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                        </tr>
                        <tr>
                            <th>Account Status:</th>
                            <td class="text-right">
                                <span class="badge ${customer.statusBadgeClass}">
                                    ${customer.statusDisplayName}
                                </span>
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
                    <input type="hidden" id="quickUserId" name="userId" value="${customer.id}">
                    <input type="hidden" id="quickUserType" name="userType" value="customer">
                    
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
                <p>Are you sure you want to delete customer "<strong><span id="deleteCustomerName"></span></strong>"?</p>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i>
                    This action will move the customer to trash. You can restore them later if needed.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <a id="deleteConfirmLink" href="#" class="btn btn-danger">
                    <i class="fas fa-trash"></i> Delete Customer
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
                <p>Customer can use this link to approve or reject the change:</p>
                <div class="input-group">
                    <input type="text" class="form-control" id="verificationLink" readonly>
                    <div class="input-group-append">
                        <button class="btn btn-outline-secondary" onclick="copyToClipboard()">
                            <i class="fas fa-copy"></i> Copy
                        </button>
                    </div>
                </div>
                <small class="text-muted">This link has also been sent to the customer's email address.</small>
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
                        'This will send a verification email to the customer for approval.';
    
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
            help.textContent = 'Customer will receive verification email at their current address';
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
        // 🔥 VẤN ĐỀ: Xử lý redirect
        if (response.redirected) {
            // Thêm '&verificationSent=true' vào URL redirect
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
    if (confirm('Send a reminder email to the customer about this pending change?')) {
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
function confirmDelete(customerId, customerName) {
    document.getElementById('deleteCustomerName').textContent = customerName;
    document.getElementById('deleteConfirmLink').href = 
        '${pageContext.request.contextPath}/admin/customers?action=delete&id=' + customerId;
    $('#deleteModal').modal('show');
}

function resetPassword(customerId) {
    if (confirm('Are you sure you want to reset the password for this customer?')) {
        alert('Password reset functionality to be implemented');
    }
}

function createBooking(customerId) {
    window.location.href = '${pageContext.request.contextPath}/admin/bookings?action=create&customer=' + customerId;
}
</script>