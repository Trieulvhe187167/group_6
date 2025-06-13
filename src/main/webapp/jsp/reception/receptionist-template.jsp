<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${pageTitle} - Luxury Hotel Receptionist</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap4.min.css">

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
            background: #17a2b8; /* Cyan color for receptionist */
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
            height: 60px;
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
            margin-top: 10px;
        }

        .sidebar-nav {
            padding: 20px 0;
        }

        .nav-item {
            display: flex;
            align-items: center;
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
            color: #17a2b8;
            text-decoration: none;
        }

        .nav-item.active {
            background: #17a2b8;
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

        /* Common Styles */
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
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
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

        .table-container {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .quick-action-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            text-align: center;
            transition: all 0.3s;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            border: 2px solid transparent;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .quick-action-card:hover {
            border-color: #17a2b8;
            transform: translateY(-3px);
            text-decoration: none;
            color: inherit;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .quick-action-icon {
            font-size: 48px;
            margin-bottom: 15px;
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
            <a href="${pageContext.request.contextPath}/receptionist/dashboard" class="logo">
                <img src="${pageContext.request.contextPath}/assets/images/logo-white.png" alt="Logo">
                <span class="logo-text">Receptionist Portal</span>
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
            <a href="${pageContext.request.contextPath}/reception-dashboard" 
               class="nav-item ${activePage == 'dashboard' ? 'active' : ''}">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
                 <a href="${pageContext.request.contextPath}/receptionist/booking" 
               class="nav-item ${activePage == 'booking' ? 'active' : ''}">
                <i class="fas fa-calendar-check"></i> Booking
            </a>
            <a href="${pageContext.request.contextPath}/receptionist/reservations" 
               class="nav-item ${activePage == 'reservations' ? 'active' : ''}">
                <i class="fas fa-calendar-check"></i> Reservations
            </a>
            <a href="${pageContext.request.contextPath}/receptionist/check-in" 
               class="nav-item ${activePage == 'checkin' ? 'active' : ''}">
                <i class="fas fa-sign-in-alt"></i> Check-in
            </a>
            <a href="${pageContext.request.contextPath}/receptionist/check-out" 
               class="nav-item ${activePage == 'checkout' ? 'active' : ''}">
                <i class="fas fa-sign-out-alt"></i> Check-out
            </a>
            <a href="${pageContext.request.contextPath}/receptionist/payments" 
               class="nav-item ${activePage == 'payments' ? 'active' : ''}">
                <i class="fas fa-money-bill-wave"></i> Payments
            </a>
            <a href="${pageContext.request.contextPath}/receptionist/guests" 
               class="nav-item ${activePage == 'guests' ? 'active' : ''}">
                <i class="fas fa-users"></i> Guests
            </a>
            <a href="${pageContext.request.contextPath}/receptionist/services" 
               class="nav-item ${activePage == 'services' ? 'active' : ''}">
                <i class="fas fa-concierge-bell"></i> Services
            </a>
            <a href="${pageContext.request.contextPath}/receptionist/amenities" 
               class="nav-item ${activePage == 'amenities' ? 'active' : ''}">
                <i class="fas fa-bath"></i> Room Amenities
            </a>
            <a href="${pageContext.request.contextPath}/receptionist/notifications" 
               class="nav-item ${activePage == 'notifications' ? 'active' : ''}">
                <i class="fas fa-bell"></i> Notifications
            </a>
            <a href="${pageContext.request.contextPath}/receptionist/activity-log" 
               class="nav-item ${activePage == 'activitylog' ? 'active' : ''}">
                <i class="fas fa-history"></i> Activity Log
            </a>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">
        <c:if test="${not empty contentPage}">
            <jsp:include page="${contentPage}" />
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger" role="alert">
                ${error}
            </div>
        </c:if>
    </main>

    <!-- Core JavaScript -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap4.min.js"></script>

    <script>
        // Common JavaScript functions for Receptionist template
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('active');
        }
    </script>
</body>
</html>