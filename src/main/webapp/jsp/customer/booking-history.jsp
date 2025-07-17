<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>



<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking History</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            width: 280px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            box-shadow: 4px 0 20px rgba(0, 0, 0, 0.1);
            position: fixed;
            height: 100vh;
            z-index: 1000;
            transition: transform 0.3s ease;
            overflow-y: auto;
        }

        .sidebar-header {
            padding: 30px 25px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .sidebar-header h3 {
            font-size: 1.4rem;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .sidebar-header p {
            font-size: 0.9rem;
            opacity: 0.8;
        }

        .sidebar-menu {
            list-style: none;
            padding: 20px 0;
        }

        .sidebar-menu li {
            margin: 0;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 15px 25px;
            color: #495057;
            text-decoration: none;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
        }

        .sidebar-menu a:hover {
            background: linear-gradient(90deg, rgba(102, 126, 234, 0.1), transparent);
            border-left-color: #667eea;
            color: #667eea;
        }

        .sidebar-menu a.active {
            background: linear-gradient(90deg, rgba(102, 126, 234, 0.15), transparent);
            border-left-color: #667eea;
            color: #667eea;
            font-weight: 600;
        }

        .sidebar-menu i {
            width: 20px;
            margin-right: 15px;
            font-size: 1.1rem;
        }

        .menu-divider {
            height: 1px;
            background: linear-gradient(90deg, transparent, #e9ecef, transparent);
            margin: 15px 0;
        }

        /* Mobile Toggle */
        .mobile-toggle {
            display: none;
            position: fixed;
            top: 20px;
            left: 20px;
            z-index: 1001;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            font-size: 1.2rem;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            transition: all 0.3s ease;
        }

        .mobile-toggle:hover {
            background: #764ba2;
            transform: scale(1.05);
        }

        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 40px;
            min-height: 100vh;
            transition: margin-left 0.3s ease;
        }

        .content-header {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .content-header h2 {
            color: #343a40;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .content-header p {
            color: #6c757d;
            font-size: 1.1rem;
            margin-bottom: 0;
        }

        /* Filter Section */
        .filter-section {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .filter-row {
            display: flex;
            gap: 20px;
            align-items: end;
            flex-wrap: wrap;
        }

        .filter-group {
            flex: 1;
            min-width: 200px;
        }

        .filter-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #495057;
        }

        .filter-group select,
        .filter-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .filter-group select:focus,
        .filter-group input:focus {
            outline: none;
            border-color: #667eea;
        }

        .filter-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-left: 10px;
        }

        .filter-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
        }

        /* Stats Section */
        .stats-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 15px;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #6c757d;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0;
        }

        .stat-card.total .stat-icon { color: #667eea; }
        .stat-card.completed .stat-icon { color: #28a745; }
        .stat-card.cancelled .stat-icon { color: #dc3545; }
        .stat-card.amount .stat-icon { color: #ffc107; }

        /* Booking Cards */
        .booking-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            padding: 30px;
            margin-bottom: 25px;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.2);
            position: relative;
            overflow: hidden;
        }

        .booking-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: linear-gradient(135deg, #667eea, #764ba2);
        }

        .booking-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
        }

        .booking-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f8f9fa;
        }

        .booking-title {
            font-size: 1.4rem;
            font-weight: 700;
            color: #495057;
            margin-bottom: 0;
        }

        .booking-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .detail-item {
            display: flex;
            align-items: center;
        }

        .detail-item i {
            color: #667eea;
            margin-right: 10px;
            width: 20px;
        }

        .detail-label {
            font-weight: 600;
            color: #495057;
            margin-right: 8px;
        }

        .detail-value {
            color: #6c757d;
        }

        .badge {
            display: inline-flex;
            align-items: center;
            padding: 8px 16px;
            border-radius: 25px;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge.completed {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
        }

        .badge.cancelled {
            background: linear-gradient(135deg, #dc3545, #e83e8c);
            color: white;
        }

        .badge.no_show {
            background: linear-gradient(135deg, #6c757d, #495057);
            color: white;
        }

        .booking-actions {
            margin-top: 20px;
            padding-top: 15px;
            border-top: 1px solid #e9ecef;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            padding: 10px 20px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
            color: white;
        }

        .btn i {
            margin-right: 8px;
        }

        .empty-message {
            text-align: center;
            padding: 60px 30px;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .empty-icon {
            font-size: 4rem;
            color: #667eea;
            margin-bottom: 20px;
        }

        .empty-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #495057;
            margin-bottom: 10px;
        }

        .empty-text {
            color: #6c757d;
            font-size: 1.1rem;
            margin-bottom: 0;
        }

        /* Rating Section */
        .rating-section {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e9ecef;
        }

        .rating-stars {
            color: #ffc107;
            margin-right: 10px;
        }

        .rating-text {
            font-size: 0.9rem;
            color: #6c757d;
            text-decoration: none;
        }

        .rating-text:hover {
            color: #667eea;
            text-decoration: none;
        }

        /* Sidebar overlay for mobile */
        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
        }

        .sidebar-overlay.active {
            display: block;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .mobile-toggle {
                display: block;
            }

            .sidebar {
                transform: translateX(-100%);
            }

            .sidebar.active {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
                padding: 80px 20px 40px;
            }

            .booking-details {
                grid-template-columns: 1fr;
                gap: 15px;
            }

            .booking-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .content-header {
                padding: 25px 20px;
            }

            .content-header h2 {
                font-size: 1.6rem;
            }

            .booking-card {
                padding: 25px 20px;
            }

            .filter-row {
                flex-direction: column;
                gap: 15px;
            }

            .filter-group {
                min-width: auto;
            }

            .stats-section {
                grid-template-columns: repeat(2, 1fr);
                gap: 15px;
            }
        }
    </style>
</head>
<body>
    <!-- Mobile Toggle Button -->
    <button class="mobile-toggle" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </button>

    <!-- Sidebar Overlay -->
    <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

    <div class="dashboard-container">
        <!-- Sidebar -->
        <nav class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <h3><i class="fas fa-user-circle"></i> Customer Panel</h3>
                <p>Welcome back!</p>
            </div>
            <ul class="sidebar-menu">
                <li>
                    <a href="${pageContext.request.contextPath}/customer/bookings">
                        <i class="fas fa-calendar-check"></i>
                        <span>My Bookings</span>
                    </a>
                </li>
                <li>
                    <a href="#" class="active">
                        <i class="fas fa-history"></i>
                        <span>Booking History</span>
                    </a>
                </li>
                  <a href="${pageContext.request.contextPath}/customer/feedback?action=list">
      <i class="fas fa-comments"></i>
      <span>My Feedback</span>
  </a>
                <div class="menu-divider"></div>
                <li>
                    <a href="${pageContext.request.contextPath}/customer/profile">
                        <i class="fas fa-user-edit"></i>
                        <span>User Profile</span>
                    </a>
                </li>
                    <li>
                       <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/services" >
                                                <i class="fa fa-concierge-bell"></i> Book Services
                                            </a>
                </li>
                <div class="menu-divider"></div>
                <li>
                    <a href="/index.jsp">
                        <i class="fas fa-home"></i>
                        <span>Homepage</span>
                    </a>
                </li>
                <li>
                    <a href="search-rooms.jsp">
                        <i class="fas fa-search"></i>
                        <span>Search Rooms</span>
                    </a>
                </li>
                <li>
                    <a href="$">
                        <i class="fas fa-headset"></i>
                        <span>Support</span>
                    </a>
                </li>
                <div class="menu-divider"></div>
                <li>
                    <a href="${pageContext.request.contextPath}/LogoutServlet" style="color: #dc3545;">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Logout</span>
                    </a>
                </li>
            </ul>
        </nav>

        <!-- Main Content -->
        <main class="main-content">
            <div class="content-header">
                <h2><i class="fas fa-history"></i> Booking History</h2>
                <p>View and manage your past hotel reservations</p>
            </div>

            <!-- Stats Section -->
            <div class="stats-section">
                <div class="stat-card total">
                    <div class="stat-icon">
                        <i class="fas fa-calendar-alt"></i>
                    </div>
                    <div class="stat-number">
                        <c:set var="totalBookings" value="${fn:length(historyBookings)}" />
                        ${totalBookings}
                    </div>
                    <div class="stat-label">Total Bookings</div>
                </div>
                
                <div class="stat-card completed">
                    <div class="stat-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-number">
                        <c:set var="completedCount" value="0" />
                        <c:forEach var="booking" items="${historyBookings}">
                            <c:if test="${booking.status == 'COMPLETED'}">
                                <c:set var="completedCount" value="${completedCount + 1}" />
                            </c:if>
                        </c:forEach>
                        ${completedCount}
                    </div>
                    <div class="stat-label">Completed</div>
                </div>
                
                <div class="stat-card cancelled">
                    <div class="stat-icon">
                        <i class="fas fa-times-circle"></i>
                    </div>
                    <div class="stat-number">
                        <c:set var="cancelledCount" value="0" />
                        <c:forEach var="booking" items="${historyBookings}">
                            <c:if test="${booking.status == 'CANCELLED'}">
                                <c:set var="cancelledCount" value="${cancelledCount + 1}" />
                            </c:if>
                        </c:forEach>
                        ${cancelledCount}
                    </div>
                    <div class="stat-label">Cancelled</div>
                </div>
                
                <div class="stat-card amount">
                    <div class="stat-icon">
                        <i class="fas fa-dollar-sign"></i>
                    </div>
                    <div class="stat-number">
                        <c:set var="totalAmount" value="0" />
                        <c:forEach var="booking" items="${historyBookings}">
                            <c:if test="${booking.status == 'COMPLETED'}">
                                <c:set var="totalAmount" value="${totalAmount + booking.basePrice}" />
                            </c:if>
                        </c:forEach>
                        <fmt:formatNumber value="${totalAmount}" type="currency" maxFractionDigits="0" />
                    </div>
                    <div class="stat-label">Total Spent</div>
                </div>
            </div>

            <!-- Filter Section -->
            <div class="filter-section">
             <form method="GET" action="${pageContext.request.contextPath}/customer/history">

                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="status">Filter by Status</label>
                            <select id="status" name="status">
                                <option value="">All Status</option>
                                <option value="COMPLETED" ${selectedStatus == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                <option value="CANCELLED" ${selectedStatus == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                                <option value="NO_SHOW" ${selectedStatus == 'NO_SHOW' ? 'selected' : ''}>No Show</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="dateFrom">From Date</label>
                            <input type="date" id="dateFrom" name="dateFrom" value="${selectedDateFrom}">
                        </div>
                        
                        <div class="filter-group">
                            <label for="dateTo">To Date</label>
                            <input type="date" id="dateTo" name="dateTo" value="${selectedDateTo}">
                        </div>
                        
                        <div class="filter-group">
                            <button type="submit" class="filter-btn">
                                <i class="fas fa-filter"></i> Filter
                            </button>
                        </div>
                    </div>
                </form>
            </div>

           <!-- Nếu không có đơn đặt phòng -->
<c:if test="${empty historyBookings}">
    <div class="empty-message">
        <div class="empty-icon">
            <i class="fas fa-history"></i>
        </div>
        <div class="empty-title">No Booking History</div>
        <div class="empty-text">You don't have any past bookings yet. Start exploring our rooms!</div>
    </div>
</c:if>

<div class="booking-list">
    <c:forEach var="booking" items="${historyBookings}">
        <div class="booking-card">
            <div class="booking-header">
                <div class="booking-title">
                    <i class="fas fa-bed"></i> Room ${booking.roomNumber} 
                </div>
                <div class="booking-id">ID: #${booking.id}</div>
            </div>

            <div class="booking-details">
                <div class="detail-item">
                    <i class="fas fa-calendar-plus"></i>
                    <span class="detail-label">Check-in:</span>
                    <span class="detail-value">
                        <fmt:formatDate value="${booking.checkIn}" pattern="MMM dd, yyyy" />
                    </span>
                </div>

                <div class="detail-item">
                    <i class="fas fa-calendar-minus"></i>
                    <span class="detail-label">Check-out:</span>
                    <span class="detail-value">
                        <fmt:formatDate value="${booking.checkOut}" pattern="MMM dd, yyyy" />
                    </span>
                </div>

                <div class="detail-item">
                    <i class="fas fa-dollar-sign"></i>
                    <span class="detail-label">Total Paid:</span>
                    <span class="detail-value">
                        <fmt:formatNumber value="${booking.totalAmount}" type="currency" />
                    </span>
                </div>

                <div class="detail-item">
                    <i class="fas fa-info-circle"></i>
                    <span class="detail-label">Status:</span>
                    <span class="badge ${booking.status.toLowerCase()}">${booking.status}</span>
                </div>
            </div>

            <div class="booking-actions">
                <a href="${pageContext.request.contextPath}/customer/booking-detail?id=${booking.id}"
                   class="btn btn-primary">
                    <i class="fas fa-eye"></i> View Details
                </a>

                <%-- Display Rate Stay or Your Feedback button based on status and rating --%>
                <c:choose>
                    <c:when test="${fn:toUpperCase(fn:trim(booking.status)) == 'COMPLETED' && (booking.rating == null || booking.rating == 0)}">
                        <a href="${pageContext.request.contextPath}/customer/feedback?action=view&id=${booking.id}"
   class="btn btn-warning">
    <i class="fas fa-star"></i> Rate Stay
</a>

                    </c:when>
                    <c:when test="${fn:toUpperCase(fn:trim(booking.status)) == 'COMPLETED' && booking.rating != null && booking.rating > 0}">
                        <a href="${pageContext.request.contextPath}/customer/feedback?action=list&id=${booking.id}"
                           class="btn btn-outline-success">
                            <i class="fas fa-comment-dots"></i> Your Feedback
                        </a>
                    </c:when>
                </c:choose>
            </div>
        </div>
    </c:forEach>
</div>

     <!-- JavaScript -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.querySelector('.sidebar-overlay');
            
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        }

        // Handle window resize
        window.addEventListener('resize', function() {
            if (window.innerWidth > 768) {
                const sidebar = document.getElementById('sidebar');
                const overlay = document.querySelector('.sidebar-overlay');
                sidebar.classList.remove('active');
                overlay.classList.remove('active');
            }
        });
    </script>
</body>
</html>
