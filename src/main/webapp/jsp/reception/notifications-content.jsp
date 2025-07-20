<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
        <h2 class="mb-4">Notifications Center</h2>
        
          <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-md-4">
            <div class="stat-card text-center">
                <i class="fas fa-bell stat-icon text-info"></i>
                <div class="stat-number">${totalNotifications}</div>
                <div class="stat-label">Total</div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4">
            <div class="stat-card text-center">
                <i class="fas fa-check-circle stat-icon text-success"></i>
                <div class="stat-number">${sentNotifications}</div>
                <div class="stat-label">Sent</div>
            </div>
        </div>
        <div class="col-12 col-sm-6 col-md-4">
            <div class="stat-card text-center">
                <i class="fas fa-times-circle stat-icon text-danger"></i>
                <div class="stat-number">${failedNotifications}</div>
                <div class="stat-label">Failed</div>
            </div>
        </div>
    </div>

  

<div class="d-flex justify-content-between align-items-center mb-3">
        <div class="form-inline">
            <label class="mr-2">Status:</label>
            <select id="statusFilter" class="form-control">
                <option value="">All</option>
                <option value="SENT">Sent</option>
                <option value="FAILED">Failed</option>
            </select>
        </div>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#bulkModal">
            <i class="fas fa-envelope"></i> Send Bulk Notification
        </button>
    </div>

    <table class="table table-striped" id="notificationTable">
        <thead>
            <tr>
                 <th></th>
                <th>Recipient</th>
                <th>Type</th>
                <th>Message</th>
                <th>Sent At</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="n" items="${notifications}">
                <tr>
                     <tr data-status="${n.status}">
                    <td><i class="fas ${n.typeIcon} text-secondary"></i></td>
                    <td>${n.recipientName}</td>
                    <td>${n.typeDisplayName}</td>
                    <td>${n.message}</td>
                    <td><fmt:formatDate value="${n.sentAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                    <td>
                     <span class="badge ${n.statusBadgeClass}">${n.status}</span>
                        <c:if test="${n.status == 'FAILED'}">
                            <button type="button" class="btn btn-sm btn-outline-primary ml-2" onclick="resendNotification(${n.id}, this)">Resend</button>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty notifications}">
                <tr>
                    <td colspan="6" class="text-center text-muted">No notifications found</td>
                </tr>
            </c:if>
        </tbody>
    </table>
</div>
<!-- Bulk Notification Modal -->
<div class="modal fade" id="bulkModal" tabindex="-1">
    <div class="modal-dialog">
        <form id="bulkForm" class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Send Bulk Notification</h5>
                <button type="button" class="close" data-bs-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="form-group">
                    <label>Type</label>
                    <select name="type" class="form-control" required>
                        <option value="BOOKING_CONFIRM">Booking Confirmation</option>
                        <option value="CHECKIN_REMINDER">Check-in Reminder</option>
                        <option value="CHECKOUT_REMINDER">Check-out Reminder</option>
                        <option value="PAYMENT_CONFIRM">Payment Confirmation</option>
                        <option value="SPECIAL_OFFER">Special Offer</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Message</label>
                    <textarea name="message" class="form-control" rows="3" required></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn btn-primary">Send</button>
            </div>
        </form>
    </div>
</div>

<script>
document.getElementById('statusFilter').addEventListener('change', function () {
    const status = this.value;
    document.querySelectorAll('#notificationTable tbody tr').forEach(function (row) {
        row.style.display = !status || row.dataset.status === status ? '' : 'none';
    });
});

document.getElementById('bulkForm').addEventListener('submit', function (e) {
    e.preventDefault();
    const formData = new URLSearchParams(new FormData(this));
    fetch('${pageContext.request.contextPath}/receptionist/notifications?action=sendBulkNotifications', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: formData
    }).then(r => r.json()).then(data => {
        if (data.success) {
            alert('Sent to ' + data.sentCount + ' customers');
            location.reload();
        } else {
            alert('Failed to send notifications');
        }
    }).catch(() => alert('Failed to send notifications'));
});

function resendNotification(id, btn) {
    fetch('${pageContext.request.contextPath}/receptionist/notifications', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=resendNotification&notificationId=' + id
    }).then(r => r.json()).then(data => {
        if (data.success) {
            alert('Notification resent');
            location.reload();
        } else {
            alert('Resend failed');
        }
    }).catch(() => alert('Resend failed'));
}
</script>
