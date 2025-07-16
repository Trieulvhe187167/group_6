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
    
                  <!-- Revenue Chart -->
    <div class="row mt-4">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Revenue This Year</h5>
                </div>
                <div class="card-body">
                    <canvas id="revenueChart" style="max-height:300px;"></canvas>
                </div>
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
                      <canvas id="roomStatusChart" style="max-height:300px;"></canvas>
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
                            <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
const revCtx = document.getElementById('revenueChart');
if (revCtx) {
    new Chart(revCtx, {
        type: 'line',
        data: {
            labels: ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
            datasets: [{
                label: 'Revenue',
                data: [<c:forEach var="val" items="${stats.monthlyRevenueSeries}" varStatus="loop">${val}<c:if test="${!loop.last}">,</c:if></c:forEach>],
                borderColor: '#5a2b81',
                backgroundColor: 'rgba(90,43,129,0.1)',
                fill: true,
                tension: 0.3
            }]
        },
        options: {responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}}}
    });
}
const roomCtx = document.getElementById('roomStatusChart');
if (roomCtx) {
    new Chart(roomCtx, {
        type: 'doughnut',
        data: {
            labels: ['Available','Occupied','Maintenance'],
            datasets: [{
                data: [${stats.availableRooms}, ${stats.occupiedRooms}, ${stats.maintenanceRooms}],
                backgroundColor: ['#28a745','#dc3545','#ffc107']
            }]
        },
        options: {responsive:true,maintainAspectRatio:false}
    });
}
</script>