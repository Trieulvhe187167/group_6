<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- Dashboard Content -->
<div class="container-fluid">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <h2>Welcome back, ${currentUser.fullName}!</h2>
            <p class="text-muted">Here's what's happening at the hotel today - <fmt:formatDate value="<%= new java.util.Date() %>" pattern="EEEE, dd MMMM yyyy"/></p>
        </div>
    </div>
    
    <!-- Stats Cards -->
    <div class="row">
        <div class="col-lg-3 col-md-6">
            <div class="stat-card">
                <div class="stat-icon text-info">
                    <i class="fas fa-sign-in-alt"></i>
                </div>
                <div class="stat-number">${stats.todayCheckIns}</div>
                <div class="stat-label">Today's Check-Ins</div>
            </div>
        </div>
        
        <div class="col-lg-3 col-md-6">
            <div class="stat-card">
                <div class="stat-icon text-danger">
                    <i class="fas fa-sign-out-alt"></i>
                </div>
                <div class="stat-number">${stats.todayCheckOuts}</div>
                <div class="stat-label">Today's Check-Outs</div>
            </div>
        </div>
        
        <div class="col-lg-3 col-md-6">
            <div class="stat-card">
                <div class="stat-icon text-warning">
                    <i class="fas fa-hourglass-half"></i>
                </div>
                <div class="stat-number">${stats.pendingReservations}</div>
                <div class="stat-label">Pending Reservations</div>
            </div>
        </div>
        
        <div class="col-lg-3 col-md-6">
            <div class="revenue-card">
                <h4>Expected Revenue Today</h4>
                <div class="revenue-amount">
                    <fmt:formatNumber value="${stats.todayExpectedRevenue}" pattern="#,##0"/>₫
                </div>
            </div>
        </div>
    </div>
    
    <!-- Quick Actions -->
    <div class="row mt-4">
        <div class="col-12">
            <h4 class="mb-3">Quick Actions</h4>
        </div>
        <div class="col-lg-3 col-md-6">
            <a href="${pageContext.request.contextPath}/receptionist/booking" class="quick-action-card">
                <div class="quick-action-icon text-primary">
                    <i class="fas fa-plus-circle"></i>
                </div>
                <h5>New Booking</h5>
                <p class="text-muted">Create new reservation</p>
            </a>
        </div>
        <div class="col-lg-3 col-md-6">
            <a href="${pageContext.request.contextPath}/receptionist/check-in" class="quick-action-card">
                <div class="quick-action-icon text-success">
                    <i class="fas fa-sign-in-alt"></i>
                </div>
                <h5>Quick Check-In</h5>
                <p class="text-muted">Process guest arrival</p>
            </a>
        </div>
        <div class="col-lg-3 col-md-6">
            <a href="${pageContext.request.contextPath}/receptionist/check-out" class="quick-action-card">
                <div class="quick-action-icon text-danger">
                    <i class="fas fa-sign-out-alt"></i>
                </div>
                <h5>Quick Check-Out</h5>
                <p class="text-muted">Process guest departure</p>
            </a>
        </div>
        <div class="col-lg-3 col-md-6">
            <a href="${pageContext.request.contextPath}/receptionist/room-status" class="quick-action-card">
                <div class="quick-action-icon text-info">
                    <i class="fas fa-th"></i>
                </div>
                <h5>Room Status</h5>
                <p class="text-muted">View all room states</p>
            </a>
        </div>
    </div>
    
    <!-- Room Status Overview -->
    <div class="row mt-4">
        <div class="col-lg-8">
            <div class="table-container">
                <h4 class="mb-3">Room Status Overview</h4>
                <div class="row">
                    <div class="col-md-3">
                        <div class="stat-card bg-light">
                            <i class="fas fa-check-circle text-success stat-icon"></i>
                            <h5>${stats.availableRooms}</h5>
                            <small>Available</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card bg-light">
                            <i class="fas fa-user-check text-danger stat-icon"></i>
                            <h5>${stats.occupiedRooms}</h5>
                            <small>Occupied</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card bg-light">
                            <i class="fas fa-broom text-warning stat-icon"></i>
                            <h5>${stats.dirtyRooms}</h5>
                            <small>Cleaning</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card bg-light">
                            <i class="fas fa-tools text-info stat-icon"></i>
                            <h5>${stats.maintenanceRooms}</h5>
                            <small>Maintenance</small>
                        </div>
                    </div>
                </div>
                <div class="progress mt-3" style="height: 25px;">
                    <div class="progress-bar bg-success" style="width: ${(stats.availableRooms * 100.0 / stats.totalRooms)}%">
                        ${stats.availableRooms}
                    </div>
                    <div class="progress-bar bg-danger" style="width: ${(stats.occupiedRooms * 100.0 / stats.totalRooms)}%">
                        ${stats.occupiedRooms}
                    </div>
                    <div class="progress-bar bg-warning" style="width: ${(stats.dirtyRooms * 100.0 / stats.totalRooms)}%">
                        ${stats.dirtyRooms}
                    </div>
                    <div class="progress-bar bg-info" style="width: ${(stats.maintenanceRooms * 100.0 / stats.totalRooms)}%">
                        ${stats.maintenanceRooms}
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-lg-4">
            <div class="table-container">
                <h4 class="mb-3">Recent Activities</h4>
                <div style="max-height: 300px; overflow-y: auto;">
                    <c:choose>
                        <c:when test="${not empty stats.recentActivities}">
                            <c:forEach var="activity" items="${stats.recentActivities}">
                                <div class="border-bottom pb-2 mb-2">
                                    <div class="d-flex align-items-start">
                                        <i class="fas ${activity.typeIcon} mr-3 mt-1"></i>
                                        <div class="flex-grow-1">
                                            <p class="mb-1">${activity.description}</p>
                                            <small class="text-muted">
                                                by ${activity.userName} • 
                                                <fmt:formatDate value="${activity.timestamp}" pattern="HH:mm dd/MM"/>
                                            </small>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p class="text-center text-muted">No recent activities</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Upcoming Check-ins and Check-outs -->
    <div class="row mt-4">
        <div class="col-lg-6">
            <div class="table-container">
                <h4 class="mb-3">
                    <i class="fas fa-sign-in-alt text-info"></i> 
                    Upcoming Check-Ins
                </h4>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Guest Name</th>
                                <th>Room</th>
                                <th>Time</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty stats.upcomingCheckIns}">
                                    <c:forEach var="checkIn" items="${stats.upcomingCheckIns}">
                                        <tr>
                                            <td>${checkIn.customerName}</td>
                                            <td>
                                                <span class="badge badge-info">Room ${checkIn.roomNumber}</span>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${checkIn.checkIn}" pattern="HH:mm"/>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/receptionist/check-in?id=${checkIn.id}" 
                                                   class="btn btn-sm btn-primary">
                                                    Check In
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4" class="text-center text-muted">
                                            No upcoming check-ins today
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <div class="col-lg-6">
            <div class="table-container">
                <h4 class="mb-3">
                    <i class="fas fa-sign-out-alt text-danger"></i> 
                    Upcoming Check-Outs
                </h4>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Guest Name</th>
                                <th>Room</th>
                                <th>Amount</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty stats.upcomingCheckOuts}">
                                    <c:forEach var="checkOut" items="${stats.upcomingCheckOuts}">
                                        <tr>
                                            <td>${checkOut.customerName}</td>
                                            <td>
                                                <span class="badge badge-danger">Room ${checkOut.roomNumber}</span>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${checkOut.totalAmount}" pattern="#,##0"/>₫
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/receptionist/check-out?id=${checkOut.id}" 
                                                   class="btn btn-sm btn-danger">
                                                    Check Out
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4" class="text-center text-muted">
                                            No upcoming check-outs today
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Auto-refresh dashboard every 5 minutes
    setTimeout(function() {
        location.reload();
    }, 300000);
</script>