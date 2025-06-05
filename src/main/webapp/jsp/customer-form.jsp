<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${isEdit ? 'Edit' : 'Add'} User - Luxury Hotel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
    
    <style>
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
        }
        .alert-danger {
            color: #a94442;
            background-color: #f2dede;
            border-color: #ebccd1;
        }
        .text-danger {
            color: #dc3545;
        }
    </style>
</head>
<body id="bg">
    <div class="page-wraper">
        <!-- Header -->
        <jsp:include page="/jsp/header.jsp" />
        
        <!-- Content -->
        <div class="page-content bg-white">
            <!-- Page Banner -->
            <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                <div class="container">
                    <div class="page-banner-entry">
                        <h1 class="text-white">${isEdit ? 'Edit' : 'Add'} User</h1>
                    </div>
                </div>
            </div>
            
            <!-- Breadcrumb -->
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/admin/customers">Users</a></li>
                        <li>${isEdit ? 'Edit' : 'Add'} User</li>
                    </ul>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="section-area section-sp1">
                <div class="container">
                    <div class="row">
                        <div class="col-lg-8 col-md-8 col-sm-12 m-auto">
                            <div style="background-color: #f8f9fa; padding: 40px; border-radius: 10px;">
                                <!-- Error Message -->
                                <c:if test="${not empty error}">
                                    <div class="alert alert-danger">${error}</div>
                                </c:if>
                                
                                <form method="post" action="${pageContext.request.contextPath}/admin/customers" 
                                      class="contact-bx">
                                    <input type="hidden" name="action" value="${isEdit ? 'update' : 'add'}">
                                    <c:if test="${isEdit}">
                                        <input type="hidden" name="id" value="${customer.id}">
                                    </c:if>
                                    
                                    <div class="heading-bx left mb-4">
                                        <h2 class="title-head">${isEdit ? 'Edit' : 'Add New'} <span>User</span></h2>
                                    </div>
                                    
                                    <c:if test="${not isEdit}">
                                        <div class="row">
                                            <div class="col-lg-6">
                                                <div class="form-group">
                                                    <label>Username <span class="text-danger">*</span></label>
                                                    <input name="username" type="text" required 
                                                           class="form-control" 
                                                           placeholder="Enter username"
                                                           pattern="[a-zA-Z0-9_]{3,20}"
                                                           title="Username must be 3-20 characters long and contain only letters, numbers, and underscores"
                                                           value="${customer.username}">
                                                    <small class="form-text text-muted">
                                                        3-20 characters, letters, numbers and underscore only
                                                    </small>
                                                </div>
                                            </div>
                                            <div class="col-lg-6">
                                                <div class="form-group">
                                                    <label>Password <span class="text-danger">*</span></label>
                                                    <input name="password" type="password" required 
                                                           class="form-control"
                                                           placeholder="Enter password"
                                                           pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&+=!]).{8,}$"
                                                           title="Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one digit, and one special character (@#$%^&+=!)">
                                                    <small class="form-text text-muted">
                                                        Password must contain:
                                                        <ul style="margin-left: 20px; font-size: 12px;">
                                                            <li>At least 8 characters</li>
                                                            <li>At least one uppercase letter (A-Z)</li>
                                                            <li>At least one lowercase letter (a-z)</li>
                                                            <li>At least one digit (0-9)</li>
                                                            <li>At least one special character (@#$%^&+=!)</li>
                                                        </ul>
                                                    </small>
                                                </div>
                                            </div>
                                        </div>
                                    </c:if>
                                    
                                    <div class="row">
                                        <div class="col-lg-12">
                                            <div class="form-group">
                                                <label>Full Name <span class="text-danger">*</span></label>
                                                <input name="fullName" type="text" required 
                                                       class="form-control" 
                                                       placeholder="Enter full name"
                                                       value="${customer.fullName}">
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Email <span class="text-danger">*</span></label>
                                                <input name="email" type="email" required 
                                                       class="form-control" 
                                                       placeholder="Enter email address"
                                                       pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
                                                       title="Please enter a valid email address"
                                                       value="${customer.email}">
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Phone <span class="text-danger">*</span></label>
                                                <input name="phone" type="text" required 
                                                       class="form-control" 
                                                       placeholder="Enter phone number (10 digits)"
                                                       pattern="[0-9]{10}"
                                                       maxlength="10"
                                                       title="Phone number must be exactly 10 digits"
                                                       value="${customer.phone}">
                                                <small class="form-text text-muted">
                                                    Phone number must be exactly 10 digits (e.g., 0123456789)
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-lg-12">
                                            <div class="form-group">
                                                <label>Role <span class="text-danger">*</span></label>
                                                <select name="role" class="form-control" required>
<!--                                                    <option value="">Select Role</option>-->
<!--                                                    <option value="ADMIN" 
                                                            <c:if test="${customer.role eq 'ADMIN'}">selected</c:if>>
                                                        Administrator
                                                    </option>
                                                    <option value="RECEPTIONIST" 
                                                            <c:if test="${customer.role eq 'RECEPTIONIST'}">selected</c:if>>
                                                        Receptionist
                                                    </option>
                                                    <option value="HOUSEKEEPER" 
                                                            <c:if test="${customer.role eq 'HOUSEKEEPER'}">selected</c:if>>
                                                        Housekeeper
                                                    </option>-->
                                                    <option value="GUEST" 
                                                            <c:if test="${customer.role eq 'GUEST' or empty customer.role}">selected</c:if>>
                                                        Guest
                                                    </option>
                                                </select>
                                                <small class="form-text text-muted">
                                                    Note: Users can be deactivated by deleting them (sets Status = 0)
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-lg-12">
                                            <button type="submit" class="btn button-md">
                                                ${isEdit ? 'Update' : 'Add'} User
                                            </button>
                                            <a href="${pageContext.request.contextPath}/admin/customers" 
                                               class="btn btn-secondary button-md">
                                                Cancel
                                            </a>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Footer -->
        <jsp:include page="/jsp/footer.jsp" />
    </div>
    
    <!-- JS -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
    
    <script>
        // Only allow numbers in phone input
        document.querySelector('input[name="phone"]').addEventListener('input', function(e) {
            this.value = this.value.replace(/[^0-9]/g, '');
        });
        
        // Password strength indicator
        <c:if test="${not isEdit}">
        document.querySelector('input[name="password"]').addEventListener('input', function(e) {
            const password = this.value;
            const hasUpperCase = /[A-Z]/.test(password);
            const hasLowerCase = /[a-z]/.test(password);
            const hasNumbers = /\d/.test(password);
            const hasSpecialChar = /[@#$%^&+=!]/.test(password);
            const isLongEnough = password.length >= 8;
            
            // Update visual feedback
            const requirements = this.parentElement.querySelector('ul');
            if (requirements) {
                const items = requirements.getElementsByTagName('li');
                items[0].style.color = isLongEnough ? 'green' : 'inherit';
                items[1].style.color = hasUpperCase ? 'green' : 'inherit';
                items[2].style.color = hasLowerCase ? 'green' : 'inherit';
                items[3].style.color = hasNumbers ? 'green' : 'inherit';
                items[4].style.color = hasSpecialChar ? 'green' : 'inherit';
            }
        });
        </c:if>
    </script>
</body>
</html>