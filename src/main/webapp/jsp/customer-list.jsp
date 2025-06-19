<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Users - Luxury Hotel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
        }
        .alert-success {
            color: #3c763d;
            background-color: #dff0d8;
            border-color: #d6e9c6;
        }
        .alert-danger {
            color: #a94442;
            background-color: #f2dede;
            border-color: #ebccd1;
        }
        .btn-sm {
            padding: 5px 10px;
            font-size: 12px;
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
        
        /* Enhanced pagination styles */
        .pagination-bx {
            margin-top: 30px;
            text-align: center;
        }
        
        .pagination {
            display: inline-flex;
            padding-left: 0;
            list-style: none;
            border-radius: 0.25rem;
        }
        
        .pagination li {
            margin: 0 2px;
        }
        
        .pagination li a {
            position: relative;
            display: block;
            padding: 0.5rem 0.75rem;
            margin-left: -1px;
            line-height: 1.25;
            color: #007bff;
            background-color: #fff;
            border: 1px solid #dee2e6;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        
        .pagination li a:hover {
            z-index: 2;
            color: #0056b3;
            text-decoration: none;
            background-color: #e9ecef;
            border-color: #dee2e6;
        }
        
        .pagination li.active a {
            z-index: 3;
            color: #fff;
            background-color: #007bff;
            border-color: #007bff;
        }
        
        .pagination li.disabled a {
            color: #6c757d;
            pointer-events: none;
            cursor: auto;
            background-color: #fff;
            border-color: #dee2e6;
        }
        
        .pagination li.previous a,
        .pagination li.next a {
            padding: 0.5rem 1rem;
        }
        
        /* Page info styling */
        .page-info {
            text-align: center;
            margin-top: 20px;
            color: #6c757d;
        }
        
        .page-info strong {
            color: #333;
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
                        <h1 class="text-white">Manage Customer</h1>
                    </div>
                </div>
            </div>
            
            <!-- Breadcrumb -->
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="#">Admin</a></li>
                        <li>Manage Customer</li>
                    </ul>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="section-area section-sp1">
                <div class="container">
                    <!-- Success/Error Messages -->
                    <c:if test="${param.success eq 'added'}">
                        <div class="alert alert-success">User added successfully!</div>
                    </c:if>
                    <c:if test="${param.success eq 'updated'}">
                        <div class="alert alert-success">User updated successfully!</div>
                    </c:if>
                    <c:if test="${param.success eq 'deleted'}">
                        <div class="alert alert-success">User deleted successfully!</div>
                    </c:if>
                    <c:if test="${param.error eq 'delete'}">
                        <div class="alert alert-danger">Failed to delete user!</div>
                    </c:if>
                    
                    <!-- Search and Add Button -->
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <form action="${pageContext.request.contextPath}/admin/customers" method="get" class="form-inline">
                                <input type="hidden" name="action" value="search">
                                <div class="input-group">
                                    <input type="text" name="keyword" class="form-control" 
                                           placeholder="Search by name, email, phone, role..." 
                                           value="${keyword}" style="width: 300px;">
                                    <div class="input-group-append" style="margin-left: 10px;">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fa fa-search"></i> Search
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                        <div class="col-md-6 text-right">
                            <a href="${pageContext.request.contextPath}/admin/customers?action=add" 
                               class="btn btn-success">
                                <i class="fa fa-plus"></i> Add New User
                            </a>
                        </div>
                    </div>
                    
                    <!-- User Table -->
                    <div class="table-responsive">
                        <table class="table table-striped table-bordered">
                            <thead style="background-color: #f8f9fa;">
                                <tr>
                                    <th>ID</th>
                                    <th>Username</th>
                                    <th>Full Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Status</th>
                                    <th>Bookings</th>
                                    <th>Joined Date</th>
                                    <th style="width: 150px;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="customer" items="${customers}">
                                    <tr>
                                        <td>${customer.id}</td>
                                        <td>${customer.username}</td>
                                        <td>${customer.fullName}</td>
                                        <td>
                                            <a href="mailto:${customer.email}">${customer.email}</a>
                                        </td>
                                        <td>${customer.phone}</td>
                                        <td>
                                            <span class="badge ${customer.statusBadgeClass}">
                                                ${customer.statusDisplayName}
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge badge-info">${customer.totalBookings}</span>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${customer.createdAt}" 
                                                            pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/admin/customers?action=detail&id=${customer.id}" 
                                               class="btn btn-sm btn-info" title="View Details">
                                                <i class="fa fa-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/customers?action=edit&id=${customer.id}" 
                                               class="btn btn-sm btn-warning" title="Edit">
                                                <i class="fa fa-edit"></i>
                                            </a>
                                            <button onclick="confirmDelete(${customer.id})" 
                                                    class="btn btn-sm btn-danger" title="Delete">
                                                <i class="fa fa-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                                
                                <c:if test="${empty customers}">
                                    <tr>
                                        <td colspan="9" class="text-center">
                                            <p style="margin: 20px 0;">No users found.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Enhanced Pagination -->
                    <c:if test="${not isSearch and totalPages > 1}">
                        <div class="pagination-bx rounded-sm gray clearfix">
                            <ul class="pagination">
                                <!-- Previous Button -->
                                <c:choose>
                                    <c:when test="${currentPage > 1}">
                                        <li class="previous">
                                            <a href="${pageContext.request.contextPath}/admin/customers?page=${currentPage - 1}">
                                                <i class="ti-arrow-left"></i> Previous
                                            </a>
                                        </li>
                                    </c:when>
                                    <c:otherwise>
                                        <li class="previous disabled">
                                            <a href="#"><i class="ti-arrow-left"></i> Previous</a>
                                        </li>
                                    </c:otherwise>
                                </c:choose>
                                
                                <!-- Page Numbers -->
                                <c:choose>
                                    <c:when test="${totalPages <= 7}">
                                        <!-- Show all pages if total pages <= 7 -->
                                        <c:forEach begin="1" end="${totalPages}" var="page">
                                            <li class="${page == currentPage ? 'active' : ''}">
                                                <a href="${pageContext.request.contextPath}/admin/customers?page=${page}">
                                                    ${page}
                                                </a>
                                            </li>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Smart pagination for many pages -->
                                        <c:choose>
                                            <c:when test="${currentPage <= 4}">
                                                <!-- Near beginning -->
                                                <c:forEach begin="1" end="5" var="page">
                                                    <li class="${page == currentPage ? 'active' : ''}">
                                                        <a href="${pageContext.request.contextPath}/admin/customers?page=${page}">
                                                            ${page}
                                                        </a>
                                                    </li>
                                                </c:forEach>
                                                <li class="disabled"><a href="#">...</a></li>
                                                <li>
                                                    <a href="${pageContext.request.contextPath}/admin/customers?page=${totalPages}">
                                                        ${totalPages}
                                                    </a>
                                                </li>
                                            </c:when>
                                            <c:when test="${currentPage >= totalPages - 3}">
                                                <!-- Near end -->
                                                <li>
                                                    <a href="${pageContext.request.contextPath}/admin/customers?page=1">1</a>
                                                </li>
                                                <li class="disabled"><a href="#">...</a></li>
                                                <c:forEach begin="${totalPages - 4}" end="${totalPages}" var="page">
                                                    <li class="${page == currentPage ? 'active' : ''}">
                                                        <a href="${pageContext.request.contextPath}/admin/customers?page=${page}">
                                                            ${page}
                                                        </a>
                                                    </li>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <!-- In middle -->
                                                <li>
                                                    <a href="${pageContext.request.contextPath}/admin/customers?page=1">1</a>
                                                </li>
                                                <li class="disabled"><a href="#">...</a></li>
                                                <c:forEach begin="${currentPage - 1}" end="${currentPage + 1}" var="page">
                                                    <li class="${page == currentPage ? 'active' : ''}">
                                                        <a href="${pageContext.request.contextPath}/admin/customers?page=${page}">
                                                            ${page}
                                                        </a>
                                                    </li>
                                                </c:forEach>
                                                <li class="disabled"><a href="#">...</a></li>
                                                <li>
                                                    <a href="${pageContext.request.contextPath}/admin/customers?page=${totalPages}">
                                                        ${totalPages}
                                                    </a>
                                                </li>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:otherwise>
                                </c:choose>
                                
                                <!-- Next Button -->
                                <c:choose>
                                    <c:when test="${currentPage < totalPages}">
                                        <li class="next">
                                            <a href="${pageContext.request.contextPath}/admin/customers?page=${currentPage + 1}">
                                                Next <i class="ti-arrow-right"></i>
                                            </a>
                                        </li>
                                    </c:when>
                                    <c:otherwise>
                                        <li class="next disabled">
                                            <a href="#">Next <i class="ti-arrow-right"></i></a>
                                        </li>
                                    </c:otherwise>
                                </c:choose>
                            </ul>
                        </div>
                    </c:if>
                    
                    <!-- Page Info -->
                    <c:if test="${not empty totalRecords}">
                        <div class="page-info">
                            <c:set var="startRecord" value="${(currentPage - 1) * 5 + 1}" />
                            <c:set var="endRecord" value="${currentPage * 5}" />
                            <c:if test="${endRecord > totalRecords}">
                                <c:set var="endRecord" value="${totalRecords}" />
                            </c:if>
                            <p>Showing <strong>${startRecord}-${endRecord}</strong> of <strong>${totalRecords}</strong> users</p>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
        
        <!-- Footer -->
        <jsp:include page="/jsp/footer.jsp" />
    </div>
    
    <!-- Delete Confirmation Form -->
    <form id="deleteForm" method="post" action="${pageContext.request.contextPath}/admin/customers" style="display: none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="id" id="deleteId">
    </form>
    
    <!-- JS -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
    
    <script>
        function confirmDelete(id) {
            if (confirm('Are you sure you want to delete this user? This will mark the user as inactive.')) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteForm').submit();
            }
        }
        
        // Auto hide alerts after 5 seconds
        setTimeout(function() {
            $('.alert').fadeOut('slow');
        }, 5000);
    </script>
</body>
</html>