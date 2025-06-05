<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .table-container {
        background: white;
        border-radius: 10px;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    .search-box {
        display: flex;
        gap: 10px;
        align-items: center;
    }
    
    .search-box input {
        width: 300px;
        padding: 10px 15px;
        border: 1px solid #e9ecef;
        border-radius: 5px;
        font-size: 14px;
    }
    
    .search-box input:focus {
        outline: none;
        border-color: #5a2b81;
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
        color: white;
    }
    
    .btn-success {
        background: #28a745;
        color: white;
    }
    
    .btn-success:hover {
        background: #218838;
        color: white;
    }
    
    .btn-sm {
        padding: 5px 10px;
        font-size: 12px;
    }
    
    .btn-info {
        background: #17a2b8;
        color: white;
    }
    
    .btn-warning {
        background: #ffc107;
        color: #212529;
    }
    
    .btn-danger {
        background: #dc3545;
        color: white;
    }
    
    .table th {
        background: #f8f9fa;
        font-weight: 600;
        color: #5a2b81;
        border-bottom: 2px solid #dee2e6;
    }
    
    .badge {
        padding: 5px 10px;
        border-radius: 10px;
        font-size: 12px;
        font-weight: 500;
    }
    
    .badge-info {
        background: #17a2b8;
        color: white;
    }
    
    .alert {
        padding: 15px;
        margin-bottom: 20px;
        border-radius: 5px;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .alert-success {
        background: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }
    
    .alert-danger {
        background: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }
    
    @media (max-width: 768px) {
        .search-box {
            flex-direction: column;
            width: 100%;
        }
        
        .search-box input {
            width: 100%;
        }
    }
</style>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item active">Customers</li>
        </ol>
    </nav>
    
    <h1 class="mb-4">Customer Management</h1>
    
    <!-- Success/Error Messages -->
    <c:if test="${param.success eq 'added'}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> Customer added successfully!
        </div>
    </c:if>
    <c:if test="${param.success eq 'updated'}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> Customer updated successfully!
        </div>
    </c:if>
    <c:if test="${param.success eq 'deleted'}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> Customer deleted successfully!
        </div>
    </c:if>
    <c:if test="${param.error eq 'notfound'}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle"></i> Customer not found!
        </div>
    </c:if>
    <c:if test="${param.error eq 'delete'}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle"></i> Failed to delete customer!
        </div>
    </c:if>
    
    <!-- Search and Add Button -->
    <div class="row mb-4">
        <div class="col-md-6">
            <form action="${pageContext.request.contextPath}/admin/customers" method="get" class="search-box">
                <input type="hidden" name="action" value="search">
                <input type="text" name="keyword" 
                       placeholder="Search by name, email, phone..." 
                       value="${keyword}">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-search"></i> Search
                </button>
                <c:if test="${isSearch}">
                    <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Clear
                    </a>
                </c:if>
            </form>
        </div>
        <div class="col-md-6 text-right">
            <a href="${pageContext.request.contextPath}/admin/customers?action=add" 
               class="btn btn-success">
                <i class="fas fa-plus"></i> Add New Customer
            </a>
        </div>
    </div>
    
    <!-- Customer Table -->
    <div class="table-container">
        <c:if test="${isSearch}">
            <p class="mb-3">Search results for: <strong>"${keyword}"</strong> (${customers.size()} found)</p>
        </c:if>
        
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Username</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th class="text-center">Total Bookings</th>
                        <th class="text-center">Total Spent</th>
                        <th>Joined Date</th>
                        <th class="text-center">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="customer" items="${customers}">
                        <tr>
                            <td>#${customer.id}</td>
                            <td>${customer.username}</td>
                            <td>${customer.fullName}</td>
                            <td><a href="mailto:${customer.email}">${customer.email}</a></td>
                            <td>${customer.phone}</td>
                            <td class="text-center">
                                <span class="badge badge-info">${customer.totalBookings}</span>
                            </td>
                            <td class="text-center">
                                <fmt:formatNumber value="${customer.totalSpent}" pattern="#,##0"/>₫
                            </td>
                            <td><fmt:formatDate value="${customer.createdAt}" pattern="dd/MM/yyyy"/></td>
                            <td class="text-center">
                                <a href="${pageContext.request.contextPath}/admin/customers?action=detail&id=${customer.id}" 
                                   class="btn btn-sm btn-info" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/customers?action=edit&id=${customer.id}" 
                                   class="btn btn-sm btn-warning" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <button onclick="confirmDelete(${customer.id})" 
                                        class="btn btn-sm btn-danger" title="Delete">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    
                    <c:if test="${empty customers}">
                        <tr>
                            <td colspan="9" class="text-center py-4">
                                <i class="fas fa-info-circle"></i> No customers found.
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
        
        <c:if test="${not isSearch and not empty customers}">
            <div class="d-flex justify-content-between align-items-center mt-3">
                <div>
                    Showing ${(currentPage - 1) * 10 + 1} to ${currentPage * 10 > totalRecords ? totalRecords : currentPage * 10} of ${totalRecords} customers
                </div>
                
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav>
                        <ul class="pagination mb-0">
                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/customers?page=1">
                                        <i class="fas fa-angle-double-left"></i>
                                    </a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/customers?page=${currentPage - 1}">
                                        <i class="fas fa-angle-left"></i>
                                    </a>
                                </li>
                            </c:if>
                            
                            <c:forEach begin="${currentPage > 2 ? currentPage - 2 : 1}" 
                                      end="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}" 
                                      var="page">
                                <li class="page-item ${page == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/customers?page=${page}">
                                        ${page}
                                    </a>
                                </li>
                            </c:forEach>
                            
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/customers?page=${currentPage + 1}">
                                        <i class="fas fa-angle-right"></i>
                                    </a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="${pageContext.request.contextPath}/admin/customers?page=${totalPages}">
                                        <i class="fas fa-angle-double-right"></i>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </nav>
                </c:if>
            </div>
        </c:if>
    </div>
</div>

<!-- Delete Form -->
<form id="deleteForm" method="post" action="${pageContext.request.contextPath}/admin/customers" style="display: none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id" id="deleteId">
</form>

<script>
function confirmDelete(id) {
    if (confirm('Are you sure you want to delete this customer?\nThis will mark the customer as inactive and cannot be undone.')) {
        document.getElementById('deleteId').value = id;
        document.getElementById('deleteForm').submit();
    }
}

// Auto hide success messages after 5 seconds
setTimeout(function() {
    const alerts = document.querySelectorAll('.alert-success');
    alerts.forEach(function(alert) {
        alert.style.transition = 'opacity 0.5s';
        alert.style.opacity = '0';
        setTimeout(function() {
            alert.remove();
        }, 500);
    });
}, 5000);
</script>