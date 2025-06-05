<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Booking Management - Luxury Hotel</title>
    
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
        
        /* Table Styles */
        .table-container {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .badge-confirmed {
            background-color: #28a745;
            color: white;
        }
        
        .badge-pending {
            background-color: #ffc107;
            color: #333;
        }
        
        .btn-view {
            background-color: #17a2b8;
            color: white;
            border: none;
        }
        
        .btn-edit {
            background-color: #ffc107;
            color: #333;
            border: none;
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
            <a href="${pageContext.request.contextPath}/admin-dashboard" class="nav-item">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/admin/rooms" class="nav-item">
                <i class="fas fa-bed"></i> Rooms
            </a>
            <a href="${pageContext.request.contextPath}/admin/customers" class="nav-item">
                <i class="fas fa-users"></i> Customers
            </a>
            <a href="${pageContext.request.contextPath}/admin/bookings" class="nav-item active">
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
            <!-- Breadcrumb -->
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin-dashboard">Home</a></li>
                    <li class="breadcrumb-item active">Bookings</li>
                </ol>
            </nav>
            
            <h1 class="mb-4">Booking Management</h1>
            
            <!-- Buttons -->
            <div class="mb-4">
                <a href="${pageContext.request.contextPath}/admin/bookings?action=new" class="btn btn-primary">
                    <i class="fas fa-plus"></i> New Booking
                </a>
                <button class="btn btn-secondary" onclick="exportBookings()">
                    <i class="fas fa-download"></i> Export
                </button>
            </div>
            
            <!-- Table -->
            <div class="table-container">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Booking ID</th>
                            <th>Customer</th>
                            <th>Room</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Status</th>
                            <th>Total Amount</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="booking" items="${bookings}">
                            <tr>
                                <td>#${booking.id}</td>
                                <td>${booking.customerName}</td>
                                <td>${booking.roomNumber}</td>
                                <td><fmt:formatDate value="${booking.checkIn}" pattern="dd/MM/yyyy"/></td>
                                <td><fmt:formatDate value="${booking.checkOut}" pattern="dd/MM/yyyy"/></td>
                                <td>
                                    <span class="badge badge-${booking.status == 'CONFIRMED' ? 'confirmed' : 'pending'}">
                                        ${booking.status}
                                    </span>
                                </td>
                                <td><fmt:formatNumber value="${booking.totalAmount}" pattern="#,##0"/>₫</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/admin/bookings?action=view&id=${booking.id}" 
                                       class="btn btn-sm btn-view">View</a>
                                    <a href="${pageContext.request.contextPath}/admin/bookings?action=edit&id=${booking.id}" 
                                       class="btn btn-sm btn-edit">Edit</a>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <c:if test="${empty bookings}">
                            <tr>
                                <td colspan="8" class="text-center">No bookings found</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
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
        
        function exportBookings() {
            alert('Export functionality to be implemented');
        }
    </script>
</body>
</html>