<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .form-container {
        max-width: 800px;
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
    }
    
    .form-control:focus {
        outline: none;
        border-color: #5a2b81;
        box-shadow: 0 0 0 0.2rem rgba(90, 43, 129, 0.25);
    }
    
    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }
    
    .text-danger {
        color: #dc3545;
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
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/customers">Customers</a></li>
            <li class="breadcrumb-item active">${isEdit ? 'Edit' : 'Add'} Customer</li>
        </ol>
    </nav>
    
    <h1 class="mb-4">${isEdit ? 'Edit' : 'Add New'} Customer</h1>
    
    <div class="form-container">
        <!-- Error Message -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> ${error}
            </div>
        </c:if>
        
        <form method="post" action="${pageContext.request.contextPath}/admin/customers" id="customerForm">
            <input type="hidden" name="action" value="${isEdit ? 'update' : 'add'}">
            <c:if test="${isEdit}">
                <input type="hidden" name="id" value="${customer.id}">
            </c:if>
            
            <div class="form-section">
                <h3><i class="fas fa-user"></i> Account Information</h3>
                
                <c:if test="${not isEdit}">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Username <span class="text-danger">*</span></label>
                            <input name="username" type="text" required 
                                   class="form-control" 
                                   placeholder="Enter username"
                                   pattern="[a-zA-Z0-9_]{3,20}"
                                   title="Username must be 3-20 characters, alphanumeric and underscore only"
                                   value="${customer.username}">
                            <small class="text-muted">Username cannot be changed after creation</small>
                        </div>
                        <div class="form-group">
                            <label>Password <span class="text-danger">*</span></label>
                            <input name="password" type="password" required 
                                   class="form-control"
                                   placeholder="Enter password"
                                   pattern=".{6,}"
                                   title="Password must be at least 6 characters">
                            <small class="text-muted">Minimum 6 characters</small>
                        </div>
                    </div>
                </c:if>
                
                <c:if test="${isEdit}">
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" class="form-control" value="${customer.username}" disabled>
                        <small class="text-muted">Username cannot be changed</small>
                    </div>
                </c:if>
            </div>
            
            <div class="form-section">
                <h3><i class="fas fa-info-circle"></i> Personal Information</h3>
                
                <div class="form-group">
                    <label>Full Name <span class="text-danger">*</span></label>
                    <input name="fullName" type="text" required 
                           class="form-control" 
                           placeholder="Enter full name"
                           value="${customer.fullName}">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Email <span class="text-danger">*</span></label>
                        <input name="email" type="email" required 
                               class="form-control" 
                               placeholder="Enter email address"
                               value="${customer.email}">
                    </div>
                    <div class="form-group">
                        <label>Phone <span class="text-danger">*</span></label>
                        <input name="phone" type="text" required 
                               class="form-control" 
                               placeholder="Enter phone number"
                               pattern="0[0-9]{9,10}"
                               title="Phone number must start with 0 and be 10-11 digits"
                               value="${customer.phone}">
                    </div>
                </div>
            </div>
            
            <div class="btn-group">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> ${isEdit ? 'Update' : 'Add'} Customer
                </button>
                <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-secondary">
                    <i class="fas fa-times"></i> Cancel
                </a>
            </div>
        </form>
    </div>
</div>

<script>
// Form validation
document.getElementById('customerForm').addEventListener('submit', function(e) {
    const email = document.querySelector('input[name="email"]').value;
    const phone = document.querySelector('input[name="phone"]').value;
    
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        e.preventDefault();
        alert('Please enter a valid email address');
        return;
    }
    
    // Validate phone format
    const phoneRegex = /^0[0-9]{9,10}$/;
    if (!phoneRegex.test(phone)) {
        e.preventDefault();
        alert('Phone number must start with 0 and be 10-11 digits');
        return;
    }
});
</script>