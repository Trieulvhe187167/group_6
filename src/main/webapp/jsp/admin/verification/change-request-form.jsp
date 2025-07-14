
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .change-form-container {
        max-width: 800px;
        background: white;
        border-radius: 10px;
        padding: 30px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    .user-info-card {
        background: #f8f9fa;
        border-left: 4px solid #5a2b81;
        padding: 20px;
        margin-bottom: 30px;
        border-radius: 5px;
    }
    
    .warning-box {
        background: #fff3cd;
        border: 1px solid #ffeaa7;
        color: #856404;
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 20px;
    }
    
    .form-group {
        margin-bottom: 20px;
    }
    
    .form-group label {
        display: block;
        margin-bottom: 8px;
        font-weight: 500;
        color: #4a5568;
    }
    
    .form-control {
        width: 100%;
        padding: 10px 15px;
        border: 1px solid #e9ecef;
        border-radius: 5px;
        font-size: 14px;
        transition: border-color 0.3s;
    }
    
    .form-control:focus {
        outline: none;
        border-color: #5a2b81;
        box-shadow: 0 0 0 0.2rem rgba(90, 43, 129, 0.25);
    }
    
    .btn {
        padding: 10px 20px;
        border: none;
        border-radius: 5px;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: all 0.3s;
    }
    
    .btn-primary {
        background: #5a2b81;
        color: white;
    }
    
    .btn-secondary {
        background: #6c757d;
        color: white;
    }
    
    .btn-group {
        display: flex;
        gap: 10px;
        margin-top: 30px;
    }
</style>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/${userType}">${userType == 'customer' ? 'Customer' : 'Staff'} Management</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/${userType}?action=view&id=${targetUser.id}">${targetUser.fullName}</a></li>
            <li class="breadcrumb-item active">Request ${changeType.substring(0, 1).toUpperCase()}${changeType.substring(1)} Change</li>
        </ol>
    </nav>

    <h1 class="mb-4">Request ${changeType.substring(0, 1).toUpperCase()}${changeType.substring(1)} Change</h1>

    <div class="row">
        <div class="col-lg-8">
            <div class="change-form-container">
                
                <!-- User Information Card -->
                <div class="user-info-card">
                    <h5><i class="fas fa-user"></i> Target User Information</h5>
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>Name:</strong> ${targetUser.fullName}</p>
                            <p><strong>Role:</strong> <span class="badge ${targetUser.roleBadgeClass}">${targetUser.roleDisplayName}</span></p>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Current Email:</strong> ${targetUser.email}</p>
                            <p><strong>Current Phone:</strong> 
                                <c:choose>
                                    <c:when test="${not empty targetUser.phone}">${targetUser.phone}</c:when>
                                    <c:otherwise><span class="text-muted">Not provided</span></c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Security Warning -->
                <div class="warning-box">
                    <i class="fas fa-shield-alt"></i>
                    <strong>Security Notice:</strong> This request will send a verification email to the user's current email address. 
                    The user must approve the change before it takes effect. All changes are logged for security audit.
                </div>

                <!-- Change Form -->
                <form method="post" action="${pageContext.request.contextPath}/admin/change-request" id="changeForm">
                    <input type="hidden" name="action" value="request-${changeType}-change">
                    <input type="hidden" name="userId" value="${targetUser.id}">
                    <input type="hidden" name="userType" value="${userType}">

                    <c:choose>
                        <c:when test="${changeType == 'email'}">
                            <div class="form-group">
                                <label>Current Email Address</label>
                                <input type="text" class="form-control" value="${targetUser.email}" disabled>
                            </div>
                            
                            <div class="form-group">
                                <label>New Email Address <span class="text-danger">*</span></label>
                                <input name="newEmail" type="email" required class="form-control" 
                                       placeholder="Enter new email address">
                                <small class="text-muted">The user will receive verification email at their current address</small>
                            </div>
                        </c:when>
                        
                        <c:when test="${changeType == 'phone'}">
                            <div class="form-group">
                                <label>Current Phone Number</label>
                                <input type="text" class="form-control" 
                                       value="${not empty targetUser.phone ? targetUser.phone : 'Not provided'}" disabled>
                            </div>
                            
                            <div class="form-group">
                                <label>New Phone Number</label>
                                <input name="newPhone" type="text" class="form-control" 
                                       placeholder="Enter new phone number (e.g., 0123456789)"
                                       pattern="0\d{9}" title="Phone number must start with 0 and be exactly 10 digits">
                                <small class="text-muted">Leave empty to remove phone number. Format: 0123456789</small>
                            </div>
                        </c:when>
                        
                        <c:when test="${changeType == 'password'}">
                            <div class="form-group">
                                <label>New Password <span class="text-danger">*</span></label>
                                <input name="newPassword" type="password" required class="form-control" 
                                       placeholder="Enter new password" id="newPassword">
                                <div id="passwordStrength" class="mt-2"></div>
                                <small class="text-muted">Minimum 8 characters with uppercase, lowercase, digit, and special character</small>
                            </div>
                            
                            <div class="form-group">
                                <label>Confirm New Password <span class="text-danger">*</span></label>
                                <input name="confirmPassword" type="password" required class="form-control" 
                                       placeholder="Confirm new password" id="confirmPassword">
                                <div id="passwordMatch" class="mt-2"></div>
                            </div>
                        </c:when>
                    </c:choose>

                    <div class="form-group">
                        <label>Reason for Change <span class="text-danger">*</span></label>
                        <textarea name="reason" required class="form-control" rows="4" 
                                  placeholder="Please provide a detailed reason for this change request..."></textarea>
                        <small class="text-muted">This reason will be included in the verification email sent to the user</small>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            <i class="fas fa-paper-plane"></i> Send Change Request
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/${userType}?action=view&id=${targetUser.id}" 
                           class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Side Information -->
        <div class="col-lg-4">
            <div class="info-box">
                <h6><i class="fas fa-info-circle"></i> How It Works</h6>
                <ol class="small">
                    <li>You submit the change request with a reason</li>
                    <li>User receives verification email at current address</li>
                    <li>User clicks verification link to approve/reject</li>
                    <li>If approved, change is applied automatically</li>
                    <li>Both admin and user receive confirmation</li>
                </ol>
            </div>

            <div class="info-box">
                <h6><i class="fas fa-clock"></i> Timeline</h6>
                <ul class="small">
                    <li><strong>Immediate:</strong> Verification email sent</li>
                    <li><strong>24 hours:</strong> Reminder email (if no response)</li>
                    <li><strong>48 hours:</strong> Request expires automatically</li>
                </ul>
            </div>

            <div class="info-box">
                <h6><i class="fas fa-shield-alt"></i> Security Features</h6>
                <ul class="small">
                    <li>Secure verification tokens</li>
                    <li>Time-limited approval links</li>
                    <li>Complete audit trail</li>
                    <li>Email notifications</li>
                    <li>User consent required</li>
                </ul>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    <c:if test="${changeType == 'password'}">
    // Password strength indicator
    $('#newPassword').on('input', function() {
        var password = $(this).val();
        checkPasswordStrength(password);
    });

    // Password match validation
    $('#confirmPassword').on('input', function() {
        var password = $('#newPassword').val();
        var confirmPassword = $(this).val();
        
        if (confirmPassword.length > 0) {
            if (password === confirmPassword) {
                $('#passwordMatch').html('<span class="text-success"><i class="fas fa-check"></i> Passwords match</span>');
            } else {
                $('#passwordMatch').html('<span class="text-danger"><i class="fas fa-times"></i> Passwords do not match</span>');
            }
        } else {
            $('#passwordMatch').html('');
        }
    });

    function checkPasswordStrength(password) {
        var strength = 0;
        if (password.length >= 8) strength++;
        if (/[a-z]/.test(password)) strength++;
        if (/[A-Z]/.test(password)) strength++;
        if (/\d/.test(password)) strength++;
        if (/[@#$%^&+=!]/.test(password)) strength++;

        var strengthText = '';
        var strengthClass = '';

        switch(strength) {
            case 0:
            case 1:
                strengthText = 'Weak';
                strengthClass = 'text-danger';
                break;
            case 2:
            case 3:
                strengthText = 'Medium';
                strengthClass = 'text-warning';
                break;
            case 4:
                strengthText = 'Good';
                strengthClass = 'text-info';
                break;
            case 5:
                strengthText = 'Strong';
                strengthClass = 'text-success';
                break;
        }

        if (password.length > 0) {
            $('#passwordStrength').html('<span class="' + strengthClass + '">Password strength: ' + strengthText + '</span>');
        } else {
            $('#passwordStrength').html('');
        }
    }
    </c:if>

    // Form validation
    $('#changeForm').on('submit', function(e) {
        <c:if test="${changeType == 'password'}">
        var password = $('#newPassword').val();
        var confirmPassword = $('#confirmPassword').val();
        
        if (!password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!]).{8,}$/)) {
            e.preventDefault();
            alert('Password must be at least 8 characters with uppercase, lowercase, digit, and special character!');
            return false;
        }
        
        if (password !== confirmPassword) {
            e.preventDefault();
            alert('Passwords do not match!');
            return false;
        }
        </c:if>
        
        // Confirmation dialog
        var confirmMessage = 'Are you sure you want to send this ${changeType} change request?\n\n' +
                           'The user will receive an email and must approve the change.';
        
        if (!confirm(confirmMessage)) {
            e.preventDefault();
            return false;
        }
        
        $('#submitBtn').prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Sending...');
    });
});
</script>