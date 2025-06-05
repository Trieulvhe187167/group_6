<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <title>Reception Dashboard - Luxury Hotel</title>
    
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        .dashboard-container {
            padding: 30px 0;
            background-color: #f8f9fa;
            min-height: 100vh;
        }
        
        .stat-widget {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }
        
        .stat-widget:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            float: left;
            margin-right: 15px;
        }
        
        .stat-content h3 {
            margin: 0;
            font-size: 24px;
            font-weight: 600;
        }
        
        .stat-content p {
            margin: 0;
            color: #666;
            font-size: 14px;
        }
        
        .action-button {
            display: inline-flex;
            align-items: center;
            padding: 12px 24px;
            background: #EFBB20;
            color: white;
            border-radius: 5px;
            text-decoration: none;
            transition: all 0.3s ease;
            margin: 5px;
            font-weight: 500;
        }
        
        .action-button:hover {
            background: #d4a51b;
            text-decoration: none;
            color: white;
            transform: translateY(-2px);
        }
        
        .action-button i {
            margin-right: 8px;
        }
        
        .room-status-card {
            background: white;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .room-status-card:hover {
            box-shadow: 0 5px 15px rgba(0,0,0,0.15);
        }
        
        .room-number {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .room-type {
            color: #666;
            font-size: 14px;
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            text-transform: uppercase;
        }
        
        .status-available { background: #d4edda; color: #155724; }
        .status-occupied { background: #f8d7da; color: #721c24; }
        .status-dirty { background: #fff3cd; color: #856404; }
        .status-maintenance { background: #d1ecf1; color: #0c5460; }
        
        .activity-list {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .activity-item {
            padding: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .activity-item:last-child {
            border-bottom: none;
        }
        
        .quick-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .welcome-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        
        .section-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #333;
        }
    </style>
</head>
<body id="bg">
    <div class="page-wraper">
        <!-- Header -->
           <!-- Content -->
                <!-- inner page banner -->
                 <div class="page-banner ovbl-dark" style="background-image:url(assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Reception Dashboard </h1>
                        </div>
                    </div>
                </div>
        <!-- Dashboard Content -->
        <div class="dashboard-container">
            <div class="container">
              
                <!-- Welcome Section -->
                <div class="welcome-section">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h1>Welcome, ${sessionScope.user.fullName}!</h1>
                            <p class="mb-0">Reception Dashboard - Manage daily hotel operations</p>
                        </div>
                        <div class="col-md-4 text-right">
                            <p class="mb-0">Current Time: <span id="currentTime"></span></p>
                            <p class="mb-0">Role: <span class="badge badge-light">RECEPTIONIST</span></p>
                        </div>
                    </div>
                </div>
                
                <!-- Quick Actions -->
                <div class="text-center mb-4">
                    <a href="${pageContext.request.contextPath}/reception/new-checkin" class="action-button">
                        <i class="fas fa-sign-in-alt"></i> New Check-in
                    </a>
                    <a href="${pageContext.request.contextPath}/reception/checkout" class="action-button">
                        <i class="fas fa-sign-out-alt"></i> Check-out
                    </a>
                    <a href="${pageContext.request.contextPath}/reception/new-reservation" class="action-button">
                        <i class="fas fa-calendar-plus"></i> New Reservation
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/customers" class="action-button">
                        <i class="fas fa-user-plus"></i> Register Guest
                    </a>
                </div>
                
                <!-- Quick Stats -->
                <div class="quick-stats">
                    <!-- Today Check-ins -->
                    <div class="stat-widget">
                        <div class="stat-icon" style="background: rgba(52,191,163,0.1); color: #34BFA3;">
                            <i class="fas fa-sign-in-alt"></i>
                        </div>
                        <div class="stat-content">
                            <h3>${stats.todayCheckIns}</h3>
                            <p>Today's Check-ins</p>
                        </div>
                        <div style="clear: both;"></div>
                    </div>
                    
                    <!-- Today Check-outs -->
                    <div class="stat-widget">
                        <div class="stat-icon" style="background: rgba(246,78,96,0.1); color: #F64E60;">
                            <i class="fas fa-sign-out-alt"></i>
                        </div>
                        <div class="stat-content">
                            <h3>${stats.todayCheckOuts}</h3>
                            <p>Today's Check-outs</p>
                        </div>
                        <div style="clear: both;"></div>
                    </div>
                    
                    <!-- Available Rooms -->
                    <div class="stat-widget">
                        <div class="stat-icon" style="background: rgba(239,187,32,0.1); color: #EFBB20;">
                            <i class="fas fa-bed"></i>
                        </div>
                        <div class="stat-content">
                            <h3>${stats.availableRooms}</h3>
                            <p>Available Rooms</p>
                        </div>
                        <div style="clear: both;"></div>
                    </div>
                    
                    <!-- Occupied Rooms -->
                    <div class="stat-widget">
                        <div class="stat-icon" style="background: rgba(102,126,234,0.1); color: #667EEA;">
                            <i class="fas fa-door-closed"></i>
                        </div>
                        <div class="stat-content">
                            <h3>${stats.occupiedRooms}</h3>
                            <p>Occupied Rooms</p>
                        </div>
                        <div style="clear: both;"></div>
                    </div>
                </div>
                
                <!-- Main Content Area -->
                <div class="row">
                    <!-- Today's Activities -->
                    <div class="col-lg-6">
                        <h3 class="section-title">Today's Check-ins</h3>
                        <div class="activity-list">
                            <c:choose>
                                <c:when test="${not empty stats.todayCheckInsList}">
                                    <c:forEach var="checkin" items="${stats.todayCheckInsList}">
                                        <div class="activity-item">
                                            <div class="row align-items-center">
                                                <div class="col-md-8">
                                                    <h6 class="mb-1">
                                                        <i class="fas fa-user"></i> ${checkin.guestName}
                                                    </h6>
                                                    <p class="mb-0 text-muted">
                                                        Room: ${checkin.roomNumber} | 
                                                        Check-in: <fmt:formatDate value="${checkin.checkIn}" pattern="HH:mm"/>
                                                    </p>
                                                </div>
                                                <div class="col-md-4 text-right">
                                                    <button class="btn btn-sm btn-success" onclick="processCheckIn(${checkin.id})">
                                                        Process
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted text-center py-3">No check-ins scheduled for today</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <h3 class="section-title mt-4">Today's Check-outs</h3>
                        <div class="activity-list">
                            <c:choose>
                                <c:when test="${not empty stats.todayCheckOutsList}">
                                    <c:forEach var="checkout" items="${stats.todayCheckOutsList}">
                                        <div class="activity-item">
                                            <div class="row align-items-center">
                                                <div class="col-md-8">
                                                    <h6 class="mb-1">
                                                        <i class="fas fa-user"></i> ${checkout.guestName}
                                                    </h6>
                                                    <p class="mb-0 text-muted">
                                                        Room: ${checkout.roomNumber} | 
                                                        Check-out: <fmt:formatDate value="${checkout.checkOut}" pattern="HH:mm"/>
                                                    </p>
                                                </div>
                                                <div class="col-md-4 text-right">
                                                    <button class="btn btn-sm btn-warning" onclick="processCheckOut(${checkout.id})">
                                                        Process
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted text-center py-3">No check-outs scheduled for today</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <!-- Room Status -->
                    <div class="col-lg-6">
                        <h3 class="section-title">Room Status Overview</h3>
                        
                        <!-- Room Summary -->
                        <div class="row mb-3">
                            <div class="col-6">
                                <div class="text-center p-3" style="background: #f8f9fa; border-radius: 10px;">
                                    <h4 class="mb-1">${stats.availableRooms}</h4>
                                    <p class="mb-0 text-success">Available</p>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="text-center p-3" style="background: #f8f9fa; border-radius: 10px;">
                                    <h4 class="mb-1">${stats.occupiedRooms}</h4>
                                    <p class="mb-0 text-danger">Occupied</p>
                                </div>
                            </div>
                        </div>
                        <div class="row mb-4">
                            <div class="col-6">
                                <div class="text-center p-3" style="background: #f8f9fa; border-radius: 10px;">
                                    <h4 class="mb-1">${stats.dirtyRooms}</h4>
                                    <p class="mb-0 text-warning">Need Cleaning</p>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="text-center p-3" style="background: #f8f9fa; border-radius: 10px;">
                                    <h4 class="mb-1">${stats.maintenanceRooms}</h4>
                                    <p class="mb-0 text-info">Maintenance</p>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Available Rooms List -->
                        <h5 class="mb-3">Available Rooms</h5>
                        <div style="max-height: 400px; overflow-y: auto;">
                            <c:choose>
                                <c:when test="${not empty stats.availableRoomsList}">
                                    <c:forEach var="room" items="${stats.availableRoomsList}">
                                        <div class="room-status-card" onclick="quickReserve('${room.roomNumber}')">
                                            <div class="row align-items-center">
                                                <div class="col-8">
                                                    <div class="room-number">Room ${room.roomNumber}</div>
                                                    <div class="room-type">${room.roomTypeName}</div>
                                                </div>
                                                <div class="col-4 text-right">
                                                    <span class="status-badge status-available">Available</span>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <p class="text-muted text-center py-3">No available rooms</p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                
                <!-- Quick Links -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="activity-list">
                            <h3 class="section-title">Quick Links</h3>
                            <div class="row">
                                <div class="col-md-3 text-center mb-3">
                                    <a href="${pageContext.request.contextPath}/reception/reservations" class="text-decoration-none">
                                        <i class="fas fa-calendar-alt fa-3x text-primary mb-2"></i>
                                        <p class="mb-0">View All Reservations</p>
                                    </a>
                                </div>
                                <div class="col-md-3 text-center mb-3">
                                    <a href="${pageContext.request.contextPath}/HouseKeeping" class="text-decoration-none">
                                        <i class="fas fa-broom fa-3x text-warning mb-2"></i>
                                        <p class="mb-0">Housekeeping Status</p>
                                    </a>
                                </div>
                                <div class="col-md-3 text-center mb-3">
                                    <a href="${pageContext.request.contextPath}/admin/customers" class="text-decoration-none">
                                        <i class="fas fa-users fa-3x text-success mb-2"></i>
                                        <p class="mb-0">Current Guests</p>
                                    </a>
                                </div>
                                <div class="col-md-3 text-center mb-3">
                                    <a href="${pageContext.request.contextPath}/reception/reports" class="text-decoration-none">
                                        <i class="fas fa-chart-bar fa-3x text-info mb-2"></i>
                                        <p class="mb-0">Daily Reports</p>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Footer -->
        <jsp:include page="/jsp/footer.jsp" />
    </div>
    
    <!-- JS -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
    
    <script>
        // Update current time
        function updateTime() {
            const now = new Date();
            const options = { 
                year: 'numeric', 
                month: '2-digit', 
                day: '2-digit', 
                hour: '2-digit', 
                minute: '2-digit', 
                second: '2-digit' 
            };
            document.getElementById('currentTime').textContent = now.toLocaleString('vi-VN', options);
        }
        
        updateTime();
        setInterval(updateTime, 1000);
        
        // Process check-in
        function processCheckIn(reservationId) {
            if (confirm('Process check-in for this guest?')) {
                window.location.href = '${pageContext.request.contextPath}/reception/process-checkin?id=' + reservationId;
            }
        }
        
        // Process check-out
        function processCheckOut(reservationId) {
            if (confirm('Process check-out for this guest?')) {
                window.location.href = '${pageContext.request.contextPath}/reception/process-checkout?id=' + reservationId;
            }
        }
        
        // Quick reserve room
        function quickReserve(roomNumber) {
            window.location.href = '${pageContext.request.contextPath}/reception/new-reservation?room=' + roomNumber;
        }
        
        // Auto refresh every 2 minutes for real-time updates
        setTimeout(function() {
            location.reload();
        }, 120000);
    </script>
</body>
</html>