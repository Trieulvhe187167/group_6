<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    /* Giữ nguyên style cũ và thêm mới */
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

    .alert-warning {
        background: #fff3cd;
        color: #856404;
        border: 1px solid #ffeaa7;
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

    .role-protection-note {
        background: #fff3cd;
        border: 1px solid #ffeaa7;
        color: #856404;
        padding: 10px;
        border-radius: 5px;
        margin-top: 5px;
        font-size: 0.875rem;
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
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/staff">Staff Management</a></li>
            <li class="breadcrumb-item active">${isEdit ? 'Edit Staff Member' : 'Add New Staff Member'}</li>
        </ol>
    </nav>

    <h1 class="mb-4">${isEdit ? 'Edit' : 'Add New'} Staff Member</h1>

    <!-- Admin Role Protection Alert -->
    <c:if test="${isEdit && staff.role == 'ADMIN'}">
        <div class="alert alert-warning">
            <i class="fas fa-shield-alt"></i>
            <strong>Admin Role Protection:</strong> The role for Administrator accounts cannot be changed for security reasons.
        </div>
    </c:if>

    <div class="row">
        <div class="col-lg-8">
            <div class="form-container">
                <!-- Error Message -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <form method="post" action="${pageContext.request.contextPath}/admin/staff" id="staffForm">
                    <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="id" value="${staff.id}">
                        <!-- Hidden field to preserve admin role -->
                        <c:if test="${staff.role == 'ADMIN'}">
                            <input type="hidden" name="role" value="ADMIN">
                        </c:if>
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
                                <input type="text" class="form-control" value="${staff.username}" disabled>
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
                            <c:choose>
                                <c:when test="${!isEdit || (isEdit && staff.role != 'ADMIN')}">
                                    <select name="role" class="form-control" id="role" required>
                                        <option value="">Select Role</option>
                                      
                                        <option value="RECEPTIONIST" ${isEdit && staff.role == 'RECEPTIONIST' ? 'selected' : ''}>Receptionist</option>
                                        <option value="HOUSEKEEPER" ${isEdit && staff.role == 'HOUSEKEEPER' ? 'selected' : ''}>Housekeeper</option>
                                        <option value="ROOM_INSPECTOR" ${isEdit && staff.role == 'ROOM_INSPECTOR' ? 'selected' : ''}>Room Inspector</option>
                                    </select>
                                </c:when>
                                <c:otherwise>
                                    <input type="text" class="form-control" value="Administrator" disabled>
                                    <div class="role-protection-note">
                                        <i class="fas fa-shield-alt"></i>
                                        <strong>Protected Role:</strong> Administrator role cannot be changed for security reasons. This ensures system stability and prevents accidental privilege loss.
                                    </div>
                                </c:otherwise>
                            </c:choose>
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
                                   value="${isEdit ? staff.fullName : ''}">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label>Email <span class="text-danger">*</span></label>
                                <input name="email" type="email" required 
                                       class="form-control" id="email"
                                       placeholder="Enter email address"
                                       value="${isEdit ? staff.email : ''}">
                            </div>
                            <div class="form-group">
                                <label>Phone</label>
                                <input name="phone" type="text" 
                                       class="form-control" id="phone"
                                       placeholder="Enter phone number"
                                       pattern="0\d{9}"
                                       title="Phone number must start with 0 and be exactly 10 digits"
                                       value="${not empty staff ? staff.phone : ''}">
                                <small class="text-muted">Must start with 0 (10 digits total)</small>
                            </div>
                        </div>
                    </div>

                    <!-- Personal Details -->
                    <div class="form-section">
                        <h3><i class="fas fa-user-circle"></i> Personal Details</h3>

                        <div class="form-row">
                            <div class="form-group">
                                <label>Date of Birth <span class="text-danger">*</span></label>
                                <input name="dateOfBirth" type="date" required
                                       class="form-control" id="dateOfBirth"
                                       value="${isEdit && not empty staff.dateOfBirth ? staff.formattedDateOfBirth : ''}"
                                       max="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                                <small class="text-muted">Must be at least 18 years old</small>
                            </div>
                            <div class="form-group">
                                <label>Gender</label>
                                <select name="gender" class="form-control" id="gender">
                                    <option value="">Select Gender</option>
                                    <option value="MALE" ${isEdit && staff.gender == 'MALE' ? 'selected' : ''}>Male</option>
                                    <option value="FEMALE" ${isEdit && staff.gender == 'FEMALE' ? 'selected' : ''}>Female</option>
                                    <option value="OTHER" ${isEdit && staff.gender == 'OTHER' ? 'selected' : ''}>Other</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Address</label>
                            <input name="address" type="text" 
                                   class="form-control" id="address"
                                   placeholder="Enter street address"
                                   value="${isEdit ? staff.address : ''}">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label>City</label>
                                <input name="city" type="text" 
                                       class="form-control" id="city"
                                       placeholder="Enter city"
                                       value="${isEdit ? staff.city : ''}">
                            </div>
                            <div class="form-group">
                                <label>Country</label>
                                <input name="country" type="text" 
                                       class="form-control" id="country"
                                       placeholder="Enter country"
                                       value="${isEdit ? staff.country : ''}">
                            </div>
                        </div>
                    </div>

                    <!-- Employment Information -->
                    <div class="form-section">
                        <h3><i class="fas fa-briefcase"></i> Employment Information</h3>

                        <div class="form-row">
                            <div class="form-group">
                                <label>Department</label>
                                <input name="department" type="text" 
                                       class="form-control" id="department"
                                       placeholder="Enter department"
                                       value="${isEdit ? staff.department : ''}">
                                <small class="text-muted">e.g., Front Office, Housekeeping, Management</small>
                            </div>
                            <div class="form-group">
                                <label>Hire Date</label>
                                <input name="hireDate" type="date" 
                                       class="form-control" id="hireDate"
                                       value="${isEdit && not empty staff.hireDate ? staff.formattedHireDate : ''}"
                                       max="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Monthly Salary (VND)</label>
                            <input name="salary" type="number" 
                                   class="form-control" id="salary"
                                   placeholder="Enter monthly salary"
                                   min="0"
                                   step="100000"
                                   value="${isEdit ? staff.salary : ''}">
                            <small class="text-muted">Basic monthly salary in Vietnamese Dong</small>
                        </div>
                    </div>

                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> ${isEdit ? 'Update' : 'Create'} Staff Member
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/staff" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Side Information -->
        <div class="col-lg-4">
            <div class="info-box">
                <h6><i class="fas fa-shield-alt"></i> Staff Roles</h6>
                <ul class="small">
                    <li><strong>Administrator:</strong> Full system access and management</li>
                    <li><strong>Receptionist:</strong> Manage bookings, check-ins, and customer service</li>
                    <li><strong>Housekeeper:</strong> Room cleaning and maintenance tasks</li>
                    <li><strong>Room Inspector:</strong> Quality control and room inspections</li>
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

            <!-- Role Protection Info Box -->
            <c:if test="${isEdit && staff.role == 'ADMIN'}">
                <div class="info-box" style="border-left-color: #ffc107;">
                    <h6><i class="fas fa-shield-alt text-warning"></i> Role Protection</h6>
                    <ul class="small">
                        <li>Administrator roles are protected from modification</li>
                        <li>This prevents accidental privilege loss</li>
                        <li>Ensures system security and stability</li>
                        <li>Only other admins can manage admin accounts</li>
                    </ul>
                </div>
            </c:if>

            <c:if test="${isEdit}">
                <div class="info-box">
                    <h6><i class="fas fa-info"></i> Staff Information</h6>
                    <p class="small mb-1">
                        <strong>Current Role:</strong> 
                        <span class="badge ${staff.roleBadgeClass}">${staff.roleDisplayName}</span>
                    </p>
                    <p class="small mb-1">
                        <strong>Status:</strong> 
                        <span class="badge ${staff.statusBadgeClass}">${staff.statusDisplayName}</span>
                    </p>
                    <p class="small mb-1">
                        <strong>Years of Service:</strong> ${staff.yearsOfService}
                    </p>
                    <p class="small mb-1">
                        <strong>Joined:</strong> 
                        <fmt:formatDate value="${staff.createdAt}" pattern="dd/MM/yyyy"/>
                    </p>
                    <p class="small mb-1">
                        <strong>Last Updated:</strong> 
                        <fmt:formatDate value="${staff.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </p>
                    <c:if test="${staff.role == 'RECEPTIONIST'}">
                        <p class="small mb-0">
                            <strong>Bookings Created:</strong> ${staff.totalBookings}
                        </p>
                    </c:if>
                </div>

                <div class="info-box">
                    <h6><i class="fas fa-dollar-sign"></i> Salary Guidelines</h6>
                    <ul class="small">
                        <li><strong>Receptionist:</strong> 8M - 15M VND/month</li>
                        <li><strong>Housekeeper:</strong> 6M - 10M VND/month</li>
                        <li><strong>Room Inspector:</strong> 7M - 12M VND/month</li>
                        <li><strong>Administrator:</strong> 15M - 30M VND/month</li>
                    </ul>
                </div>
            </c:if>

            <div class="info-box">
                <h6><i class="fas fa-calendar-alt"></i> Age Requirement</h6>
                <p class="small">
                    All staff members must be at least 18 years old at the time of hiring. 
                    This is automatically validated when you enter the date of birth.
                </p>
            </div>
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
        checkPasswordStrength(password, '#newPasswordStrength');
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

    // Real-time password strength indicator for new staff
    <c:if test="${!isEdit}">
    $('#password').on('input', function() {
        var password = $(this).val();
        checkPasswordStrength(password, '#passwordStrength');
    });
    </c:if>

    // Auto-fill department based on role selection
    $('#role').on('change', function() {
        var role = $(this).val();
        var department = '';
        
        switch(role) {
            case 'ADMIN':
                department = 'Management';
                break;
            case 'RECEPTIONIST':
                department = 'Front Office';
                break;
            case 'HOUSEKEEPER':
                department = 'Housekeeping';
                break;
            case 'ROOM_INSPECTOR':
                department = 'Quality Control';
                break;
        }
        
        if (department && !$('#department').val()) {
            $('#department').val(department);
        }
    });

    // Password strength checker function
    function checkPasswordStrength(password, targetElement) {
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
            $(targetElement).html('<span class="' + strengthClass + '">Password strength: ' + strengthText + '</span>');
        } else {
            $(targetElement).html('');
        }
    }

    // Form validation
    $('#staffForm').on('submit', function(e) {
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

        // Username validation (only for new staff)
        <c:if test="${!isEdit}">
        var username = $('#username').val();
        if (username && !/^[a-zA-Z0-9_]{3,20}$/.test(username)) {
            $('#username').addClass('is-invalid');
            errorMessage = 'Username must be 3-20 characters and contain only letters, numbers, and underscores';
            isValid = false;
        }

        // Password validation for new staff
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

        // Role validation (only for non-admin staff)
        <c:if test="${!isEdit || (isEdit && staff.role != 'ADMIN')}">
        var role = $('#role').val();
        if (!role) {
            $('#role').addClass('is-invalid');
            errorMessage = 'Please select a role';
            isValid = false;
        }
        </c:if>

        // Date of birth validation
        var dob = $('#dateOfBirth').val();
        if (dob) {
            var dobDate = new Date(dob);
            var today = new Date();
            var age = today.getFullYear() - dobDate.getFullYear();
            var monthDiff = today.getMonth() - dobDate.getMonth();
            
            if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dobDate.getDate())) {
                age--;
            }
            
            if (age < 18) {
                $('#dateOfBirth').addClass('is-invalid');
                errorMessage = 'Staff member must be at least 18 years old';
                isValid = false;
            }
            
            if (dobDate > today) {
                $('#dateOfBirth').addClass('is-invalid');
                errorMessage = 'Date of birth cannot be in the future';
                isValid = false;
            }
        }

        // Hire date validation
        var hireDate = $('#hireDate').val();
        if (hireDate) {
            var hireDateObj = new Date(hireDate);
            var today = new Date();
            if (hireDateObj > today) {
                $('#hireDate').addClass('is-invalid');
                errorMessage = 'Hire date cannot be in the future';
                isValid = false;
            }
        }

        // Salary validation
        var salary = $('#salary').val();
        if (salary && salary < 0) {
            $('#salary').addClass('is-invalid');
            errorMessage = 'Salary cannot be negative';
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
});
</script>