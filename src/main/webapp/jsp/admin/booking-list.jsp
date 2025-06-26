<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.List, model.Reservation" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Booking Management - Admin Dashboard</title>
    
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
            height: 60px;
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
        .table-responsive {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .table {
            margin-bottom: 0;
        }
        
        .table th {
            border-top: none;
            background: #f8f9fa;
            font-weight: 600;
            color: #333;
        }
        
        .table td {
            vertical-align: middle;
        }
        
        .badge {
            font-size: 0.75em;
            padding: 0.375rem 0.75rem;
        }
        
        /* Filter Section */
        .filter-section {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        /* Breadcrumb Styles */
        .breadcrumb {
            background: white;
            border-radius: 8px;
            padding: 12px 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .breadcrumb-item + .breadcrumb-item::before {
            content: ">";
            color: #6c757d;
        }
        
        .breadcrumb-item a {
            color: #5a2b81;
            text-decoration: none;
        }
        
        .breadcrumb-item a:hover {
            color: #7b3fa0;
            text-decoration: underline;
        }
        
        .breadcrumb-item.active {
            color: #6c757d;
        }
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
                <img src="${pageContext.request.contextPath}/assets/images/logo-white.png" alt="Logo">
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
    <!-- Sidebar -->
        <aside class="sidebar" id="sidebar">
            <nav class="sidebar-nav">
                <a href="${pageContext.request.contextPath}/admin-dashboard" 
                   class="nav-item ${activePage == 'dashboard' ? 'active' : ''}">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/admin/rooms" 
                   class="nav-item ${activePage == 'rooms' ? 'active' : ''}">
                    <i class="fas fa-bed"></i> Rooms
                </a>
                <a href="${pageContext.request.contextPath}/admin/customers" 
                   class="nav-item ${activePage == 'customers' ? 'active' : ''}">
                    <i class="fas fa-users"></i> Customers
                </a>
                <a href="${pageContext.request.contextPath}/admin/staff" 
                   class="nav-item ${activePage == 'staff' ? 'active' : ''}">
                    <i class="fas fa-user-tie"></i> Staff
                </a>
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/change-request">
        <i class="fas fa-clock"></i> Pending Changes
        <span class="badge badge-warning ml-1">${pendingChangesCount}</span>
    </a>
                <a href="${pageContext.request.contextPath}/jsp/admin/booking-list.jsp" 
                   class="nav-item ${activePage == 'bookings' ? 'active' : ''}">
                    <i class="fas fa-calendar-check"></i> Bookings
                </a>
                    
                <a href="${pageContext.request.contextPath}/HouseKeeping" 
                   class="nav-item ${activePage == 'houseKeeping' ? 'active' : ''}">
                    <i class="fas fa-broom"></i> Housekeeping
                </a>
              
                <a href="${pageContext.request.contextPath}/admin/reports" 
                   class="nav-item ${activePage == 'reports' ? 'active' : ''}">
                    <i class="fas fa-chart-bar"></i> Reports
                </a>
                <a href="${pageContext.request.contextPath}/admin/blogs" 
                   class="nav-item ${activePage == 'blogs' ? 'active' : ''}">
                    <i class="fas fa-blog"></i> Blog Posts
                </a>
                <a href="${pageContext.request.contextPath}/admin/events" 
                   class="nav-item ${activePage == 'events' ? 'active' : ''}">
                    <i class="fas fa-calendar-alt"></i> Events
                </a>
                <a href="${pageContext.request.contextPath}/admin/settings" 
                   class="nav-item ${activePage == 'settings' ? 'active' : ''}">
                    <i class="fas fa-cog"></i> Settings
                </a>
            </nav>
        </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <div class="container-fluid">
            <!-- Breadcrumb -->
            <nav aria-label="breadcrumb" class="mb-4">
                <ol class="breadcrumb bg-white shadow-sm rounded px-3 py-2">
                    <li class="breadcrumb-item">
                        <a href="${pageContext.request.contextPath}/admin-dashboard" class="text-decoration-none">
                            <i class="fas fa-home"></i> Home Dashboard
                        </a>
                    </li>
                    <li class="breadcrumb-item active" aria-current="page">
                        <i class="fas fa-calendar-check"></i> Booking Management
                    </li>
                </ol>
            </nav>
            
            <h2 class="mb-4">Booking Management</h2>
            
            <!-- Filter Section -->
            <div class="filter-section">
                <form class="row" method="GET">
                    <div class="col-md-3">
                        <label for="status">Status</label>
                        <select class="form-control" id="status" name="status">
                            <option value="">All Status</option>
                            <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>Pending</option>
                            <option value="CONFIRMED" ${param.status == 'CONFIRMED' ? 'selected' : ''}>Confirmed</option>
                            <option value="CANCELLED" ${param.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                            <option value="COMPLETED" ${param.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="fromDate">From Date</label>
                        <input type="date" class="form-control" id="fromDate" name="fromDate" value="${param.fromDate}">
                    </div>
                    <div class="col-md-3">
                        <label for="toDate">To Date</label>
                        <input type="date" class="form-control" id="toDate" name="toDate" value="${param.toDate}">
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary mr-2">
                            <i class="fas fa-search"></i> Filter
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/bookings" class="btn btn-secondary">
                            <i class="fas fa-undo"></i> Reset
                        </a>
                    </div>
                </form>
            </div>
            
            <!-- Booking Table -->
            <div class="table-responsive">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h5 class="mb-0">All Bookings</h5>
                </div>
                
                <table class="table table-bordered table-hover">
                    <thead class="thead-dark">
                        <tr>
                            <th>#</th>
                            <th>Booking ID</th>
                            <th>Customer</th>
                            <th>Room</th>
                            <th>Check-In</th>
                            <th>Check-Out</th>
                            <th>Status</th>
                            <th>Total Amount</th>
                            <th>Created At</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty reservations}">
                                <c:forEach var="b" items="${reservations}" varStatus="i">
                                    <tr>
                                        <td>${i.count}</td>
                                        <td>
                                            <strong>#${b.id}</strong>
                                        </td>
                                        <td>
                                            <div>
                                                <strong>${b.userFullName}</strong><br>
                                                <small class="text-muted">${b.userEmail}</small>
                                            </div>
                                        </td>
                                        <td>
                                            <div>
                                                <strong>${b.roomName}</strong><br>
                                                <small class="text-muted">Room ${b.roomNumber}</small>
                                            </div>
                                        </td>
                                        <td><fmt:formatDate value="${b.checkIn}" pattern="dd/MM/yyyy"/></td>
                                        <td><fmt:formatDate value="${b.checkOut}" pattern="dd/MM/yyyy"/></td>
                                        <td>
                                            <span class="badge 
                                                <c:choose>
                                                    <c:when test="${b.status == 'CONFIRMED'}">badge-success</c:when>
                                                    <c:when test="${b.status == 'PENDING'}">badge-warning</c:when>
                                                    <c:when test="${b.status == 'CANCELLED'}">badge-danger</c:when>
                                                    <c:when test="${b.status == 'COMPLETED'}">badge-info</c:when>
                                                    <c:otherwise>badge-secondary</c:otherwise>
                                                </c:choose>">
                                                ${b.status}
                                            </span>
                                        </td>
                                        <td>
                                            <strong><fmt:formatNumber value="${b.totalAmount}" pattern="#,##0"/> ₫</strong>
                                        </td>
                                        <td><fmt:formatDate value="${b.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                        <td>
                                            <div class="btn-group" role="group">
                                                <a href="${pageContext.request.contextPath}/admin/booking-detail?id=${b.id}" 
                                                   class="btn btn-sm btn-info" title="View Details">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <c:if test="${b.status == 'PENDING'}">
                                                    <button class="btn btn-sm btn-success" 
                                                            onclick="updateBookingStatus(${b.id}, 'CONFIRMED')" 
                                                            title="Confirm Booking">
                                                        <i class="fas fa-check"></i>
                                                    </button>
                                                    <button class="btn btn-sm btn-danger" 
                                                            onclick="updateBookingStatus(${b.id}, 'CANCELLED')" 
                                                            title="Cancel Booking">
                                                        <i class="fas fa-times"></i>
                                                    </button>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="10" class="text-center text-muted py-4">
                                        <i class="fas fa-inbox fa-3x mb-3"></i><br>
                                        No bookings found
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
                
                <!-- Pagination -->
                <c:if test="${not empty reservations}">
                    <nav aria-label="Booking pagination">
                        <ul class="pagination justify-content-center">
                            <li class="page-item">
                                <a class="page-link" href="#" aria-label="Previous">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>
                            <li class="page-item active"><a class="page-link" href="#">1</a></li>
                            <li class="page-item"><a class="page-link" href="#">2</a></li>
                            <li class="page-item"><a class="page-link" href="#">3</a></li>
                            <li class="page-item">
                                <a class="page-link" href="#" aria-label="Next">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </c:if>
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
        
        // Update booking status
        function updateBookingStatus(bookingId, status) {
            if (confirm('Are you sure you want to ' + status.toLowerCase() + ' this booking?')) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/admin/update-booking-status',
                    method: 'POST',
                    data: {
                        bookingId: bookingId,
                        status: status
                    },
                    success: function(response) {
                        if (response.success) {
                            location.reload();
                        } else {
                            alert('Error updating booking status: ' + response.message);
                        }
                    },
                    error: function() {
                        alert('Error updating booking status');
                    }
                });
            }
        }
        
        // Export to Excel
        function exportToExcel() {
            window.location.href = '${pageContext.request.contextPath}/admin/export-bookings?format=excel';
        }
    </script>
</body>
</html>