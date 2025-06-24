<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">Pending Change Requests</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">
            <i class="fas fa-clock"></i> Pending Change Requests
        </h1>
        <div>
            <button class="btn btn-info" onclick="refreshPage()">
                <i class="fas fa-sync-alt"></i> Refresh
            </button>
        </div>
    </div>
    
    <!-- Statistics Cards -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card bg-warning text-white">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="small">Pending Requests</div>
                            <div class="h4">${pendingCount}</div>
                        </div>
                        <div class="ml-2">
                            <i class="fas fa-clock fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-success text-white">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="small">Approved Today</div>
                            <div class="h4">${approvedToday}</div>
                        </div>
                        <div class="ml-2">
                            <i class="fas fa-check fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-danger text-white">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="small">Expired/Rejected</div>
                            <div class="h4">${expiredCount}</div>
                        </div>
                        <div class="ml-2">
                            <i class="fas fa-times fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-info text-white">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="flex-grow-1">
                            <div class="small">Total This Month</div>
                            <div class="h4">${totalThisMonth}</div>
                        </div>
                        <div class="ml-2">
                            <i class="fas fa-chart-line fa-2x"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Pending Changes Table -->
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0">Recent Change Requests</h5>
        </div>
        <div class="card-body">
            <c:choose>
                <c:when test="${not empty pendingChanges}">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="thead-light">
                                <tr>
                                    <th>User</th>
                                    <th>Change Type</th>
                                    <th>Requested Value</th>
                                    <th>Initiated By</th>
                                    <th>Status</th>
                                    <th>Created</th>
                                    <th>Expires</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="change" items="${pendingChanges}">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="avatar-circle mr-2" style="width: 30px; height: 30px; background: #5a2b81; color: white; display: flex; align-items: center; justify-content: center; border-radius: 50%; font-size: 12px; font-weight: bold;">
                                                    ${change.userName.substring(0, 1).toUpperCase()}
                                                </div>
                                                <div>
                                                    <strong>${change.userName}</strong>
                                                    <br><small class="text-muted">${change.userRole}</small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge badge-info">${change.changeTypeDisplayName}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${change.changeType == 'EMAIL'}">${change.newEmail}</c:when>
                                                <c:when test="${change.changeType == 'PHONE'}">${change.newPhone}</c:when>
                                                <c:when test="${change.changeType == 'PASSWORD'}">********</c:when>
                                                <c:otherwise>N/A</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${change.initiatedByName}</td>
                                        <td>
                                            <span class="badge ${change.statusBadgeClass}">${change.status}</span>
                                            <c:if test="${change.status == 'PENDING' && change.hoursUntilExpiry < 12}">
                                                <br><small class="text-warning">Expires soon!</small>
                                            </c:if>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${change.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${change.tokenExpiry}" pattern="dd/MM/yyyy HH:mm"/>
                                            <br><small class="text-muted">${change.hoursUntilExpiry}h left</small>
                                        </td>
                                        <td>
                                            <div class="btn-group btn-group-sm">
                                                <button class="btn btn-outline-info" onclick="viewDetails('${change.id}')">
                                                    <i class="fas fa-eye"></i>
                                                </button>
                                                <c:if test="${change.status == 'PENDING'}">
                                                    <button class="btn btn-outline-warning" onclick="sendReminder('${change.id}')">
                                                        <i class="fas fa-bell"></i>
                                                    </button>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">No pending change requests</h5>
                        <p class="text-muted">All change requests have been processed or expired.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script>
function refreshPage() {
    window.location.reload();
}

function viewDetails(changeId) {
    // Implementation to view change details
    window.location.href = '${pageContext.request.contextPath}/admin/change-request?action=view&id=' + changeId;
}

function sendReminder(changeId) {
    if (confirm('Send reminder email to the user?')) {
        // Implementation to send reminder
        fetch('${pageContext.request.contextPath}/admin/change-request', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=send-reminder&changeId=' + changeId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Reminder sent successfully!');
                refreshPage();
            } else {
                alert('Failed to send reminder: ' + data.error);
            }
        })
        .catch(error => {
            alert('Error sending reminder: ' + error);
        });
    }
}

// Auto-refresh every 5 minutes
setInterval(refreshPage, 5 * 60 * 1000);
</script>