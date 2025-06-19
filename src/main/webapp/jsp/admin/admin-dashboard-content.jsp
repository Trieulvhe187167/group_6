<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="admin-dashboard">Home Dashboard</a></li>
            
        </ol>
    </nav>
 
    <!-- Stats Cards -->
    <div class="row">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-warning">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-number">${stats.totalCustomers}</div>
                <div class="stat-label">Total Customers</div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-success">
                    <i class="fas fa-bed"></i>
                </div>
                <div class="stat-number">${stats.availableRooms}</div>
                <div class="stat-label">Available Rooms</div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-danger">
                    <i class="fas fa-door-closed"></i>
                </div>
                <div class="stat-number">${stats.occupiedRooms}</div>
                <div class="stat-label">Occupied Rooms</div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-icon text-info">
                    <i class="fas fa-sign-in-alt"></i>
                </div>
                <div class="stat-number">${stats.todayCheckIns}</div>
                <div class="stat-label">Today Check-ins</div>
            </div>
        </div>
    </div>
    
    <!-- Revenue Cards -->
    <div class="row mt-4">
        <div class="col-md-6">
            <div class="revenue-card">
                <h4>Monthly Revenue</h4>
                <div class="revenue-amount">
                    <fmt:formatNumber value="${stats.monthlyRevenue}" pattern="#,##0" />₫
                </div>
                <div class="stat-label">Current Month</div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="revenue-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                <h4>Yearly Revenue</h4>
                <div class="revenue-amount">
                    <fmt:formatNumber value="${stats.yearlyRevenue}" pattern="#,##0" />₫
                </div>
                <div class="stat-label">Current Year</div>
            </div>
        </div>
    </div>
    
    <!-- Room Status & Recent Reservations -->
    <div class="row mt-4">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Room Status Overview</h5>
                </div>
                <div class="card-body">
                    <div class="row text-center">
                        <div class="col-3">
                            <h6>${stats.availableRooms}</h6>
                            <small class="text-success">Available</small>
                        </div>
                        <div class="col-3">
                            <h6>${stats.occupiedRooms}</h6>
                            <small class="text-danger">Occupied</small>
                        </div>
                        <div class="col-3">
                            <h6>${stats.maintenanceRooms}</h6>
                            <small class="text-warning">Maintenance</small>
                        </div>
                        <div class="col-3">
                            <h6>${stats.totalRooms}</h6>
                            <small class="text-info">Total</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Recent Reservations</h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty stats.recentReservations}">
                            <c:forEach var="res" items="${stats.recentReservations}">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <div>
                                        <strong>Booking #${res.id}</strong><br>
                                        <small>${res.customerName} - Room ${res.roomNumber}</small>
                                    </div>
                                    <span class="badge badge-${res.status == 'CONFIRMED' ? 'success' : 'warning'}">
                                        ${res.status}
                                    </span>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p class="text-center text-muted">No recent reservations</p>
                        </c:otherwise>
                    </c:choose>
                    <div class="text-center mt-3">
                        <a href="${pageContext.request.contextPath}/admin/bookings" class="btn btn-warning">
                            View All Reservations
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>