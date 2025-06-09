<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Dashboard - Luxury Hotel</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
        }
        
        /* Header */
        .admin-header {
            background: #5a2b81;
            color: white;
            padding: 15px 20px;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            display: flex;
            align-items: center;
            gap: 10px;
            color: white;
            text-decoration: none;
        }
        
        .logo img {
            height: 40px;
            background: white;
            padding: 5px;
            border-radius: 5px;
        }
        
        .logo-text {
            font-size: 20px;
            font-weight: 600;
        }
        
        /* Sidebar */
        .sidebar {
            position: fixed;
            top: 70px;
            left: 0;
            width: 250px;
            height: calc(100vh - 70px);
            background: white;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
            overflow-y: auto;
            z-index: 999;
        }
        
        .sidebar-nav {
            padding: 20px 0;
        }
        
        .nav-item {
            display: block;
            padding: 12px 25px;
            color: #333;
            text-decoration: none;
            transition: all 0.3s;
            border: none;
            background: none;
            width: 100%;
            text-align: left;
            cursor: pointer;
        }
        
        .nav-item:hover {
            background: #f8f9fa;
            color: #5a2b81;
            text-decoration: none;
        }
        
        .nav-item.active {
            background: #5a2b81;
            color: white;
        }
        
        .nav-item i {
            width: 20px;
            margin-right: 10px;
        }
        
        /* Main Content */
        .main-content {
            margin-left: 250px;
            margin-top: 70px;
            padding: 30px;
            min-height: calc(100vh - 70px);
        }
        
        /* Dashboard Cards */
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .stat-icon {
            font-size: 40px;
            margin-bottom: 10px;
        }
        
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 14px;
            text-transform: uppercase;
        }
        
        .revenue-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .revenue-card h4 {
            color: white;
            margin-bottom: 20px;
        }
        
        .revenue-amount {
            font-size: 36px;
            font-weight: bold;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }
            
            .sidebar.active {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="admin-header">
        <div class="d-flex align-items-center">
            <button class="btn btn-link text-white d-md-none" onclick="toggleSidebar()">
                <i class="fas fa-bars"></i>
            </button>
            <a href="${pageContext.request.contextPath}/admin-dashboard" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/logo.png" alt="Logo">
                <span class="logo-text">Luxury Hotel</span>
            </a>
        </div>
        
        <div class="d-flex align-items-center">
            <span class="mr-3">Welcome, ${sessionScope.user.fullName}</span>
            <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn btn-outline-light btn-sm">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    </header>
    
    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/admin-dashboard" class="nav-item active">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/admin/rooms" class="nav-item">
                <i class="fas fa-bed"></i> Rooms
            </a>
            <a href="${pageContext.request.contextPath}/admin/customers" class="nav-item">
                <i class="fas fa-users"></i> Customers
            </a>
            <a href="${pageContext.request.contextPath}/admin/bookings" class="nav-item">
                <i class="fas fa-calendar-check"></i> Bookings
            </a>
            <a href="${pageContext.request.contextPath}/HouseKeeping" class="nav-item">
                <i class="fas fa-broom"></i> Housekeeping
            </a>
            <a href="${pageContext.request.contextPath}/admin/reports" class="nav-item">
                <i class="fas fa-chart-bar"></i> Reports
            </a>
            <a href="${pageContext.request.contextPath}/admin/blogs" class="nav-item">
                <i class="fas fa-blog"></i> Blog Posts
            </a>
            <a href="${pageContext.request.contextPath}/admin/events" class="nav-item">
                <i class="fas fa-calendar-alt"></i> Events
            </a>
            <a href="${pageContext.request.contextPath}/admin/settings" class="nav-item">
                <i class="fas fa-cog"></i> Settings
            </a>
        </nav>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <div class="container-fluid">
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="#">Home</a></li>
                    <li class="breadcrumb-item active">Dashboard</li>
                </ol>
            </nav>
            
            <h1 class="mb-4">Dashboard</h1>
            
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
    </main>
    
    <!-- Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('active');
        }
        
        // Highlight active menu
        $(document).ready(function() {
            var currentPath = window.location.pathname;
            $('.nav-item').each(function() {
                if ($(this).attr('href') === currentPath) {
                    $('.nav-item').removeClass('active');
                    $(this).addClass('active');
                }
            });
        });
    </script>
</body>
</html>