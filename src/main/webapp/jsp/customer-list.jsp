<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Customers - Luxury Hotel</title>
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
                        <h1 class="text-white">Manage Customers</h1>
                    </div>
                </div>
            </div>
            
            <!-- Breadcrumb -->
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="#">Admin</a></li>
                        <li>Manage Customers</li>
                    </ul>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="section-area section-sp1">
                <div class="container">
                    <!-- Success/Error Messages -->
                    <c:if test="${param.success eq 'added'}">
                        <div class="alert alert-success">Customer added successfully!</div>
                    </c:if>
                    <c:if test="${param.success eq 'updated'}">
                        <div class="alert alert-success">Customer updated successfully!</div>
                    </c:if>
                    <c:if test="${param.success eq 'deleted'}">
                        <div class="alert alert-success">Customer deleted successfully!</div>
                    </c:if>
                    <c:if test="${param.error eq 'delete'}">
                        <div class="alert alert-danger">Failed to delete customer!</div>
                    </c:if>
                    
                    <!-- Search and Add Button -->
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <form action="${pageContext.request.contextPath}/admin/customers" method="get" class="form-inline">
                                <input type="hidden" name="action" value="search">
                                <div class="input-group">
                                    <input type="text" name="keyword" class="form-control" 
                                           placeholder="Search by name, email, phone..." 
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
                                <i class="fa fa-plus"></i> Add New Customer
                            </a>
                        </div>
                    </div>
                    
                    <!-- Customer Table -->
                    <div class="table-responsive">
                        <table class="table table-striped table-bordered">
                            <thead style="background-color: #f8f9fa;">
                                <tr>
                                    <th>ID</th>
                                    <th>Username</th>
                                    <th>Full Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Total Bookings</th>
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
                                        <td colspan="8" class="text-center">
                                            <p style="margin: 20px 0;">No customers found.</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination -->
                    <c:if test="${not isSearch and totalPages > 1}">
                        <div class="pagination-bx rounded-sm gray clearfix">
                            <ul class="pagination">
                                <c:if test="${currentPage > 1}">
                                    <li class="previous">
                                        <a href="${pageContext.request.contextPath}/admin/customers?page=${currentPage - 1}">
                                            <i class="ti-arrow-left"></i> Prev
                                        </a>
                                    </li>
                                </c:if>
                                
                                <c:forEach begin="1" end="${totalPages}" var="page">
                                    <li class="${page == currentPage ? 'active' : ''}">
                                        <a href="${pageContext.request.contextPath}/admin/customers?page=${page}">
                                            ${page}
                                        </a>
                                    </li>
                                </c:forEach>
                                
                                <c:if test="${currentPage < totalPages}">
                                    <li class="next">
                                        <a href="${pageContext.request.contextPath}/admin/customers?page=${currentPage + 1}">
                                            Next <i class="ti-arrow-right"></i>
                                        </a>
                                    </li>
                                </c:if>
                            </ul>
                        </div>
                    </c:if>
                    
                    <!-- Summary -->
                    <c:if test="${not empty totalRecords}">
                        <div class="text-center mt-3">
                            <p>Total customers: <strong>${totalRecords}</strong></p>
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
            if (confirm('Are you sure you want to delete this customer? This action cannot be undone.')) {
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