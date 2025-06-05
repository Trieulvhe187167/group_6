<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
    .detail-card {
        background: white;
        border-radius: 10px;
        padding: 30px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        margin-bottom: 20px;
    }
    
    .customer-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
        padding-bottom: 20px;
        border-bottom: 2px solid #f0f0f0;
    }
    
    .customer-avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background: #5a2b81;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 36px;
        font-weight: bold;
        margin-right: 20px;
    }
    
    .customer-info h2 {
        margin: 0;
        color: #333;
    }
    
    .customer-status {
        display: inline-block;
        padding: 5px 15px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 500;
        margin-left: 10px;
    }
    
    .status-active {
        background: #d4edda;
        color: #155724;
    }
    
    .info-section {
        margin-bottom: 30px;
    }
    
    .info-section h4 {
        color: #5a2b81;
        margin-bottom: 20px;
        font-weight: 600;
    }
    
    .info-row {
        display: flex;
        margin-bottom: 15px;
    }
    
    .info-label {
        width: 150px;
        font-weight: 500;
        color: #666;
    }
    
    .info-value {
        flex: 1;
        color: #333;
    }
    
    .stat-box {
        background: #f8f9fa;
        border-radius: 10px;
        padding: 20px;
        text-align: center;
        margin-bottom: 20px;
    }
    
    .stat-number {
        font-size: 32px;
        font-weight: bold;
        color: #5a2b81;
    }
    
    .stat-label {
        color: #666;
        font-size: 14px;
        text-transform: uppercase;
    }
    
    .action-buttons {
        display: flex;
        gap: 10px;
    }
    
    .btn {
        padding: 8px 16px;
        border: none;
        border-radius: 5px;
        font-size: 14px;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: all 0.3s;
    }
    
    .btn-warning {
        background: #ffc107;
        color: #212529;
    }
    
    .btn-warning:hover {
        background: #e0a800;
    }
    
    .btn-danger {
        background: #dc3545;
        color: white;
    }
    
    .btn-danger:hover {
        background: #c82333;
    }
    
    .booking-table {
        background: white;
        border-radius: 10px;
        padding: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    .table {
        width: 100%;
        margin-bottom: 0;
    }
    
    .table th {
        background: #f8f9fa;
        font-weight: 600;
        color: #5a2b81;
        border-bottom: 2px solid #dee2e6;
    }
    
    @media (max-width: 768px) {
        .customer-header {
            flex-direction: column;
            text-align: center;
        }
        
        .customer-avatar {
            margin: 0 auto 20px;
        }
        
        .info-row {
            flex-direction: column;
        }
        
        .info-label {
            width: 100%;
            margin-bottom: 5px;
        }
    }
</style>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/customers">Customers</a></li>
            <li class="breadcrumb-item active">Customer Detail</li>
        </ol>
    </nav>
    
    <!-- Customer Detail Card -->
    <div class="detail-card">
        <div class="customer-header">
            <div class="d-flex align-items-center">
                <div class="customer-avatar">
                    <c:choose>
                        <c:when test="${not empty customer.fullName}">
                            ${customer.fullName.substring(0, 1).toUpperCase()}
                        </c:when>
                        <c:otherwise>
                            U
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="customer-info">
                    <h2>${customer.fullName}
                        <span class="customer-status status-active">Active</span>
                    </h2>
                    <p class="text-muted mb-0">Customer ID: #${customer.id}</p>
                </div>
            </div>
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/admin/customers?action=edit&id=${customer.id}" 
                   class="btn btn-warning">
                    <i class="fas fa-edit"></i> Edit
                </a>
                <button onclick="confirmDelete(${customer.id})" class="btn btn-danger">
                    <i class="fas fa-trash"></i> Delete
                </button>
            </div>
        </div>
        
        <!-- Customer Statistics -->
        <div class="row mb-4">
            <div class="col-md-3 col-sm-6">
                <div class="stat-box">
                    <div class="stat-number">${customer.totalBookings}</div>
                    <div class="stat-label">Total Bookings</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-box">
                    <div class="stat-number">
                        <fmt:formatNumber value="${totalSpent}" pattern="#,##0"/>₫
                    </div>
                    <div class="stat-label">Total Spent</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-box">
                    <div class="stat-number">${completedBookings}</div>
                    <div class="stat-label">Completed Stays</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="stat-box">
                    <div class="stat-number">
                        <i class="fas fa-star text-warning"></i> ${averageRating}
                    </div>
                    <div class="stat-label">Average Rating</div>
                </div>
            </div>
        </div>
        
        <!-- Basic Information -->
        <div class="info-section">
            <h4><i class="fas fa-info-circle"></i> Basic Information</h4>
            <div class="row">
                <div class="col-md-6">
                    <div class="info-row">
                        <span class="info-label">Username:</span>
                        <span class="info-value">${customer.username}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Email:</span>
                        <span class="info-value">
                            <a href="mailto:${customer.email}">${customer.email}</a>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Phone:</span>
                        <span class="info-value">${customer.phone}</span>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="info-row">
                        <span class="info-label">Member Since:</span>
                        <span class="info-value">
                            <fmt:formatDate value="${customer.createdAt}" pattern="dd/MM/yyyy"/>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Last Updated:</span>
                        <span class="info-value">
                            <fmt:formatDate value="${customer.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Account Type:</span>
                        <span class="info-value">Regular Guest</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Booking History -->
    <div class="booking-table">
        <h4 class="mb-4"><i class="fas fa-history"></i> Booking History</h4>
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Room</th>
                        <th>Check-in</th>
                        <th>Check-out</th>
                        <th>Status</th>
                        <th>Amount</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="booking" items="${bookingHistory}">
                        <tr>
                            <td>#${booking.id}</td>
                            <td>${booking.roomNumber}</td>
                            <td><fmt:formatDate value="${booking.checkIn}" pattern="dd/MM/yyyy"/></td>
                            <td><fmt:formatDate value="${booking.checkOut}" pattern="dd/MM/yyyy"/></td>
                            <td>
                                <span class="badge badge-${booking.status == 'COMPLETED' ? 'success' : 
                                                          booking.status == 'CONFIRMED' ? 'primary' : 
                                                          booking.status == 'CANCELLED' ? 'danger' : 'warning'}">
                                    ${booking.status}
                                </span>
                            </td>
                            <td><fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0"/>₫</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/bookings?action=view&id=${booking.id}" 
                                   class="btn btn-sm btn-info">
                                    <i class="fas fa-eye"></i> View
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    
                    <c:if test="${empty bookingHistory}">
                        <tr>
                            <td colspan="7" class="text-center py-4">No booking history found.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
    
    <!-- Recent Feedback -->
    <c:if test="${not empty feedbacks}">
        <div class="detail-card mt-4">
            <h4 class="mb-4"><i class="fas fa-comments"></i> Recent Feedback</h4>
            <c:forEach var="feedback" items="${feedbacks}">
                <div class="border-bottom pb-3 mb-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <div class="mb-2">
                                <c:forEach begin="1" end="5" var="star">
                                    <i class="fas fa-star ${star <= feedback.rating ? 'text-warning' : 'text-muted'}"></i>
                                </c:forEach>
                                <span class="ml-2 text-muted">
                                    <fmt:formatDate value="${feedback.createdAt}" pattern="dd/MM/yyyy"/>
                                </span>
                            </div>
                            <p class="mb-0">${feedback.comment}</p>
                        </div>
                        <span class="badge badge-info">Booking #${feedback.reservationId}</span>
                    </div>
                </div>
            </c:forEach>
        </div>
    </c:if>
</div>

<!-- Delete Form -->
<form id="deleteForm" method="post" action="${pageContext.request.contextPath}/admin/customers" style="display: none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id" id="deleteId">
</form>

<script>
function confirmDelete(id) {
    if (confirm('Are you sure you want to delete this customer? This action cannot be undone.')) {
        document.getElementById('deleteId').value = id;
        document.getElementById('deleteForm').submit();
    }
}
</script>