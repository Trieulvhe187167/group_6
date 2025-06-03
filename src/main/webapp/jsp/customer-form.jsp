<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${isEdit ? 'Edit' : 'Add'} Customer - Luxury Hotel</title>
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
                        <h1 class="text-white">${isEdit ? 'Edit' : 'Add'} Customer</h1>
                    </div>
                </div>
            </div>
            
            <!-- Breadcrumb -->
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/admin/customers">Customers</a></li>
                        <li>${isEdit ? 'Edit' : 'Add'} Customer</li>
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
                                        <h2 class="title-head">${isEdit ? 'Edit' : 'Add New'} <span>Customer</span></h2>
                                    </div>
                                    
                                    <c:if test="${not isEdit}">
                                        <div class="row">
                                            <div class="col-lg-6">
                                                <div class="form-group">
                                                    <label>Username <span class="text-danger">*</span></label>
                                                    <input name="username" type="text" required 
                                                           class="form-control" 
                                                           placeholder="Enter username"
                                                           value="${customer.username}">
                                                </div>
                                            </div>
                                            <div class="col-lg-6">
                                                <div class="form-group">
                                                    <label>Password <span class="text-danger">*</span></label>
                                                    <input name="password" type="password" required 
                                                           class="form-control"
                                                           placeholder="Enter password">
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
                                                       value="${customer.email}">
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Phone <span class="text-danger">*</span></label>
                                                <input name="phone" type="text" required 
                                                       class="form-control" 
                                                       placeholder="Enter phone number"
                                                       pattern="[0-9]{10,11}"
                                                       title="Phone number should be 10-11 digits"
                                                       value="${customer.phone}">
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-lg-12">
                                            <button type="submit" class="btn button-md">
                                                ${isEdit ? 'Update' : 'Add'} Customer
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
</body>
</html>