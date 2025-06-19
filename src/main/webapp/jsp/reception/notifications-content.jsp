<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
.notification-item {
    border: 1px solid #dee2e6;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 10px;
    transition: all 0.3s;
    cursor: pointer;
    background: white;
}

.notification-item:hover {
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transform: translateY(-1px);
}

.notification-item.unread {
    border-left: 4px solid #17a2b8;
    background: #f8f9fa;
}

.notification-item.urgent {
    border-left: 4px solid #dc3545;
    background: #fff5f5;
}

.notification-icon {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    margin-right: 15px;
}

.notification-content {
    flex: 1;
}

.notification-time {
    font-size: 12px;
    color: #6c757d;
}

.notification-actions {
    display: none;
}

.notification-item:hover .notification-actions {
    display: block;
}

.priority-high { background-color: #dc3545; color: white; }
.priority-medium { background-color: #ffc107; color: #212529; }
.priority-low { background-color: #28a745; color: white; }
.priority-info { background-color: #17a2b8; color: white; }
</style>

<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-6">
            <h2>Notifications Center</h2>
            <p class="text-muted">Stay updated with hotel operations and guest requests</p>
        </div>
        <div class="col-md-6 text-right">
            <button class="btn btn-primary" data-toggle="modal" data-target="#newNotificationModal">
                <i class="fas fa-plus"></i> New Notification
            </button>
            <button class="btn btn-success" onclick="markAllAsRead()">
                <i class="fas fa-check-double"></i> Mark All Read
            </button>
            <button class="btn btn-info" onclick="refreshNotifications()">
                <i class="fas fa-sync"></i> Refresh
            </button>
        </div>
    </div>

    <!-- Notification Statistics -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-bell stat-icon text-warning"></i>
                <div class="stat-number">${notificationStats.unreadCount}</div>
                <div class="stat-label">Unread Notifications</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-exclamation-triangle stat-icon text-danger"></i>
                <div class="stat-number">${notificationStats.urgentCount}</div>
                <div class="stat-label">Urgent Alerts</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-calendar-day stat-icon text-info"></i>
                <div class="stat-number">${notificationStats.todayCount}</div>
                <div class="stat-label">Today's Notifications</div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stat-card">
                <i class="fas fa-user-friends stat-icon text-success"></i>
                <div class="stat-number">${notificationStats.guestRequestsCount}</div>
                <div class="stat-label">Guest Requests</div>
            </div>
        </div>
    </div>

    <!-- Quick Filters -->
    <div class="table-container mb-4">
        <div class="row">
            <div class="col-md-3">
                <div class="form-group">
                    <label>Filter by Type</label>
                    <select class="form-control" id="typeFilter" onchange="filterNotifications()">
                        <option value="">All Types</option>
                        <option value="GUEST_REQUEST" ${param.type == 'GUEST_REQUEST' ? 'selected' : ''}>Guest Request</option>
                        <option value="SYSTEM_ALERT" ${param.type == 'SYSTEM_ALERT' ? 'selected' : ''}>System Alert</option>
                        <option value="MAINTENANCE" ${param.type == 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
                        <option value="BOOKING" ${param.type == 'BOOKING' ? 'selected' : ''}>Booking</option>
                        <option value="PAYMENT" ${param.type == 'PAYMENT' ? 'selected' : ''}>Payment</option>
                        <option value="STAFF" ${param.type == 'STAFF' ? 'selected' : ''}>Staff</option>
                    </select>
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label>Priority</label>
                    <select class="form-control" id="priorityFilter" onchange="filterNotifications()">
                        <option value="">All Priorities</option>
                        <option value="HIGH" ${param.priority == 'HIGH' ? 'selected' : ''}>High</option>
                        <option value="MEDIUM" ${param.priority == 'MEDIUM' ? 'selected' : ''}>Medium</option>
                        <option value="LOW" ${param.priority == 'LOW' ? 'selected' : ''}>Low</option>
                    </select>
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label>Status</label>
                    <select class="form-control" id="statusFilter" onchange="filterNotifications()">
                        <option value="">All Status</option>
                        <option value="UNREAD" ${param.status == 'UNREAD' ? 'selected' : ''}>Unread</option>
                        <option value="READ" ${param.status == 'READ' ? 'selected' : ''}>Read</option>
                        <option value="RESOLVED" ${param.status == 'RESOLVED' ? 'selected' : ''}>Resolved</option>
                    </select>
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <label>Date Range</label>
                    <select class="form-control" id="dateFilter" onchange="filterNotifications()">
                        <option value="">All Time</option>
                        <option value="today" ${param.dateRange == 'today' ? 'selected' : ''}>Today</option>
                        <option value="yesterday" ${param.dateRange == 'yesterday' ? 'selected' : ''}>Yesterday</option>
                        <option value="week" ${param.dateRange == 'week' ? 'selected' : ''}>This Week</option>
                        <option value="month" ${param.dateRange == 'month' ? 'selected' : ''}>This Month</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <!-- Notifications List -->
    <div class="row">
        <div class="col-md-8">
            <div class="table-container">
                <h5 class="mb-3">
                    Notifications
                    <small class="text-muted ml-2">
                        (${not empty notifications ? notifications.size() : 0} items)
                    </small>
                </h5>

                <div id="notificationsList">
                    <c:choose>
                        <c:when test="${not empty notifications}">
                            <c:forEach var="notification" items="${notifications}">
                                <div class="notification-item ${notification.isRead ? '' : 'unread'} ${notification.priority == 'HIGH' ? 'urgent' : ''}"
                                     data-id="${notification.id}" onclick="viewNotification(${notification.id})">
                                    <div class="d-flex align-items-start">
                                        <div class="notification-icon priority-${notification.priority.toLowerCase()}">
                                            <c:choose>
                                                <c:when test="${notification.type eq 'GUEST_REQUEST'}">
                                                    <i class="fas fa-user-cog"></i>
                                                </c:when>
                                                <c:when test="${notification.type eq 'SYSTEM_ALERT'}">
                                                    <i class="fas fa-exclamation-triangle"></i>
                                                </c:when>
                                                <c:when test="${notification.type eq 'MAINTENANCE'}">
                                                    <i class="fas fa-tools"></i>
                                                </c:when>
                                                <c:when test="${notification.type eq 'BOOKING'}">
                                                    <i class="fas fa-calendar-check"></i>
                                                </c:when>
                                                <c:when test="${notification.type eq 'PAYMENT'}">
                                                    <i class="fas fa-credit-card"></i>
                                                </c:when>
                                                <c:when test="${notification.type eq 'STAFF'}">
                                                    <i class="fas fa-users"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fas fa-bell"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        
                                        <div class="notification-content">
                                            <div class="d-flex justify-content-between align-items-start">
                                                <div>
                                                    <h6 class="mb-1">
                                                        ${notification.title}
                                                        <c:if test="${!notification.isRead}">
                                                            <span class="badge badge-primary badge-sm">New</span>
                                                        </c:if>
                                                    </h6>
                                                    <p class="mb-2 text-muted">${notification.message}</p>
                                                    <div class="notification-time">
                                                        <i class="fas fa-clock mr-1"></i>
                                                        <fmt:formatDate value="${notification.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                        <c:if test="${not empty notification.roomNumber}">
                                                            | <i class="fas fa-door-open mr-1"></i>Room ${notification.roomNumber}
                                                        </c:if>
                                                        <c:if test="${not empty notification.guestName}">
                                                            | <i class="fas fa-user mr-1"></i>${notification.guestName}
                                                        </c:if>
                                                    </div>
                                                </div>
                                                
                                                <div class="notification-actions">
                                                    <c:if test="${!notification.isRead}">
                                                        <button class="btn btn-sm btn-outline-primary" 
                                                                onclick="markAsRead(${notification.id}, event)" title="Mark as read">
                                                            <i class="fas fa-check"></i>
                                                        </button>
                                                    </c:if>
                                                    <c:if test="${notification.type eq 'GUEST_REQUEST' && notification.status ne 'RESOLVED'}">
                                                        <button class="btn btn-sm btn-outline-success" 
                                                                onclick="resolveNotification(${notification.id}, event)" title="Resolve">
                                                            <i class="fas fa-check-circle"></i>
                                                        </button>
                                                    </c:if>
                                                    <button class="btn btn-sm btn-outline-danger" 
                                                            onclick="deleteNotification(${notification.id}, event)" title="Delete">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5">
                                <i class="fas fa-bell-slash fa-3x text-muted mb-3"></i>
                                <p class="text-muted">No notifications found</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Quick Actions Sidebar -->
        <div class="col-md-4">
            <div class="table-container">
                <h6 class="mb-3">Quick Actions</h6>
                
                <div class="mb-3">
                    <button class="btn btn-outline-primary btn-block" data-toggle="modal" data-target="#newNotificationModal">
                        <i class="fas fa-plus"></i> Create Notification
                    </button>
                </div>
                
                <div class="mb-3">
                    <button class="btn btn-outline-success btn-block" onclick="markAllAsRead()">
                        <i class="fas fa-check-double"></i> Mark All as Read
                    </button>
                </div>
                
                <div class="mb-3">
                    <button class="btn btn-outline-info btn-block" onclick="showSystemStatus()">
                        <i class="fas fa-server"></i> System Status
                    </button>
                </div>

                <hr>

                <h6 class="mb-3">Notification Templates</h6>
                <div class="list-group list-group-flush">
                    <button class="list-group-item list-group-item-action" onclick="createTemplateNotification('maintenance')">
                        <i class="fas fa-tools text-warning mr-2"></i> Maintenance Alert
                    </button>
                    <button class="list-group-item list-group-item-action" onclick="createTemplateNotification('cleaning')">
                        <i class="fas fa-broom text-info mr-2"></i> Room Cleaning Request
                    </button>
                    <button class="list-group-item list-group-item-action" onclick="createTemplateNotification('vip_arrival')">
                        <i class="fas fa-star text-warning mr-2"></i> VIP Arrival Alert
                    </button>
                    <button class="list-group-item list-group-item-action" onclick="createTemplateNotification('late_checkout')">
                        <i class="fas fa-clock text-danger mr-2"></i> Late Checkout
                    </button>
                </div>
            </div>

            <!-- Recent Activity -->
            <div class="table-container mt-4">
                <h6 class="mb-3">Recent Activity</h6>
                <div style="max-height: 300px; overflow-y: auto;">
                    <c:forEach var="activity" items="${recentActivity}" begin="0" end="9">
                        <div class="border-bottom pb-2 mb-2">
                            <small class="d-block text-muted">
                                <i class="fas fa-clock mr-1"></i>
                                <fmt:formatDate value="${activity.timestamp}" pattern="HH:mm"/>
                            </small>
                            <small class="d-block">${activity.description}</small>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- New Notification Modal -->
<div class="modal fade" id="newNotificationModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Create New Notification</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form id="newNotificationForm">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Notification Type <span class="text-danger">*</span></label>
                        <select class="form-control" id="notificationType" required>
                            <option value="">Select type</option>
                            <option value="GUEST_REQUEST">Guest Request</option>
                            <option value="SYSTEM_ALERT">System Alert</option>
                            <option value="MAINTENANCE">Maintenance</option>
                            <option value="BOOKING">Booking</option>
                            <option value="PAYMENT">Payment</option>
                            <option value="STAFF">Staff</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Priority <span class="text-danger">*</span></label>
                        <select class="form-control" id="notificationPriority" required>
                            <option value="">Select priority</option>
                            <option value="HIGH">High - Urgent Action Required</option>
                            <option value="MEDIUM">Medium - Attention Needed</option>
                            <option value="LOW">Low - Informational</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Title <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="notificationTitle" 
                               placeholder="Enter notification title" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Message <span class="text-danger">*</span></label>
                        <textarea class="form-control" id="notificationMessage" rows="4" 
                                  placeholder="Enter detailed message..." required></textarea>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Room Number</label>
                                <input type="text" class="form-control" id="notificationRoom" 
                                       placeholder="Optional room number">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Guest Name</label>
                                <input type="text" class="form-control" id="notificationGuest" 
                                       placeholder="Optional guest name">
                            </div>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Notify Staff</label>
                        <select class="form-control" id="notifyStaff" multiple>
                            <option value="ALL">All Reception Staff</option>
                            <option value="MANAGER">Manager Only</option>
                            <option value="HOUSEKEEPING">Housekeeping</option>
                            <option value="MAINTENANCE">Maintenance</option>
                        </select>
                        <small class="form-text text-muted">Hold Ctrl to select multiple options</small>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-bell"></i> Create Notification
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- View Notification Modal -->
<div class="modal fade" id="viewNotificationModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Notification Details</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body" id="notificationDetails">
                <!-- Details will be loaded here -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-success" id="resolveBtn" onclick="resolveCurrentNotification()">
                    <i class="fas fa-check-circle"></i> Resolve
                </button>
            </div>
        </div>
    </div>
</div>

<script>
let currentNotificationId = null;

$(document).ready(function() {
    $('#newNotificationForm').submit(function(e) {
        e.preventDefault();
        createNotification();
    });
    
    // Auto-refresh notifications every 30 seconds
    setInterval(function() {
        refreshNotificationCount();
    }, 30000);
});

function createNotification() {
    const notificationData = {
        type: $('#notificationType').val(),
        priority: $('#notificationPriority').val(),
        title: $('#notificationTitle').val(),
        message: $('#notificationMessage').val(),
        roomNumber: $('#notificationRoom').val(),
        guestName: $('#notificationGuest').val(),
        notifyStaff: $('#notifyStaff').val()
    };
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/notifications',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({
            action: 'createNotification',
            ...notificationData
        }),
        success: function(response) {
            if (response.success) {
                alert('Notification created successfully!');
                $('#newNotificationModal').modal('hide');
                $('#newNotificationForm')[0].reset();
                location.reload();
            } else {
                alert('Error creating notification: ' + (response.message || 'Unknown error'));
            }
        },
        error: function() {
            alert('Error creating notification. Please try again.');
        }
    });
}

function viewNotification(notificationId) {
    currentNotificationId = notificationId;
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/notifications',
        type: 'POST',
        data: {
            action: 'getNotificationDetails',
            id: notificationId
        },
        success: function(notification) {
            // Determine badge classes
            let priorityBadgeClass = 'success';
            if (notification.priority === 'HIGH') {
                priorityBadgeClass = 'danger';
            } else if (notification.priority === 'MEDIUM') {
                priorityBadgeClass = 'warning';
            }
            
            let statusBadgeClass = notification.status === 'RESOLVED' ? 'success' : 'warning';
            
            // Build room and guest rows
            let roomRow = notification.roomNumber ? 
                '<tr><th>Room:</th><td>' + notification.roomNumber + '</td></tr>' : '';
            let guestRow = notification.guestName ? 
                '<tr><th>Guest:</th><td>' + notification.guestName + '</td></tr>' : '';
            
            // Build action buttons
            let markAsReadBtn = !notification.isRead ? 
                '<button class="btn btn-outline-primary btn-sm mb-2" onclick="markAsRead(' + notification.id + ')"><i class="fas fa-check"></i> Mark as Read</button>' : '';
            let resolveBtn = notification.status !== 'RESOLVED' ? 
                '<button class="btn btn-outline-success btn-sm mb-2" onclick="resolveNotification(' + notification.id + ')"><i class="fas fa-check-circle"></i> Resolve</button>' : '';
            
            let html = '<div class="row">' +
                '<div class="col-md-8">' +
                    '<h6>' + notification.title + '</h6>' +
                    '<p class="lead">' + notification.message + '</p>' +
                    '<div class="row mt-3">' +
                        '<div class="col-md-6">' +
                            '<table class="table table-sm">' +
                                '<tr><th>Type:</th><td><span class="badge badge-info">' + notification.type + '</span></td></tr>' +
                                '<tr><th>Priority:</th><td><span class="badge badge-' + priorityBadgeClass + '">' + notification.priority + '</span></td></tr>' +
                                '<tr><th>Status:</th><td><span class="badge badge-' + statusBadgeClass + '">' + notification.status + '</span></td></tr>' +
                            '</table>' +
                        '</div>' +
                        '<div class="col-md-6">' +
                            '<table class="table table-sm">' +
                                '<tr><th>Created:</th><td>' + formatDateTime(notification.createdAt) + '</td></tr>' +
                                '<tr><th>Created By:</th><td>' + notification.createdBy + '</td></tr>' +
                                roomRow +
                                guestRow +
                            '</table>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
                '<div class="col-md-4">' +
                    '<h6>Actions</h6>' +
                    '<div class="btn-group-vertical w-100">' +
                        markAsReadBtn +
                        resolveBtn +
                        '<button class="btn btn-outline-info btn-sm mb-2" onclick="duplicateNotification(' + notification.id + ')"><i class="fas fa-copy"></i> Duplicate</button>' +
                    '</div>' +
                '</div>' +
            '</div>';
            
            $('#notificationDetails').html(html);
            
            // Show/hide resolve button
            if (notification.status === 'RESOLVED') {
                $('#resolveBtn').hide();
            } else {
                $('#resolveBtn').show();
            }
            
            $('#viewNotificationModal').modal('show');
            
            // Mark as read if not already read
            if (!notification.isRead) {
                markAsRead(notificationId);
            }
        },
        error: function() {
            alert('Error loading notification details');
        }
    });
}

function markAsRead(notificationId, event) {
    if (event) {
        event.stopPropagation();
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/notifications',
        type: 'POST',
        data: {
            action: 'markAsRead',
            id: notificationId
        },
        success: function(response) {
            if (response.success) {
                // Update UI
                const notificationElement = $('[data-id="' + notificationId + '"]');
                notificationElement.removeClass('unread');
                notificationElement.find('.badge:contains("New")').remove();
                
                // Update counter
                refreshNotificationCount();
            }
        },
        error: function() {
            alert('Error updating notification status');
        }
    });
}

function resolveNotification(notificationId, event) {
    if (event) {
        event.stopPropagation();
    }
    
    if (confirm('Mark this notification as resolved?')) {
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/notifications',
            type: 'POST',
            data: {
                action: 'resolveNotification',
                id: notificationId
            },
            success: function(response) {
                if (response.success) {
                    alert('Notification resolved successfully!');
                    location.reload();
                } else {
                    alert('Error resolving notification');
                }
            },
            error: function() {
                alert('Error resolving notification');
            }
        });
    }
}

function resolveCurrentNotification() {
    if (currentNotificationId) {
        resolveNotification(currentNotificationId);
    }
}

function deleteNotification(notificationId, event) {
    if (event) {
        event.stopPropagation();
    }
    
    if (confirm('Are you sure you want to delete this notification?')) {
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/notifications',
            type: 'POST',
            data: {
                action: 'deleteNotification',
                id: notificationId
            },
            success: function(response) {
                if (response.success) {
                    $('[data-id="' + notificationId + '"]').fadeOut(300, function() {
                        $(this).remove();
                    });
                    refreshNotificationCount();
                } else {
                    alert('Error deleting notification');
                }
            },
            error: function() {
                alert('Error deleting notification');
            }
        });
    }
}

function markAllAsRead() {
    if (confirm('Mark all notifications as read?')) {
        $.ajax({
            url: '${pageContext.request.contextPath}/receptionist/notifications',
            type: 'POST',
            data: {
                action: 'markAllAsRead'
            },
            success: function(response) {
                if (response.success) {
                    alert('All notifications marked as read!');
                    location.reload();
                } else {
                    alert('Error updating notifications');
                }
            },
            error: function() {
                alert('Error updating notifications');
            }
        });
    }
}

function filterNotifications() {
    const params = new URLSearchParams();
    
    const type = $('#typeFilter').val();
    const priority = $('#priorityFilter').val();
    const status = $('#statusFilter').val();
    const dateRange = $('#dateFilter').val();
    
    if (type) params.append('type', type);
    if (priority) params.append('priority', priority);
    if (status) params.append('status', status);
    if (dateRange) params.append('dateRange', dateRange);
    
    const url = '${pageContext.request.contextPath}/receptionist/notifications' + 
                (params.toString() ? '?' + params.toString() : '');
    window.location.href = url;
}

function createTemplateNotification(template) {
    let templateData = {};
    
    switch(template) {
        case 'maintenance':
            templateData = {
                type: 'MAINTENANCE',
                priority: 'MEDIUM',
                title: 'Maintenance Required',
                message: 'Maintenance request for room equipment or facilities.'
            };
            break;
        case 'cleaning':
            templateData = {
                type: 'GUEST_REQUEST',
                priority: 'LOW',
                title: 'Room Cleaning Request',
                message: 'Guest has requested additional room cleaning service.'
            };
            break;
        case 'vip_arrival':
            templateData = {
                type: 'BOOKING',
                priority: 'HIGH',
                title: 'VIP Guest Arrival',
                message: 'VIP guest arriving - ensure special arrangements are in place.'
            };
            break;
        case 'late_checkout':
            templateData = {
                type: 'BOOKING',
                priority: 'MEDIUM',
                title: 'Late Checkout Alert',
                message: 'Guest has requested late checkout - confirm availability.'
            };
            break;
    }
    
    // Pre-fill the form
    $('#notificationType').val(templateData.type);
    $('#notificationPriority').val(templateData.priority);
    $('#notificationTitle').val(templateData.title);
    $('#notificationMessage').val(templateData.message);
    
    $('#newNotificationModal').modal('show');
}

function showSystemStatus() {
    alert('System Status Dashboard - Coming Soon!');
}

function refreshNotifications() {
    location.reload();
}

function refreshNotificationCount() {
    $.ajax({
        url: '${pageContext.request.contextPath}/receptionist/notifications',
        type: 'POST',
        data: {
            action: 'getUnreadCount'
        },
        success: function(count) {
            // Update notification count in header if exists
            $('.notification-count').text(count);
        }
    });
}

function duplicateNotification(notificationId) {
    // Implementation for duplicating notification
    alert('Duplicate notification feature - Coming Soon!');
}

function formatDateTime(dateTime) {
    if (!dateTime) return '-';
    const date = new Date(dateTime);
    return date.toLocaleString('vi-VN');
}
</script>