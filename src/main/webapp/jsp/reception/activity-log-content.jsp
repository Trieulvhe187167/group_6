<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
.activity-item {
    border-left: 4px solid #dee2e6;
    padding: 15px 20px;
    margin-bottom: 10px;
    background: white;
    border-radius: 0 8px 8px 0;
    transition: all 0.3s;
}

.activity-item:hover {
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transform: translateX(2px);
}

.activity-item.success { border-left-color: #28a745; }
.activity-item.warning { border-left-color: #ffc107; }
.activity-item.danger { border-left-color: #dc3545; }
.activity-item.info { border-left-color: #17a2b8; }
.activity-item.primary { border-left-color: #007bff; }

.activity-icon {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    margin-right: 15px;
    font-size: 16px;
}

.activity-time {
    font-size: 12px;
    color: #6c757d;
}

.activity-details {
    font-size: 14px;
    color: #495057;
}

.timeline {
    position: relative;
    padding-left: 30px;
}

.timeline::before {
    content: '';
    position: absolute;
    left: 20px;
    top: 0;
    bottom: 0;
    width: 2px;
    background: #dee2e6;
}

.timeline-item {
    position: relative;
    margin-bottom: 25px;
}

.timeline-item::before {
    content: '';
    position: absolute;
    left: -26px;
    top: 5px;
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: #17a2b8;
    border: 3px solid white;
    box-shadow: 0 0 0 2px #17a2b8;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}
</style>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-6">
            <h2>Activity Log</h2>
            <p class="text-muted">Track all system activities and user actions</p>
        </div>
        <div class="col-md-6 text-right">
            <button class="btn btn-primary" onclick="exportActivityLog()">
                <i class="fas fa-download"></i> Export Report
            </button>
            <button class="btn btn-success" onclick="generateReport()">
                <i class="fas fa-chart-line"></i> Generate Report
            </button>
            <button class="btn btn-info" onclick="refreshActivityLog()">
                <i class="fas fa-sync"></i> Refresh
            </button>
        </div>
    </div>

    <!-- Activity Statistics -->
    <div class="stats-grid">
        <div class="stat-card">
            <i class="fas fa-history stat-icon text-primary"></i>
            <div class="stat-number">${activityStats.totalActivities}</div>
            <div class="stat-label">Total Activities Today</div>
        </div>
        <div class="stat-card">
            <i class="fas fa-users stat-icon text-success"></i>
            <div class="stat-number">${activityStats.activeUsers}</div>
            <div class="stat-label">Active Users</div>
        </div>
        <div class="stat-card">
            <i class="fas fa-sign-in-alt stat-icon text-info"></i>
            <div class="stat-number">${activityStats.checkIns}</div>
            <div class="stat-label">Check-ins Today</div>
        </div>
        <div class="stat-card">
            <i class="fas fa-sign-out-alt stat-icon text-warning"></i>
            <div class="stat-number">${activityStats.checkOuts}</div>
            <div class="stat-label">Check-outs Today</div>
        </div>
        <div class="stat-card">
            <i class="fas fa-calendar-plus stat-icon text-primary"></i>
            <div class="stat-number">${activityStats.newBookings}</div>
            <div class="stat-label">New Bookings</div>
        </div>
        <div class="stat-card">
            <i class="fas fa-credit-card stat-icon text-success"></i>
            <div class="stat-number">${activityStats.payments}</div>
            <div class="stat-label">Payments Processed</div>
        </div>
    </div>

    <!-- Advanced Filters -->
    <div class="table-container mb-4">
        <h5 class="mb-3">Activity Filters</h5>
        <form id="filterForm">
            <div class="row">
                <div class="col-md-2">
                    <div class="form-group">
                        <label>Activity Type</label>
                        <select class="form-control" name="activityType" id="activityTypeFilter">
                            <option value="">All Types</option>
                            <option value="LOGIN" ${param.activityType == 'LOGIN' ? 'selected' : ''}>Login</option>
                            <option value="LOGOUT" ${param.activityType == 'LOGOUT' ? 'selected' : ''}>Logout</option>
                            <option value="CHECK_IN" ${param.activityType == 'CHECK_IN' ? 'selected' : ''}>Check-in</option>
                            <option value="CHECK_OUT" ${param.activityType == 'CHECK_OUT' ? 'selected' : ''}>Check-out</option>
                            <option value="BOOKING" ${param.activityType == 'BOOKING' ? 'selected' : ''}>Booking</option>
                            <option value="PAYMENT" ${param.activityType == 'PAYMENT' ? 'selected' : ''}>Payment</option>
                            <option value="ROOM_CHANGE" ${param.activityType == 'ROOM_CHANGE' ? 'selected' : ''}>Room Change</option>
                            <option value="SERVICE" ${param.activityType == 'SERVICE' ? 'selected' : ''}>Service</option>
                            <option value="SYSTEM" ${param.activityType == 'SYSTEM' ? 'selected' : ''}>System</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>User</label>
                        <select class="form-control" name="userId" id="userFilter">
                            <option value="">All Users</option>
                            <c:forEach var="user" items="${staffUsers}">
                                <option value="${user.id}" ${param.userId == user.id ? 'selected' : ''}>
                                    ${user.fullName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>From Date</label>
                        <input type="date" class="form-control" name="fromDate" id="fromDate" 
                               value="${param.fromDate}">
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>To Date</label>
                        <input type="date" class="form-control" name="toDate" id="toDate" 
                               value="${param.toDate}">
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>Search</label>
                        <input type="text" class="form-control" name="search" id="searchInput" 
                               placeholder="Room, guest name..." value="${param.search}">
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="form-group">
                        <label>&nbsp;</label>
                        <div>
                            <button type="submit" class="btn btn-primary btn-sm">
                                <i class="fas fa-filter"></i> Filter
                            </button>
                            <button type="button" class="btn btn-secondary btn-sm" onclick="clearFilters()">
                                <i class="fas fa-times"></i> Clear
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-3">
                    <div class="form-group">
                        <label>Quick Time Filters</label>
                        <div class="btn-group btn-group-sm" role="group">
                            <button type="button" class="btn btn-outline-secondary" onclick="setTimeFilter('today')">Today</button>
                            <button type="button" class="btn btn-outline-secondary" onclick="setTimeFilter('yesterday')">Yesterday</button>
                            <button type="button" class="btn btn-outline-secondary" onclick="setTimeFilter('week')">This Week</button>
                            <button type="button" class="btn btn-outline-secondary" onclick="setTimeFilter('month')">This Month</button>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="form-group">
                        <label>View Mode</label>
                        <div class="btn-group btn-group-sm" role="group">
                            <button type="button" class="btn btn-outline-info active" onclick="setViewMode('list')" id="listViewBtn">
                                <i class="fas fa-list"></i> List
                            </button>
                            <button type="button" class="btn btn-outline-info" onclick="setViewMode('timeline')" id="timelineViewBtn">
                                <i class="fas fa-stream"></i> Timeline
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <!-- Activity Log Display -->
    <div class="table-container">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5>Activity Log</h5>
            <small class="text-muted">
                Showing ${not empty activities ? activities.size() : 0} activities
                <c:if test="${not empty param.fromDate || not empty param.toDate}">
                    | Filtered results
                </c:if>
            </small>
        </div>

        <!-- List View -->
        <div id="listView">
            <div class="table-responsive">
                <table class="table table-hover" id="activityTable">
                    <thead>
                        <tr>
                            <th>Time</th>
                            <th>User</th>
                            <th>Activity</th>
                            <th>Details</th>
                            <th>Room/Guest</th>
                            <th>IP Address</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty activities}">
                                <c:forEach var="activity" items="${activities}">
                                    <tr class="activity-row" data-activity-type="${activity.activityType}">
                                        <td>
                                            <small>
                                                <fmt:formatDate value="${activity.timestamp}" pattern="dd/MM/yyyy"/>
                                                <br>
                                                <strong><fmt:formatDate value="${activity.timestamp}" pattern="HH:mm:ss"/></strong>
                                            </small>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="rounded-circle bg-primary text-white p-2 mr-2" 
                                                     style="width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; font-size: 12px;">
                                                    ${activity.userName.substring(0,1).toUpperCase()}
                                                </div>
                                                <div>
                                                    <strong>${activity.userName}</strong>
                                                    <br><small class="text-muted">${activity.userRole}</small>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${activity.activityType eq 'LOGIN'}">
                                                    <i class="fas fa-sign-in-alt text-success mr-2"></i>Login
                                                </c:when>
                                                <c:when test="${activity.activityType eq 'LOGOUT'}">
                                                    <i class="fas fa-sign-out-alt text-warning mr-2"></i>Logout
                                                </c:when>
                                                <c:when test="${activity.activityType eq 'CHECK_IN'}">
                                                    <i class="fas fa-door-open text-info mr-2"></i>Check-in
                                                </c:when>
                                                <c:when test="${activity.activityType eq 'CHECK_OUT'}">
                                                    <i class="fas fa-door-closed text-danger mr-2"></i>Check-out
                                                </c:when>
                                                <c:when test="${activity.activityType eq 'BOOKING'}">
                                                    <i class="fas fa-calendar-plus text-primary mr-2"></i>Booking
                                                </c:when>
                                                <c:when test="${activity.activityType eq 'PAYMENT'}">
                                                    <i class="fas fa-credit-card text-success mr-2"></i>Payment
                                                </c:when>
                                                <c:when test="${activity.activityType eq 'ROOM_CHANGE'}">
                                                    <i class="fas fa-exchange-alt text-warning mr-2"></i>Room Change
                                                </c:when>
                                                <c:when test="${activity.activityType eq 'SERVICE'}">
                                                    <i class="fas fa-concierge-bell text-info mr-2"></i>Service
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fas fa-cog text-secondary mr-2"></i>${activity.activityType}
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <strong>${activity.description}</strong>
                                            <c:if test="${not empty activity.details}">
                                                <br><small class="text-muted">${activity.details}</small>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:if test="${not empty activity.roomNumber}">
                                                <span class="badge badge-info">Room ${activity.roomNumber}</span>
                                                <br>
                                            </c:if>
                                            <c:if test="${not empty activity.guestName}">
                                                <small>${activity.guestName}</small>
                                            </c:if>
                                        </td>
                                        <td>
                                            <small class="text-muted">${activity.ipAddress}</small>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${activity.status eq 'SUCCESS'}">
                                                    <span class="badge badge-success">Success</span>
                                                </c:when>
                                                <c:when test="${activity.status eq 'FAILED'}">
                                                    <span class="badge badge-danger">Failed</span>
                                                </c:when>
                                                <c:when test="${activity.status eq 'PENDING'}">
                                                    <span class="badge badge-warning">Pending</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">${activity.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">
                                        <i class="fas fa-history fa-3x mb-3"></i>
                                        <br>No activities found for the selected criteria
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Timeline View -->
        <div id="timelineView" style="display: none;">
            <div class="timeline">
                <c:forEach var="activity" items="${activities}">
                    <div class="timeline-item">
                        <div class="activity-item ${activity.status == 'SUCCESS' ? 'success' : activity.status == 'FAILED' ? 'danger' : 'info'}">
                            <div class="d-flex align-items-start">
                                <div class="activity-icon ${activity.status == 'SUCCESS' ? 'bg-success' : activity.status == 'FAILED' ? 'bg-danger' : 'bg-info'}">
                                    <c:choose>
                                        <c:when test="${activity.activityType eq 'LOGIN'}">
                                            <i class="fas fa-sign-in-alt"></i>
                                        </c:when>
                                        <c:when test="${activity.activityType eq 'CHECK_IN'}">
                                            <i class="fas fa-door-open"></i>
                                        </c:when>
                                        <c:when test="${activity.activityType eq 'CHECK_OUT'}">
                                            <i class="fas fa-door-closed"></i>
                                        </c:when>
                                        <c:when test="${activity.activityType eq 'BOOKING'}">
                                            <i class="fas fa-calendar-plus"></i>
                                        </c:when>
                                        <c:when test="${activity.activityType eq 'PAYMENT'}">
                                            <i class="fas fa-credit-card"></i>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-cog"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <h6 class="mb-1">${activity.description}</h6>
                                            <p class="mb-1 activity-details">${activity.details}</p>
                                            <div class="activity-time">
                                                <i class="fas fa-user mr-1"></i>${activity.userName} |
                                                <i class="fas fa-clock mr-1"></i><fmt:formatDate value="${activity.timestamp}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                                <c:if test="${not empty activity.roomNumber}">
                                                    | <i class="fas fa-door-open mr-1"></i>Room ${activity.roomNumber}
                                                </c:if>
                                            </div>
                                        </div>
                                        <span class="badge badge-${activity.status == 'SUCCESS' ? 'success' : activity.status == 'FAILED' ? 'danger' : 'warning'}">
                                            ${activity.status}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- Activity Summary -->
    <div class="row mt-4">
        <div class="col-md-6">
            <div class="table-container">
                <h6 class="mb-3">Activity Summary by Type</h6>
                <canvas id="activityTypeChart" style="max-height: 300px;"></canvas>
            </div>
        </div>
        <div class="col-md-6">
            <div class="table-container">
                <h6 class="mb-3">Most Active Users</h6>
                <div class="table-responsive">
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>User</th>
                                <th>Activities</th>
                                <th>Success Rate</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="userStat" items="${userActivityStats}" begin="0" end="9">
                                <tr>
                                    <td>${userStat.userName}</td>
                                    <td><span class="badge badge-primary">${userStat.totalActivities}</span></td>
                                    <td>
                                        <div class="progress" style="height: 15px;">
                                            <div class="progress-bar bg-success" style="width: ${userStat.successRate}%">
                                                ${userStat.successRate}%
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    $('#filterForm').submit(function(e) {
        e.preventDefault();
        filterActivities();
    });
    
    // Initialize chart if data is available
    initializeActivityChart();
    
    // Set default date to today
    if (!$('#fromDate').val()) {
        $('#fromDate').val(new Date().toISOString().split('T')[0]);
    }
});

function filterActivities() {
    const params = new URLSearchParams();
    
    const activityType = $('#activityTypeFilter').val();
    const userId = $('#userFilter').val();
    const fromDate = $('#fromDate').val();
    const toDate = $('#toDate').val();
    const search = $('#searchInput').val();
    
    if (activityType) params.append('activityType', activityType);
    if (userId) params.append('userId', userId);
    if (fromDate) params.append('fromDate', fromDate);
    if (toDate) params.append('toDate', toDate);
    if (search) params.append('search', search);
    
    const url = '${pageContext.request.contextPath}/receptionist/activity-log' + 
                (params.toString() ? '?' + params.toString() : '');
    window.location.href = url;
}

function clearFilters() {
    window.location.href = '${pageContext.request.contextPath}/receptionist/activity-log';
}

function setTimeFilter(period) {
    const today = new Date();
    let fromDate, toDate;
    
    switch(period) {
        case 'today':
            fromDate = toDate = today.toISOString().split('T')[0];
            break;
        case 'yesterday':
            const yesterday = new Date(today);
            yesterday.setDate(yesterday.getDate() - 1);
            fromDate = toDate = yesterday.toISOString().split('T')[0];
            break;
        case 'week':
            const weekStart = new Date(today);
            weekStart.setDate(today.getDate() - today.getDay());
            fromDate = weekStart.toISOString().split('T')[0];
            toDate = today.toISOString().split('T')[0];
            break;
        case 'month':
            const monthStart = new Date(today.getFullYear(), today.getMonth(), 1);
            fromDate = monthStart.toISOString().split('T')[0];
            toDate = today.toISOString().split('T')[0];
            break;
    }
    
    $('#fromDate').val(fromDate);
    $('#toDate').val(toDate);
    filterActivities();
}

function setViewMode(mode) {
    if (mode === 'list') {
        $('#listView').show();
        $('#timelineView').hide();
        $('#listViewBtn').addClass('active');
        $('#timelineViewBtn').removeClass('active');
    } else {
        $('#listView').hide();
        $('#timelineView').show();
        $('#listViewBtn').removeClass('active');
        $('#timelineViewBtn').addClass('active');
    }
}

function exportActivityLog() {
    const params = new URLSearchParams(window.location.search);
    params.append('action', 'export');
    params.append('format', 'excel');
    
    window.location.href = '${pageContext.request.contextPath}/receptionist/activity-log?' + params.toString();
}

function generateReport() {
    const params = new URLSearchParams(window.location.search);
    params.append('action', 'report');
    
    window.open('${pageContext.request.contextPath}/receptionist/activity-log?' + params.toString(), '_blank');
}

function refreshActivityLog() {
    location.reload();
}

function initializeActivityChart() {
    // Sample chart implementation - replace with actual data
    const ctx = document.getElementById('activityTypeChart');
    if (ctx && typeof Chart !== 'undefined') {
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Check-in', 'Check-out', 'Booking', 'Payment', 'Service', 'Other'],
                datasets: [{
                    data: [${activityStats.checkIns || 0}, ${activityStats.checkOuts || 0}, 
                           ${activityStats.newBookings || 0}, ${activityStats.payments || 0}, 
                           ${activityStats.services || 0}, ${activityStats.other || 0}],
                    backgroundColor: [
                        '#17a2b8', '#dc3545', '#007bff', '#28a745', '#ffc107', '#6c757d'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
    }
}

// Real-time updates (if needed)
function enableRealTimeUpdates() {
    setInterval(function() {
        // Check for new activities
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/activity-log',
            type: 'POST',
            data: {
                action: 'getLatestCount'
            },
            success: function(count) {
                if (count > ${not empty activities ? activities.size() : 0}) {
                    // Show notification about new activities
                    showNewActivityNotification(count - ${not empty activities ? activities.size() : 0});
                }
            }
        });
    }, 30000); // Check every 30 seconds
}

function showNewActivityNotification(newCount) {
    // Show a small notification about new activities
    const notification = $('<div class="alert alert-info alert-dismissible fade show" role="alert">' +
                           '<i class="fas fa-info-circle mr-2"></i>' +
                           newCount + ' new activities available. ' +
                           '<a href="#" onclick="refreshActivityLog()" class="alert-link">Refresh to view</a>' +
                           '<button type="button" class="close" data-dismiss="alert">' +
                           '<span>&times;</span></button></div>');
    
    $('.container-fluid').prepend(notification);
    
    // Auto-dismiss after 10 seconds
    setTimeout(function() {
        notification.fadeOut();
    }, 10000);
}

// Initialize real-time updates if on the main activity log page
if (window.location.pathname.includes('activity-log')) {
    enableRealTimeUpdates();
}
</script>