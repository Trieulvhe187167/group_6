<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
            <li class="breadcrumb-item active">Bookings</li>
        </ol>
    </nav>
    
    <h1 class="mb-4">Booking Management</h1>
    
    <!-- Buttons -->
    <div class="mb-4">
        <a href="${pageContext.request.contextPath}/admin/bookings?action=new" class="btn btn-primary">
            <i class="fas fa-plus"></i> New Booking
        </a>
        <button class="btn btn-secondary" onclick="exportBookings()">
            <i class="fas fa-download"></i> Export
        </button>
    </div>
    
    <!-- Table -->
    <div class="table-container">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Customer</th>
                    <th>Room</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Status</th>
                    <th>Total Amount</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="booking" items="${bookings}">
                    <tr>
                        <td>#${booking.id}</td>
                        <td>${booking.customerName}</td>
                        <td>${booking.roomNumber}</td>
                        <td><fmt:formatDate value="${booking.checkIn}" pattern="dd/MM/yyyy"/></td>
                        <td><fmt:formatDate value="${booking.checkOut}" pattern="dd/MM/yyyy"/></td>
                        <td>
                            <span class="badge badge-${booking.status == 'CONFIRMED' ? 'success' : 
                                                      booking.status == 'PENDING' ? 'warning' : 
                                                      'danger'}">
                                ${booking.status}
                            </span>
                        </td>
                        <td><fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0"/>₫</td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/bookings?action=view&id=${booking.id}" 
                               class="btn btn-sm btn-info">View</a>
                            <a href="${pageContext.request.contextPath}/admin/bookings?action=edit&id=${booking.id}" 
                               class="btn btn-sm btn-warning">Edit</a>
                        </td>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty bookings}">
                    <tr>
                        <td colspan="8" class="text-center py-4">
                            <p class="mb-0">No bookings found</p>
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<script>
    function exportBookings() {
        // Implementation for export
        window.location.href = '${pageContext.request.contextPath}/admin/bookings?action=export';
    }
</script>