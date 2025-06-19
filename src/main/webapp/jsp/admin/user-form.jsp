<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .form-container {
        max-width: 900px;
        background: white;
        border-radius: 10px;
        padding: 30px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    .form-section {
        margin-bottom: 30px;
    }

    .form-section h3 {
        color: #5a2b81;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 2px solid #f0f0f0;
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
        height: 44px;
        line-height: 1.5;
    }

    .form-control:focus {
        outline: none;
        border-color: #5a2b81;
        box-shadow: 0 0 0 0.2rem rgba(90, 43, 129, 0.25);
    }

    .form-control:disabled {
        background-color: #e9ecef;
        cursor: not-allowed;
    }

    .form-control.is-invalid {
        border-color: #dc3545;
    }

    select.form-control {
        cursor: pointer;
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%23343a40' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e");
        background-repeat: no-repeat;
        background-position: right .75rem center;
        background-size: 16px 12px;
        padding-right: 2.25rem;
        -webkit-appearance: none;
        -moz-appearance: none;
        appearance: none;
    }

    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .text-danger {
        color: #dc3545;
    }

    .text-muted {
        color: #6c757d;
        font-size: 0.875rem;
    }

    .alert {
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 5px;
    }

    .alert-danger {
        background: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }

    .btn-group {
        display: flex;
        gap: 10px;
        margin-top: 30px;
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

    .btn-primary:hover {
        background: #4a1f6d;
    }

    .btn-secondary {
        background: #6c757d;
        color: white;
    }

    .btn-secondary:hover {
        background: #5a6268;
    }

    .btn-warning {
        background: #ffc107;
        color: #212529;
    }

    .btn-warning:hover {
        background: #e0a800;
    }

    .btn-sm {
        padding: 5px 10px;
        font-size: 12px;
    }

    .info-box {
        background: #f8f9fa;
        border-left: 4px solid #5a2b81;
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 5px;
    }

    .info-box h6 {
        margin-bottom: 10px;
        color: #5a2b81;
    }

    .info-box ul {
        margin-bottom: 0;
        padding-left: 20px;
    }

    .strength-indicator {
        margin-top: 5px;
        font-size: 0.875rem;
    }

    .password-section {
        background: #f8f9fa;
        border-radius: 5px;
        padding: 15px;
        margin-bottom: 15px;
        border: 1px solid #dee2e6;
    }

    .password-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
    }

    .password-fields {
        display: none;
    }

    .password-fields.show {
        display: block;
    }

    .input-group {
        position: relative;
    }

    .input-group-append {
        position: absolute;
        right: 10px;
        top: 50%;
        transform: translateY(-50%);
        z-index: 5;
    }

    .btn-outline-secondary {
        background: transparent;
        border: 1px solid #6c757d;
        color: #6c757d;
        padding: 5px 8px;
        border-radius: 3px;
        font-size: 12px;
    }

    .btn-outline-secondary:hover {
        background: #6c757d;
        color: white;
    }

    /* Ensure all inputs have same height */
    input.form-control,
    select.form-control {
        height: 44px;
    }

    @media (max-width: 768px) {
        .form-row {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/users">User Management</a></li>
            <li class="breadcrumb-item active">${isEdit ? 'Edit User' : 'Create User'}</li>
        </ol>
    </nav>

    <h1 class="mb-4">${isEdit ? 'Edit' : 'Create New'} User</h1>

    <div class="row">
        <div class="col-lg-8">
            <div class="form-container">
                <!-- Error Message -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/admin/users" id="userForm">
                    <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="id" value="${user.id}">
                    </c:if>

                    <!-- Account Information -->
                    <div class="form-section">
                        <h3><i class="fas fa-user-shield"></i> Account Information</h3>

                        <c:if test="${!isEdit}">
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Username <span class="text-danger">*</span></label>
                                    <input name="username" type="text" required 
                                           class="form-control" id="username"
                                           placeholder="Enter username"
                                           pattern="[a-zA-Z0-9_]{3,20}"
                                           title="Username must be 3-20 characters, alphanumeric and underscore only">
                                    <small class="text-muted">3-20 characters, letters, numbers and underscore only</small>
                                </div>
                                <div class="form-group">
                                    <label>Password <span class="text-danger">*</span></label>
                                    <input name="password" type="password" required 
                                           class="form-control" id="password"
                                           placeholder="Enter password">
                                    <div id="passwordStrength" class="strength-indicator"></div>
                                    <small class="text-muted">Minimum 8 characters with mixed case, number and special character</small>
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${isEdit}">
                            <div class="form-group">
                                <label>Username</label>
                                <input type="text" class="form-control" value="${user.username}" disabled>
                                <small class="text-muted">Username cannot be changed after creation</small>
                            </div>

                            <!-- Password Change Section for Edit Mode -->
                            <div class="password-section">
                                <div class="password-header">
                                    <h6 class="mb-0"><i class="fas fa-key"></i> Password Management</h6>
                                    <button type="button" class="btn btn-warning btn-sm" id="togglePasswordChange">
                                        <i class="fas fa-edit"></i> Change Password
                                    </button>
                                </div>
                                
                                <div class="password-fields" id="passwordFields">
                                    <div class="form-group">
                                        <label>New Password <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <input name="newPassword" type="password" 
                                                   class="form-control" id="newPassword"
                                                   placeholder="Enter new password">
                                            <div class="input-group-append">
                                                <button type="button" class="btn btn-outline-secondary" id="togglePassword">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                            </div>
                                        </div>
                                        <div id="newPasswordStrength" class="strength-indicator"></div>
                                        <small class="text-muted">Minimum 8 characters with mixed case, number and special character</small>
                                    </div>
                                    
                                    <div class="form-group">
                                        <label>Confirm New Password <span class="text-danger">*</span></label>
                                        <input name="confirmPassword" type="password" 
                                               class="form-control" id="confirmPassword"
                                               placeholder="Confirm new password">
                                        <div id="passwordMatch" class="strength-indicator"></div>
                                    </div>
                                </div>
                                
                                <input type="hidden" name="changePassword" id="changePasswordFlag" value="false">
                            </div>
                        </c:if>

                        <div class="form-group">
                            <label>Role <span class="text-danger">*</span></label>
                            <select name="role" class="form-control" id="role" required>
                                <option value="">Select Role</option>
                                <option value="ADMIN" ${isEdit && user.role == 'ADMIN' ? 'selected' : ''}>Administrator</option>
                                <option value="RECEPTIONIST" ${isEdit && user.role == 'RECEPTIONIST' ? 'selected' : ''}>Receptionist</option>
                                <option value="HOUSEKEEPER" ${isEdit && user.role == 'HOUSEKEEPER' ? 'selected' : ''}>Housekeeper</option>
                                <option value="GUEST" ${isEdit && user.role == 'GUEST' ? 'selected' : ''}>Guest</option>
                            </select>
                        </div>
                    </div>

                    <!-- Personal Information -->
                    <div class="form-section">
                        <h3><i class="fas fa-info-circle"></i> Personal Information</h3>

                        <div class="form-group">
                            <label>Full Name <span class="text-danger">*</span></label>
                            <input name="fullName" type="text" required 
                                   class="form-control" id="fullName"
                                   placeholder="Enter full name"
                                   value="${isEdit ? user.fullName : ''}">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label>Email <span class="text-danger">*</span></label>
                                <input name="email" type="email" required 
                                       class="form-control" id="email"
                                       placeholder="Enter email address"
                                       value="${isEdit ? user.email : ''}">
                            </div>
                            <div class="form-group">
                                <label>Phone</label>
                                 <input name="phone" type="text" 
                                       class="form-control" id="phone"
                                       placeholder="Enter phone number"
                                       pattern="0\d{9}"
                                       title="Phone number must start with 0 and be exactly 10 digits"
                                       value="${not empty user ? user.phone : ''}">
                                <small class="text-muted">Must start with 0 (10 digits total)</small>
                            </div>
                        </div>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> ${isEdit ? 'Update' : 'Create'} User
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Side Information -->
        <div class="col-lg-4">
            <div class="info-box">
                <h6><i class="fas fa-shield-alt"></i> User Roles</h6>
                <ul class="small">
                    <li><strong>Administrator:</strong> Full system access</li>
                    <li><strong>Receptionist:</strong> Manage bookings and check-ins</li>
                    <li><strong>Housekeeper:</strong> View room status and cleaning tasks</li>
                    <li><strong>Guest:</strong> Book rooms and view reservations</li>
                </ul>
            </div>

            <div class="info-box">
                <h6><i class="fas fa-key"></i> Password Requirements</h6>
                <ul class="small">
                    <li>At least 8 characters long</li>
                    <li>Contains uppercase letter (A-Z)</li>
                    <li>Contains lowercase letter (a-z)</li>
                    <li>Contains number (0-9)</li>
                    <li>Contains special character (@#$%^&+=!)</li>
                </ul>
            </div>

            <c:if test="${isEdit}">
                <div class="info-box">
                    <h6><i class="fas fa-info"></i> User Information</h6>
                    <p class="small mb-1">
                        <strong>Status:</strong> 
                        <span class="badge ${user.statusBadgeClass}">${user.statusDisplayName}</span>
                    </p>
                    <p class="small mb-1">
                        <strong>Created:</strong> 
                        <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </p>
                    <p class="small mb-1">
                        <strong>Last Updated:</strong> 
                        <fmt:formatDate value="${user.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </p>
                    <p class="small mb-0">
                        <strong>Total Bookings:</strong> ${user.totalBookings}
                    </p>
                </div>

                <div class="info-box">
                    <h6><i class="fas fa-exclamation-triangle"></i> Security Notes</h6>
                    <ul class="small">
                        <li>Changing password will log out the user from all devices</li>
                        <li>User will receive email notification of password change</li>
                        <li>All password changes are logged for security audit</li>
                    </ul>
                </div>
            </c:if>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
$(document).ready(function() {
    // Toggle password change section for edit mode
    <c:if test="${isEdit}">
    $('#togglePasswordChange').on('click', function() {
        var $fields = $('#passwordFields');
        var $button = $(this);
        var $flag = $('#changePasswordFlag');
        
        if ($fields.hasClass('show')) {
            $fields.removeClass('show');
            $button.html('<i class="fas fa-edit"></i> Change Password');
            $flag.val('false');
            // Clear password fields
            $('#newPassword, #confirmPassword').val('');
            $('#newPasswordStrength, #passwordMatch').html('');
            // Remove required attribute
            $('#newPassword, #confirmPassword').removeAttr('required');
        } else {
            $fields.addClass('show');
            $button.html('<i class="fas fa-times"></i> Cancel Change');
            $flag.val('true');
            // Add required attribute
            $('#newPassword, #confirmPassword').attr('required', 'required');
        }
    });

    // Toggle password visibility
    $('#togglePassword').on('click', function() {
        var $password = $('#newPassword');
        var $icon = $(this).find('i');
        
        if ($password.attr('type') === 'password') {
            $password.attr('type', 'text');
            $icon.removeClass('fa-eye').addClass('fa-eye-slash');
        } else {
            $password.attr('type', 'password');
            $icon.removeClass('fa-eye-slash').addClass('fa-eye');
        }
    });

    // Real-time password strength indicator for edit mode
    $('#newPassword').on('input', function() {
        var password = $(this).val();
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
            $('#newPasswordStrength').html('<span class="' + strengthClass + '">Password strength: ' + strengthText + '</span>');
        } else {
            $('#newPasswordStrength').html('');
        }
    });

    // Password confirmation validation
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
    </c:if>

    // Form validation
    $('#userForm').on('submit', function(e) {
        var isValid = true;
        var errorMessage = '';

        // Clear previous validation states
        $('.form-control').removeClass('is-invalid');

        // Check required fields
        $(this).find('[required]').each(function() {
            if (!$(this).val().trim()) {
                $(this).addClass('is-invalid');
                isValid = false;
            }
        });

        // Username validation (only for new users)
        <c:if test="${!isEdit}">
        var username = $('#username').val();
        if (username && !/^[a-zA-Z0-9_]{3,20}$/.test(username)) {
            $('#username').addClass('is-invalid');
            errorMessage = 'Username must be 3-20 characters and contain only letters, numbers, and underscores';
            isValid = false;
        }

        // Password validation for new users
        var password = $('#password').val();
        if (password) {
            if (!validatePassword(password, '#password')) {
                isValid = false;
            }
        }
        </c:if>

        // Password validation for edit mode
        <c:if test="${isEdit}">
        if ($('#changePasswordFlag').val() === 'true') {
            var newPassword = $('#newPassword').val();
            var confirmPassword = $('#confirmPassword').val();
            
            if (!newPassword) {
                $('#newPassword').addClass('is-invalid');
                errorMessage = 'New password is required when changing password';
                isValid = false;
            } else if (!validatePassword(newPassword, '#newPassword')) {
                isValid = false;
            }
            
            if (!confirmPassword) {
                $('#confirmPassword').addClass('is-invalid');
                errorMessage = 'Please confirm the new password';
                isValid = false;
            } else if (newPassword !== confirmPassword) {
                $('#confirmPassword').addClass('is-invalid');
                errorMessage = 'Passwords do not match';
                isValid = false;
            }
        }
        </c:if>

        // Email validation
        var email = $('#email').val();
        var emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/;
        if (email && !emailRegex.test(email)) {
            $('#email').addClass('is-invalid');
            errorMessage = 'Please enter a valid email address';
            isValid = false;
        }

        // Phone validation (optional)
        var phone = $('#phone').val();
        if (phone && !/^0\d{9}$/.test(phone)) {
            $('#phone').addClass('is-invalid');
            errorMessage = 'Phone number must start with 0 and be exactly 10 digits';
            isValid = false;
        }

        if (!isValid) {
            e.preventDefault();
            if (errorMessage) {
                alert(errorMessage);
            }
        }
    });

    // Password validation function
    function validatePassword(password, fieldId) {
        if (password.length < 8) {
            $(fieldId).addClass('is-invalid');
            errorMessage = 'Password must be at least 8 characters long';
            return false;
        } else if (!/(?=.*[a-z])/.test(password)) {
            $(fieldId).addClass('is-invalid');
            errorMessage = 'Password must contain at least one lowercase letter';
            return false;
        } else if (!/(?=.*[A-Z])/.test(password)) {
            $(fieldId).addClass('is-invalid');
            errorMessage = 'Password must contain at least one uppercase letter';
            return false;
        } else if (!/(?=.*\d)/.test(password)) {
            $(fieldId).addClass('is-invalid');
            errorMessage = 'Password must contain at least one number';
            return false;
        } else if (!/(?=.*[@#$%^&+=!])/.test(password)) {
            $(fieldId).addClass('is-invalid');
            errorMessage = 'Password must contain at least one special character (@#$%^&+=!)';
            return false;
        }
        return true;
    }

    // Remove invalid class on input
    $('.form-control').on('input change', function() {
        $(this).removeClass('is-invalid');
    });

    // Real-time password strength indicator for new users
    <c:if test="${!isEdit}">
    $('#password').on('input', function() {
        var password = $(this).val();
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
    });
    </c:if>
});
</script>