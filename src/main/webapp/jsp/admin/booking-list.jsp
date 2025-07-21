<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.List, model.Reservation" %>

            <!-- Breadcrumb -->
            <nav aria-label="breadcrumb" class="mb-4">
                <ol class="breadcrumb bg-white shadow-sm rounded px-3 py-2">
                    <li class="breadcrumb-item">
                        <a href="${pageContext.request.contextPath}/admin-dashboard" class="text-decoration-none">
                            <i class="fas fa-home"></i> Home Dashboard
                        </a>
                    </li>
                    <li class="breadcrumb-item active" aria-current="page">
                        <i class="fas fa-calendar-check"></i> Booking Management
                    </li>
                </ol>
            </nav>
            
            <h2 class="mb-4">Booking Management</h2>
            
            <!-- Filter Section -->
            <div class="filter-section">
                <form class="row" method="GET">
                    <div class="col-md-3">
                        <label for="status">Status</label>
                        <select class="form-control" id="status" name="status">
                            <option value="">All Status</option>
                            <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                            <option value="CONFIRMED" ${param.status == 'CONFIRMED' ? 'selected' : ''}>Confirmed</option>
                            <option value="CANCELLED" ${param.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                            <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="fromDate">From Date</label>
                        <input type="date" class="form-control" id="fromDate" name="fromDate" value="${param.fromDate}">
                    </div>
                    <div class="col-md-3">
                        <label for="toDate">To Date</label>
                        <input type="date" class="form-control" id="toDate" name="toDate" value="${param.toDate}">
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary mr-2">
                            <i class="fas fa-search"></i> Filter
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/bookings" class="btn btn-secondary">
                            <i class="fas fa-undo"></i> Reset
                        </a>
                    </div>
                </form>
            </div>
            
            <!-- Booking Table -->
            <div class="table-responsive">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="mb-0">Booking Management (Page ${currentPage})</h5>
                    <div class="text-muted">
                        <small>Total: ${totalBookings} bookings | Showing: ${((currentPage-1)*5)+1}-${(currentPage*5 > totalBookings) ? totalBookings : currentPage*5}</small>
                    </div>
                </div>
                <table class="table table-bordered table-hover">
                    <thead class="thead-dark">
                        <tr>
                            <th>#</th>
                            <th>Booking ID</th>
                            <th>Customer</th>
                            <th>Room</th>
                            <th>Check-In</th>
                            <th>Check-Out</th>
                            <th>Status</th>
                            <th>Total Amount</th>
                            <th>Created At</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty reservations}">
                                <c:forEach var="b" items="${reservations}" varStatus="i">
                                    <tr>
                                        <td>${((currentPage-1)*5) + i.count}</td>
                            <td><strong>#${b.id}</strong></td>
                                        <td>
                                            <div>
                                                <strong>${b.userFullName}</strong><br>
                                                <small class="text-muted">${b.userEmail}</small>
                                            </div>
                                        </td>
                                        <td>
                                <strong style="font-size: 1.1rem; color: #222;">${b.roomName}</strong>
                                <small class="text-muted" style="font-size: 0.95rem;"> (Room ${b.roomNumber} - ${b.roomTypeName})</small>
                                        </td>
                                        <td><fmt:formatDate value="${b.checkIn}" pattern="dd/MM/yyyy"/></td>
                                        <td><fmt:formatDate value="${b.checkOut}" pattern="dd/MM/yyyy"/></td>
                                        <td>
                                            <span class="badge 
                                                <c:choose>
                                        <c:when test="${b.status == 'CONFIRMED'}"> badge-success</c:when>
                                        <c:when test="${b.status == 'PENDING'}"> badge-warning</c:when>
                                        <c:when test="${b.status == 'CANCELLED'}"> badge-danger</c:when>
                                        <c:when test="${b.status == 'COMPLETED'}"> badge-info</c:when>
                                        <c:otherwise> badge-secondary</c:otherwise>
                                                </c:choose>">
                                                ${b.status}
                                            </span>
                                        </td>
                            <td><strong><fmt:formatNumber value="${b.totalAmount}" pattern=",##0"/> ₫</strong></td>
                                        <td><fmt:formatDate value="${b.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td>
                                            <div class="btn-group" role="group">
                                                <button type="button" class="btn btn-sm btn-info" title="View Details"
                                                     onclick="viewBookingDetail(${b.id})">
                                                        <i class="fas fa-eye"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="10" class="text-center text-muted py-4">
                                        <i class="fas fa-inbox fa-3x mb-3"></i><br>
                                        No bookings found
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <nav aria-label="Booking pagination" class="mt-4">
                        <ul class="pagination justify-content-center">
                            <!-- Previous Page -->
                            <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage - 1}&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}" 
                                   aria-label="Previous" ${currentPage == 1 ? 'tabindex="-1"' : ''}>
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>
                            <!-- Page Numbers -->
                            <c:choose>
                                <c:when test="${totalPages <= 7}">
                                    <c:forEach begin="1" end="${totalPages}" var="page">
                                        <li class="page-item ${currentPage == page ? 'active' : ''}">
                                            <a class="page-link" href="?page=${page}&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}">
                                                ${page}
                                            </a>
                                        </li>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <c:choose>
                                        <c:when test="${currentPage <= 4}">
                                            <c:forEach begin="1" end="5" var="page">
                                                <li class="page-item ${currentPage == page ? 'active' : ''}">
                                                    <a class="page-link" href="?page=${page}&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}">
                                                        ${page}
                                                    </a>
                                                </li>
                                            </c:forEach>
                                            <li class="page-item disabled">
                                                <span class="page-link">...</span>
                                            </li>
                                            <li class="page-item">
                                                <a class="page-link" href="?page=${totalPages}&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}">
                                                    ${totalPages}
                                                </a>
                                            </li>
                                        </c:when>
                                        <c:when test="${currentPage >= totalPages - 3}">
                                            <li class="page-item">
                                                <a class="page-link" href="?page=1&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}">
                                                    1
                                                </a>
                                            </li>
                                            <li class="page-item disabled">
                                                <span class="page-link">...</span>
                                            </li>
                                            <c:forEach begin="${totalPages - 4}" end="${totalPages}" var="page">
                                                <li class="page-item ${currentPage == page ? 'active' : ''}">
                                                    <a class="page-link" href="?page=${page}&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}">
                                                        ${page}
                                                    </a>
                                                </li>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <li class="page-item">
                                                <a class="page-link" href="?page=1&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}">
                                                    1
                                                </a>
                                            </li>
                                            <li class="page-item disabled">
                                                <span class="page-link">...</span>
                                            </li>
                                            <c:forEach begin="${currentPage - 1}" end="${currentPage + 1}" var="page">
                                                <li class="page-item ${currentPage == page ? 'active' : ''}">
                                                    <a class="page-link" href="?page=${page}&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}">
                                                        ${page}
                                                    </a>
                                                </li>
                                            </c:forEach>
                                            <li class="page-item disabled">
                                                <span class="page-link">...</span>
                                            </li>
                                            <li class="page-item">
                                                <a class="page-link" href="?page=${totalPages}&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}">
                                                    ${totalPages}
                                                </a>
                                            </li>
                                        </c:otherwise>
                                    </c:choose>
                                </c:otherwise>
                            </c:choose>
                            <!-- Next Page -->
                            <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a class="page-link" href="?page=${currentPage + 1}&status=${param.status}&fromDate=${param.fromDate}&toDate=${param.toDate}" 
                                   aria-label="Next" ${currentPage == totalPages ? 'tabindex="-1"' : ''}>
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
        </div>

<!-- Booking Detail Modal -->
<div class="modal fade" id="bookingDetailModal" tabindex="-1" role="dialog" aria-labelledby="bookingDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Reservation Details</h5>
        <button type="button" class="close" data-dismiss="modal">
          <span>&times;</span>
        </button>
      </div>
      <div class="modal-body row">
        <!-- Customer Information -->
        <div class="col-md-6">
          <h6>Customer Information</h6>
          <p><strong>Name:</strong> <span id="customerName"></span></p>
          <p><strong>Phone:</strong> <span id="customerPhone"></span></p>
          <p><strong>Email:</strong> <span id="customerEmail"></span></p>

          <h6>Booking Information</h6>
          <p><strong>ID:</strong> <span id="bookingId"></span></p>
          <p><strong>Status:</strong> <span id="bookingStatus" class="badge"></span></p>
          <p><strong>Created:</strong> <span id="bookingCreated"></span></p>
        </div>

        <!-- Room & Payment Info -->
        <div class="col-md-6">
          <h6>Room Information</h6>
          <p><strong>Room:</strong> <span id="roomNumber"></span></p>
          <p><strong>Type:</strong> <span id="roomType"></span></p>
          <p><strong>Check-in:</strong> <span id="checkInDate"></span></p>
          <p><strong>Check-out:</strong> <span id="checkOutDate"></span></p>
          <p><strong>Nights:</strong> <span id="nights"></span></p>

          <h6>Payment</h6>
          <p><strong>Total:</strong> <span id="totalAmount"></span></p>
          <p><strong>Payment Status:</strong> <span id="paymentStatus" class="badge"></span></p>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-dismiss="modal">Close</button>
        <button class="btn btn-primary" onclick="window.print()">Print</button>
      </div>
    </div>
  </div>
</div>

<!-- Scripts đặc thù cho trang này (nếu cần) -->
<script>
function viewBookingDetail(id) {
  fetch('${pageContext.request.contextPath}/admin/api/booking-detail?id=' + id)
    .then(res => res.json())
    .then(data => {
  document.getElementById("customerName").innerText = data.userFullName;
  document.getElementById("customerPhone").innerText = data.customerPhone;
  document.getElementById("customerEmail").innerText = data.customerEmail;
  document.getElementById("bookingId").innerText = "#" + data.id;
  document.getElementById("bookingStatus").innerText = data.status;
  document.getElementById("bookingStatus").className = "badge " +
    (data.status === 'CONFIRMED' ? 'badge-success' : 'badge-secondary');
  document.getElementById("bookingCreated").innerText = data.createdAt;
  document.getElementById("roomNumber").innerText = data.roomNumber;
  document.getElementById("roomType").innerText = data.roomTypeName;
  document.getElementById("checkInDate").innerText = data.checkIn;
  document.getElementById("checkOutDate").innerText = data.checkOut;
  document.getElementById("nights").innerText = data.nights;
  document.getElementById("totalAmount").innerText = data.totalAmount;
  document.getElementById("paymentStatus").innerText = data.paymentStatus;
  document.getElementById("paymentStatus").className = "badge " +
    (data.paymentStatus === 'Paid' ? 'badge-success' : 'badge-warning');
  $('#bookingDetailModal').modal('show');
});
}
</script>

