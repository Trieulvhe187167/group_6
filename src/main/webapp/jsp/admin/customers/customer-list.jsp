<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">Customer Management</li>
        </ol>
    </nav>
    
    <!-- Alert Messages -->
    <c:if test="${not empty sessionScope.success}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            ${sessionScope.success}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
        <c:remove var="success" scope="session"/>
    </c:if>
    
    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${sessionScope.error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
        <c:remove var="error" scope="session"/>
    </c:if>
    
    <c:if test="${not empty error}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            ${error}
            <button type="button" class="close" data-dismiss="alert">
                <span>&times;</span>
            </button>
        </div>
    </c:if>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">
            <c:choose>
                <c:when test="${isTrashView}">
                    <i class="fas fa-trash"></i> Deleted Customers
                </c:when>
                <c:otherwise>
                    <i class="fas fa-users"></i> Customer Management
                </c:otherwise>
            </c:choose>
        </h1>
              <c:if test="${isTrashView}">
                <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-primary">
                    <i class="fas fa-arrow-left"></i> Back to Customers
                </a>
            </c:if>

    </div>
    
    <!-- Filters and Search -->
    <c:if test="${!isTrashView}">
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/admin/customers" class="form-inline" style="width:100%; display:flex; align-items:center; gap:15px; flex-wrap:wrap;">
                    <!-- Search -->
                    <div class="form-group">
                        <label class="mr-2">Search:</label>
                        <input type="text" name="search" class="form-control" 
                               placeholder="Name, email, phone..." value="${searchKeyword}" style="width: 250px;">
                    </div>
                    
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i> Search
                    </button>
                    
                    <c:if test="${not empty searchKeyword}">
                        <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Clear
                        </a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/admin/customers?action=trash" class="btn btn-secondary">
                    <i class="fas fa-trash"></i> View Trash
                </a>
                <a href="${pageContext.request.contextPath}/admin/customers?action=form" class="btn btn-success">
                    <i class="fas fa-plus"></i> Add New Customer
                </a>
            
                </form>
                    
            </div>
        </div>
    </c:if>
    
   
    
    <!-- Customers Table -->
    <div class="table-container">
        <c:choose>
            <c:when test="${not empty customers}">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <small class="text-muted">
                        Showing ${(currentPage - 1) * 10 + 1} - 
                        ${currentPage * 10 > totalRecords ? totalRecords : currentPage * 10} 
                        of ${totalRecords} customers
                    </small>
                    
                
                </div>
                
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="thead-light">
                            <tr>
                                <th>#</th>
                                <th>Customer Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Username</th>
                                <th>Status</th>
                                <th>Total Bookings</th>
                               
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="customer" items="${customers}" varStatus="status">
                                <tr>
                                    <td>${(currentPage - 1) * 10 + status.index + 1}</td>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="avatar-circle mr-2" style="width: 35px; height: 35px; background: #5a2b81; color: white; display: flex; align-items: center; justify-content: center; border-radius: 50%; font-size: 14px; font-weight: bold;">
                                                ${customer.fullName.substring(0, 1).toUpperCase()}
                                            </div>
                                            <div>
                                                <strong>${customer.fullName}</strong>
                                                <c:if test="${customer.totalBookings >= 10}">
                                                    <span class="badge badge-warning ml-1">VIP</span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <a href="mailto:${customer.email}">${customer.email}</a>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty customer.phone}">
                                                <a href="tel:${customer.phone}">${customer.phone}</a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Not provided</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <code>${customer.username}</code>
                                    </td>
                                    <td>
                                        <span class="badge ${customer.statusBadgeClass}">
                                            ${customer.statusDisplayName}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge badge-info">${customer.totalBookings}</span>
                                    </td>
                                   
                                    <td>
                                        <c:if test="${!isTrashView}">
                                            <div class="btn-group" role="group">
                                                <a href="${pageContext.request.contextPath}/admin/customers?action=view&id=${customer.id}" 
                                                   class="btn btn-sm btn-info" title="View Details">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/customers?action=form&id=${customer.id}" 
                                                   class="btn btn-sm btn-warning" title="Edit">
                                                    <i class="fas fa-edit"></i>
                                                </a>
                                                <button onclick="confirmDelete(${customer.id}, '${customer.fullName}')" 
                                                        class="btn btn-sm btn-danger" title="Delete">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </c:if>
                                        <c:if test="${isTrashView}">
                                            <button onclick="confirmRestore(${customer.id}, '${customer.fullName}')" 
                                                    class="btn btn-sm btn-success" title="Restore">
                                                <i class="fas fa-undo"></i> Restore
                                            </button>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Page navigation" class="mt-4">
                        <ul class="pagination justify-content-center">
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&search=${searchKeyword}${isTrashView ? '&action=trash' : ''}">
                                    <i class="fas fa-chevron-left"></i>
                                </a>
                            </li>
                            
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <c:if test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="?page=${i}&search=${searchKeyword}${isTrashView ? '&action=trash' : ''}">
                                            ${i}
                                        </a>
                                    </li>
                                </c:if>
                                <c:if test="${i == currentPage - 3 || i == currentPage + 3}">
                                    <li class="page-item disabled">
                                        <span class="page-link">...</span>
                                    </li>
                                </c:if>
                            </c:forEach>
                            
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&search=${searchKeyword}${isTrashView ? '&action=trash' : ''}">
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5">
                    <i class="fas fa-users fa-3x text-muted mb-3"></i>
                    <h5 class="text-muted">
                        <c:choose>
                            <c:when test="${isTrashView}">No deleted customers found</c:when>
                            <c:when test="${not empty searchKeyword}">No customers found matching "${searchKeyword}"</c:when>
                            <c:otherwise>No customers found</c:otherwise>
                        </c:choose>
                    </h5>
                    <c:if test="${!isTrashView && empty searchKeyword}">
                        <a href="${pageContext.request.contextPath}/admin/customers?action=form" class="btn btn-primary">
                            <i class="fas fa-plus"></i> Add First Customer
                        </a>
                    </c:if>
                    <c:if test="${not empty searchKeyword}">
                        <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Back to All Customers
                        </a>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Delete</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete customer "<strong><span id="deleteCustomerName"></span></strong>"?</p>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i>
                    This action will move the customer to trash. You can restore them later if needed.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <a id="deleteConfirmLink" href="#" class="btn btn-danger">
                    <i class="fas fa-trash"></i> Delete Customer
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Restore Confirmation Modal -->
<div class="modal fade" id="restoreModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Restore</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to restore customer "<strong><span id="restoreCustomerName"></span></strong>"?</p>
                <div class="alert alert-info">
                    <i class="fas fa-info-circle"></i>
                    This will restore the customer and make them active again.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <a id="restoreConfirmLink" href="#" class="btn btn-success">
                    <i class="fas fa-undo"></i> Restore Customer
                </a>
            </div>
        </div>
    </div>
</div>

<script>
function confirmDelete(customerId, customerName) {
    document.getElementById('deleteCustomerName').textContent = customerName;
    document.getElementById('deleteConfirmLink').href = 
        '${pageContext.request.contextPath}/admin/customers?action=delete&id=' + customerId;
    $('#deleteModal').modal('show');
}

function confirmRestore(customerId, customerName) {
    document.getElementById('restoreCustomerName').textContent = customerName;
    document.getElementById('restoreConfirmLink').href = 
        '${pageContext.request.contextPath}/admin/customers?action=restore&id=' + customerId;
    $('#restoreModal').modal('show');
}

function exportCustomers(format) {
    // Implementation for export functionality
    const url = '${pageContext.request.contextPath}/admin/customers/export?format=' + format;
    window.open(url, '_blank');
}

// Auto-hide alerts after 5 seconds
$(document).ready(function() {
    setTimeout(function() {
        $('.alert').fadeOut('slow');
    }, 5000);
});
</script>