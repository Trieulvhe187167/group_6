<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>User Detail - Luxury Hotel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        .profile-content-bx {
            background: #fff;
            border: 1px solid #e9e9e9;
            border-radius: 10px;
            overflow: hidden;
        }
        .profile-head {
            background: #f8f9fa;
            padding: 20px;
            border-bottom: 1px solid #e9e9e9;
        }
        .profile-bx {
            padding: 30px;
        }
        .badge {
            display: inline-block;
            padding: .25em .4em;
            font-size: 75%;
            font-weight: 700;
            line-height: 1;
            text-align: center;
            white-space: nowrap;
            vertical-align: baseline;
            border-radius: .25rem;
        }
        .badge-info {
            color: #fff;
            background-color: #17a2b8;
        }
        .badge-danger {
            color: #fff;
            background-color: #dc3545;
        }
        .badge-primary {
            color: #fff;
            background-color: #007bff;
        }
        .badge-success {
            color: #fff;
            background-color: #28a745;
        }
        .badge-secondary {
            color: #fff;
            background-color: #6c757d;
        }
        .form-group label {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        .form-control-static {
            font-size: 16px;
            color: #666;
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
                        <h1 class="text-white">User Detail</h1>
                    </div>
                </div>
            </div>
            
            <!-- Breadcrumb -->
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/admin/customers">Users</a></li>
                        <li>User Detail</li>
                    </ul>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="section-area section-sp1">
                <div class="container">
                    <div class="row">
                        <div class="col-lg-8 col-md-8 col-sm-12 m-auto">
                            <div class="profile-content-bx">
                                <div class="profile-head">
                                    <h3>User Information</h3>
                                </div>
                                
                                <div class="profile-bx">
                                    <div class="row">
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>User ID</label>
                                                <p class="form-control-static">#${customer.id}</p>
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Username</label>
                                                <p class="form-control-static">${customer.username}</p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-lg-12">
                                            <div class="form-group">
                                                <label>Full Name</label>
                                                <p class="form-control-static">${customer.fullName}</p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Email</label>
                                                <p class="form-control-static">
                                                    <a href="mailto:${customer.email}">
                                                        <i class="fa fa-envelope"></i> ${customer.email}
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Phone</label>
                                                <p class="form-control-static">
                                                    <a href="tel:${customer.phone}">
                                                        <i class="fa fa-phone"></i> ${customer.phone}
                                                    </a>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-lg-4">
                                            <div class="form-group">
                                                <label>Role</label>
                                                <p class="form-control-static">
                                                    <span class="badge ${customer.roleBadgeClass}">
                                                        ${customer.roleDisplayName}
                                                    </span>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-lg-4">
                                            <div class="form-group">
                                                <label>Status</label>
                                                <p class="form-control-static">
                                                    <span class="badge ${customer.statusBadgeClass}">
                                                        ${customer.statusDisplayName}
                                                    </span>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-lg-4">
                                            <div class="form-group">
                                                <label>Total Bookings</label>
                                                <p class="form-control-static">
                                                    <span class="badge badge-info">${customer.totalBookings}</span>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Member Since</label>
                                                <p class="form-control-static">
                                                    <i class="fa fa-calendar"></i> 
                                                    <fmt:formatDate value="${customer.createdAt}" 
                                                                    pattern="dd/MM/yyyy HH:mm:ss"/>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-lg-6">
                                            <div class="form-group">
                                                <label>Last Updated</label>
                                                <p class="form-control-static">
                                                    <i class="fa fa-clock"></i> 
                                                    <fmt:formatDate value="${customer.updatedAt}" 
                                                                    pattern="dd/MM/yyyy HH:mm:ss"/>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <hr/>
                                    
                                    <div class="row">
                                        <div class="col-lg-12">
                                            <a href="${pageContext.request.contextPath}/admin/customers?action=edit&id=${customer.id}" 
                                               class="btn btn-warning">
                                                <i class="fa fa-edit"></i> Edit User
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/customers" 
                                               class="btn btn-secondary">
                                                <i class="fa fa-arrow-left"></i> Back to List
                                            </a>
                                        </div>
                                    </div>
                                </div>
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