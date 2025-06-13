<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="container-fluid">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/rooms">Room Types</a></li>
            <li class="breadcrumb-item active">Room Type Details</li>
        </ol>
    </nav>
    
    <!-- Page Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">Room Type Details</h1>
        <div>
            <a href="${pageContext.request.contextPath}/admin/rooms?action=form&id=${roomType.id}" 
               class="btn btn-warning">
                <i class="fas fa-edit"></i> Edit
            </a>
            <a href="${pageContext.request.contextPath}/admin/rooms" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Back to List
            </a>
        </div>
    </div>
    
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
    
    <div class="row">
        <!-- Room Type Information -->
        <div class="col-md-8">
            <!-- Basic Information Card -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-info-circle"></i> Basic Information
                    </h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4">
                            <div class="room-image-container" style="position: relative;">
                                <img src="${pageContext.request.contextPath}/assets/images/uploads/${roomType.imageUrl}" 
                                     class="img-fluid rounded shadow" 
                                     alt="Room Type Image"
                                     style="width: 100%; height: 200px; object-fit: cover;">
                                <div class="status-badge" style="position: absolute; top: 10px; right: 10px;">
                                    <span class="badge badge-${roomType.status == 'active' ? 'success' : 'danger'} badge-lg">
                                        ${roomType.status == 'active' ? 'Active' : 'Inactive'}
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-8">
                            <table class="table table-borderless">
                                <tr>
                                    <th width="30%">Room Type ID:</th>
                                    <td>#${roomType.id}</td>
                                </tr>
                                <tr>
                                    <th>Name:</th>
                                    <td><h5 class="mb-0">${roomType.name}</h5></td>
                                </tr>
                                <tr>
                                    <th>Base Price:</th>
                                    <td>
                                        <h4 class="text-primary mb-0">
                                            <fmt:formatNumber value="${roomType.basePrice}" pattern="#,##0" />₫
                                            <small class="text-muted">/night</small>
                                        </h4>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Capacity:</th>
                                    <td>
                                        <span class="badge badge-info badge-lg">
                                            <i class="fas fa-users"></i> ${roomType.capacity} guests
                                        </span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Status:</th>
                                    <td>
                                        <span class="badge badge-${roomType.status == 'active' ? 'success' : 'danger'} badge-lg">
                                            <i class="fas fa-${roomType.status == 'active' ? 'check-circle' : 'times-circle'}"></i>
                                            ${roomType.status == 'active' ? 'Active' : 'Inactive'}
                                        </span>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Created Date:</th>
                                    <td>
                                        <fmt:formatDate value="${roomType.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Last Updated:</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${roomType.updatedAt != null}">
                                                <fmt:formatDate value="${roomType.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Never updated</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Description and Features Card -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-align-left"></i> Description & Features
                    </h5>
                </div>
                <div class="card-body">
                    <c:set var="descriptionParts" value="${fn:split(roomType.description, ',')}" />
                    
                    <div class="row">
                        <div class="col-md-6">
                            <h6><i class="fas fa-info-circle text-primary"></i> Description</h6>
                            <c:choose>
                                <c:when test="${fn:length(descriptionParts) > 0}">
                                    <p class="text-justify">${fn:trim(descriptionParts[0])}</p>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted">No description available</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="col-md-6">
                            <h6><i class="fas fa-bed text-primary"></i> Bed Type</h6>
                            <c:choose>
                                <c:when test="${fn:length(descriptionParts) > 1}">
                                    <p><span class="badge badge-secondary">${fn:trim(descriptionParts[1])}</span></p>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted">Not specified</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <c:if test="${fn:length(descriptionParts) > 2}">
                        <hr>
                        <h6><i class="fas fa-star text-primary"></i> Special Features</h6>
                        <div class="row">
                            <c:forEach var="feature" items="${descriptionParts}" varStatus="status">
                                <c:if test="${status.index >= 2}">
                                    <div class="col-md-6 mb-2">
                                        <span class="badge badge-outline-primary">
                                            <i class="fas fa-check"></i> ${fn:trim(feature)}
                                        </span>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </div>
                    </c:if>
                    
                    <hr>
                    <h6><i class="fas fa-file-alt text-primary"></i> Full Description</h6>
                    <div class="bg-light p-3 rounded">
                        <p class="mb-0">${roomType.description}</p>
                    </div>
                </div>
            </div>
            
            <!-- Room Statistics Card -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-chart-bar"></i> Statistics & Performance
                    </h5>
                </div>
                <div class="card-body">
                    <div class="row text-center">
                        <div class="col-md-3">
                            <div class="stat-box">
                                <h3 class="text-primary">${totalRooms}</h3>
                                <p class="mb-0">Total Rooms</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-box">
                                <h3 class="text-success">${availableRooms}</h3>
                                <p class="mb-0">Available</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-box">
                                <h3 class="text-danger">${occupiedRooms}</h3>
                                <p class="mb-0">Occupied</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="stat-box">
                                <h3 class="text-warning">${maintenanceRooms + dirtyRooms}</h3>
                                <p class="mb-0">Need Attention</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Rooms List Card -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">
                        <i class="fas fa-door-open"></i> Rooms of This Type
                    </h5>
                    <span class="badge badge-primary">${totalRooms} rooms</span>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty rooms}">
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>Room Number</th>
                                            <th>Status</th>
                                            <th>Current Guest</th>
                                            <th>Last Cleaned</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="room" items="${rooms}">
                                            <tr>
                                                <td>
                                                    <strong>${room.roomNumber}</strong>
                                                </td>
                                                <td>
                                                    <span class="badge ${room.statusBadgeClass}">
                                                        ${room.statusDisplayName}
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${room.status == 'OCCUPIED'}">
                                                            <span class="text-muted">Guest in room</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <span class="text-muted">
                                                        <c:choose>
                                                            <c:when test="${room.status == 'DIRTY'}">
                                                                Needs cleaning
                                                            </c:when>
                                                            <c:when test="${room.status == 'MAINTENANCE'}">
                                                                Under maintenance
                                                            </c:when>
                                                            <c:otherwise>
                                                                Recently cleaned
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td>
                                                    <div class="btn-group" role="group">
                                                        <button class="btn btn-sm btn-outline-primary" 
                                                                onclick="viewRoomDetails(${room.id}, '${room.roomNumber}')"
                                                                title="View Details">
                                                            <i class="fas fa-eye"></i>
                                                        </button>
                                                        <c:if test="${room.status == 'DIRTY'}">
                                                            <button class="btn btn-sm btn-outline-warning" 
                                                                    onclick="scheduleClean(${room.id}, '${room.roomNumber}')"
                                                                    title="Schedule Cleaning">
                                                                <i class="fas fa-broom"></i>
                                                            </button>
                                                        </c:if>
                                                        <c:if test="${room.status == 'AVAILABLE'}">
                                                            <button class="btn btn-sm btn-outline-success" 
                                                                    onclick="markOccupied(${room.id}, '${room.roomNumber}')"
                                                                    title="Mark as Occupied">
                                                                <i class="fas fa-user"></i>
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
                            <div class="text-center py-4">
                                <i class="fas fa-door-open fa-3x text-muted mb-3"></i>
                                <p class="text-muted">No rooms found for this room type</p>
                                <button class="btn btn-primary" onclick="createRoom()">
                                    <i class="fas fa-plus"></i> Add First Room
                                </button>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions Sidebar -->
        <div class="col-md-4">
            <!-- Quick Actions Card -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-bolt"></i> Quick Actions
                    </h5>
                </div>
                <div class="card-body">
                    <a href="${pageContext.request.contextPath}/admin/rooms?action=form&id=${roomType.id}" 
                       class="btn btn-warning btn-block mb-2">
                        <i class="fas fa-edit"></i> Edit Room Type
                    </a>
                    
                    <button onclick="confirmStatusChange(${roomType.id}, '${roomType.status}', '${roomType.name}')" 
                            class="btn btn-${roomType.status == 'active' ? 'danger' : 'success'} btn-block mb-2">
                        <i class="fas fa-${roomType.status == 'active' ? 'ban' : 'check'}"></i> 
                        ${roomType.status == 'active' ? 'Deactivate' : 'Activate'}
                    </button>
                    
                    <a href="${pageContext.request.contextPath}/admin/rooms?action=form" 
                       class="btn btn-success btn-block mb-2">
                        <i class="fas fa-plus"></i> Create New Type
                    </a>
                    
                    <hr>
                    
                    <button class="btn btn-info btn-block mb-2">
                        <i class="fas fa-eye"></i> View All Rooms
                    </button>
                    
                    <button class="btn btn-secondary btn-block">
                        <i class="fas fa-chart-line"></i> View Reports
                    </button>
                </div>
            </div>
            
            <!-- Price Information Card -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-money-bill-wave"></i> Price Information
                    </h5>
                </div>
                <div class="card-body">
                    <div class="price-breakdown">
                        <div class="d-flex justify-content-between mb-2">
                            <span>Base Price:</span>
                            <strong><fmt:formatNumber value="${roomType.basePrice}" pattern="#,##0" />₫</strong>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Weekly Rate (7 nights):</span>
                            <strong><fmt:formatNumber value="${roomType.basePrice * 7 * 0.9}" pattern="#,##0" />₫</strong>
                            <small class="text-success">(10% off)</small>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Monthly Rate (30 nights):</span>
                            <strong><fmt:formatNumber value="${roomType.basePrice * 30 * 0.8}" pattern="#,##0" />₫</strong>
                            <small class="text-success">(20% off)</small>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between">
                            <span>Price per guest:</span>
                            <strong><fmt:formatNumber value="${roomType.basePrice / roomType.capacity}" pattern="#,##0" />₫</strong>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Room Type Info Card -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-info"></i> Additional Information
                    </h5>
                </div>
                <div class="card-body">
                    <div class="info-item mb-3">
                        <h6 class="text-muted mb-1">Created By</h6>
                        <p class="mb-0">System Administrator</p>
                    </div>
                    
                    <div class="info-item mb-3">
                        <h6 class="text-muted mb-1">Category</h6>
                        <p class="mb-0">
                            <c:choose>
                                <c:when test="${roomType.basePrice < 500000}">
                                    <span class="badge badge-success">Economy</span>
                                </c:when>
                                <c:when test="${roomType.basePrice >= 500000 && roomType.basePrice < 1000000}">
                                    <span class="badge badge-warning">Standard</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-danger">Premium</span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    
                    <div class="info-item mb-3">
                        <h6 class="text-muted mb-1">Occupancy Rate</h6>
                        <div class="progress" style="height: 20px;">
                            <div class="progress-bar bg-success" role="progressbar" style="width: 75%">
                                75%
                            </div>
                        </div>
                        <small class="text-muted">Average occupancy this month</small>
                    </div>
                    
                    <div class="info-item">
                        <h6 class="text-muted mb-1">Last Booking</h6>
                        <p class="mb-0">2 days ago</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Status Change Confirmation Modal -->
<div class="modal fade" id="statusModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Status Change</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to <span id="statusAction"></span> room type "<span id="roomTypeName"></span>"?</p>
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i>
                    This action will affect all rooms of this type and may impact current bookings.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <form method="post" action="${pageContext.request.contextPath}/admin/rooms" style="display: inline;">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" id="statusRoomTypeId">
                    <input type="hidden" name="status" id="statusValue">
                    <button type="submit" class="btn btn-primary">Confirm</button>
                </form>
            </div>
        </div>
    </div>
</div>

<style>
.stat-box {
    padding: 20px;
    border-radius: 8px;
    background: #f8f9fa;
    text-align: center;
}

.stat-box h3 {
    margin-bottom: 10px;
    font-weight: 600;
}

.badge-lg {
    font-size: 0.9rem;
    padding: 0.5rem 0.75rem;
}

.badge-outline-primary {
    color: #5a2b81;
    border: 1px solid #5a2b81;
    background: transparent;
}

.price-breakdown {
    font-size: 0.9rem;
}

.info-item h6 {
    font-size: 0.8rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.room-image-container:hover img {
    transform: scale(1.05);
    transition: transform 0.3s ease;
}

.table-responsive {
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.table th {
    background-color: #f8f9fa;
    border-top: none;
    font-weight: 600;
    color: #495057;
    padding: 12px;
}

.table td {
    padding: 12px;
    vertical-align: middle;
}

.table tbody tr:hover {
    background-color: #f8f9fa;
}

.btn-group .btn {
    margin-right: 2px;
}

.btn-group .btn:last-child {
    margin-right: 0;
}

.stat-box:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    transition: all 0.3s ease;
}

.card-header {
    background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
}

.badge {
    font-size: 0.75rem;
    padding: 0.375rem 0.5rem;
}

@media (max-width: 768px) {
    .stat-box {
        margin-bottom: 15px;
    }
    
    .table-responsive {
        font-size: 0.875rem;
    }
    
    .btn-group .btn {
        padding: 0.25rem 0.5rem;
        font-size: 0.75rem;
    }
}
</style>

<script>
function confirmStatusChange(roomTypeId, currentStatus, roomTypeName) {
    var newStatus = currentStatus === 'active' ? 'inactive' : 'active';
    var action = newStatus === 'active' ? 'activate' : 'deactivate';
    
    document.getElementById('statusAction').textContent = action;
    document.getElementById('roomTypeName').textContent = roomTypeName;
    document.getElementById('statusRoomTypeId').value = roomTypeId;
    document.getElementById('statusValue').value = newStatus;
    
    $('#statusModal').modal('show');
}

// Room management functions
function viewRoomDetails(roomId, roomNumber) {
    // Redirect to room details page (if you have one)
    window.location.href = '${pageContext.request.contextPath}/admin/rooms/detail?roomId=' + roomId;
}

function scheduleClean(roomId, roomNumber) {
    if (confirm('Schedule cleaning for room ' + roomNumber + '?')) {
        // Create housekeeping task
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/HouseKeeping';
        
        var actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'create';
        
        var roomIdInput = document.createElement('input');
        roomIdInput.type = 'hidden';
        roomIdInput.name = 'roomId';
        roomIdInput.value = roomId;
        
        var notesInput = document.createElement('input');
        notesInput.type = 'hidden';
        notesInput.name = 'notes';
        notesInput.value = 'Cleaning scheduled from room type management';
        
        var statusInput = document.createElement('input');
        statusInput.type = 'hidden';
        statusInput.name = 'status';
        statusInput.value = 'PENDING';
        
        form.appendChild(actionInput);
        form.appendChild(roomIdInput);
        form.appendChild(notesInput);
        form.appendChild(statusInput);
        document.body.appendChild(form);
        form.submit();
    }
}

function markOccupied(roomId, roomNumber) {
    if (confirm('Mark room ' + roomNumber + ' as occupied?')) {
        // Update room status
        var form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/admin/rooms/updateStatus';
        
        var roomIdInput = document.createElement('input');
        roomIdInput.type = 'hidden';
        roomIdInput.name = 'roomId';
        roomIdInput.value = roomId;
        
        var statusInput = document.createElement('input');
        statusInput.type = 'hidden';
        statusInput.name = 'status';
        statusInput.value = 'OCCUPIED';
        
        form.appendChild(roomIdInput);
        form.appendChild(statusInput);
        document.body.appendChild(form);
        form.submit();
    }
}

function createRoom() {
    // Redirect to room creation page with room type pre-selected
    window.location.href = '${pageContext.request.contextPath}/admin/rooms/create?roomTypeId=${roomType.id}';
}

// Add some interactive effects
$(document).ready(function() {
    // Animate statistics on page load
    $('.stat-box h3').each(function() {
        var $this = $(this);
        var countTo = parseInt($this.text()) || 0;
        
        if (countTo > 0) {
            $({ countNum: 0 }).animate({
                countNum: countTo
            }, {
                duration: 1500,
                easing: 'linear',
                step: function() {
                    $this.text(Math.floor(this.countNum));
                },
                complete: function() {
                    $this.text(this.countNum);
                }
            });
        }
    });
    
    // Tooltip for badges
    $('[data-toggle="tooltip"]').tooltip();
    
    // Auto-refresh room statuses every 30 seconds
    setInterval(function() {
        // You can implement auto-refresh here if needed
    }, 30000);
});
</script>