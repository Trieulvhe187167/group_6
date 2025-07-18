<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Feedback</title>
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

        /* Feedback Cards */
        .feedback-card {
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

        .feedback-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: linear-gradient(135deg, #667eea, #764ba2);
        }

        .feedback-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f8f9fa;
        }

        .booking-id {
            font-size: 1.4rem;
            font-weight: 700;
            color: #495057;
            margin-bottom: 0;
        }

        .card-details {
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
            margin-right: 12px;
            width: 20px;
            font-size: 1.1rem;
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

        .rating-section {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
        }

        .rating-display {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }

        .rating-stars {
            color: #ffc107;
            margin-right: 10px;
            font-size: 1.2rem;
        }

        .rating-number {
            font-size: 1.1rem;
            font-weight: 600;
            color: #495057;
        }

        .rating-badge {
            background: linear-gradient(135deg, #ffc107, #ffb300);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
            margin-left: 10px;
        }

        .unrated-badge {
            background: linear-gradient(135deg, #6c757d, #495057);
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 600;
        }

        .comment-section {
            margin-top: 15px;
            padding: 15px;
            background: rgba(102, 126, 234, 0.05);
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }

        .comment-text {
            color: #495057;
            font-style: italic;
            margin-bottom: 0;
            line-height: 1.6;
        }

        .card-actions {
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
            cursor: pointer;
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

        .btn-warning {
            background: linear-gradient(135deg, #ffc107, #ffb300);
            color: white;
        }

        .btn-warning:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 193, 7, 0.3);
            color: white;
        }

        .btn-info {
            background: linear-gradient(135deg, #17a2b8, #138496);
            color: white;
        }

        .btn-info:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(23, 162, 184, 0.3);
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
        .stat-card.rated .stat-icon { color: #28a745; }
        .stat-card.unrated .stat-icon { color: #ffc107; }

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

            .card-details {
                grid-template-columns: 1fr;
                gap: 15px;
            }

            .card-header {
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

            .feedback-card {
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
    <!-- Sidebar -->
    <div class="dashboard-container">
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
                    <a href="${pageContext.request.contextPath}/customer/history">
                        <i class="fas fa-history"></i>
                        <span>Booking History</span>
                    </a>
                </li>
                <li>
                    <a href="#" class="active">
                        <i class="fas fa-comments"></i>
                        <span>My Feedback</span>
                    </a>
                </li>
                <div class="menu-divider"></div>
                <li>
                    <a href="${pageContext.request.contextPath}/customer/profile">
                        <i class="fas fa-user-edit"></i>
                        <span>User Profile</span>
                    </a>
                </li>
                <li>
                    <a href="change-password.jsp">
                        <i class="fas fa-key"></i>
                        <span>Change Password</span>
                    </a>
                </li>
                <li>
                    <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/services">
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
                    <a href="support.jsp">
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
                <h2><i class="fas fa-comments"></i> My Feedback</h2>
                <p>View and manage your feedback for completed bookings</p>
            </div>

            <!-- Statistics Section -->
            <div class="stats-section">
                <div class="stat-card total">
                    <div class="stat-icon">
                        <i class="fas fa-list-alt"></i>
                    </div>
                    <div class="stat-number">
                        <c:set var="totalCount" value="0" />
                        <c:forEach var="booking" items="${feedbackBookings}">
                            <c:if test="${booking.status == 'COMPLETED'}">
                                <c:set var="totalCount" value="${totalCount + 1}" />
                            </c:if>
                        </c:forEach>
                        ${totalCount}
                    </div>
                    <div class="stat-label">Total Bookings</div>
                </div>
                <div class="stat-card rated">
                    <div class="stat-icon">
                        <i class="fas fa-star"></i>
                    </div>
                    <div class="stat-number">
                        <c:set var="ratedCount" value="0" />
                        <c:forEach var="booking" items="${feedbackBookings}">
                            <c:if test="${booking.status == 'COMPLETED' && booking.rating > 0}">
                                <c:set var="ratedCount" value="${ratedCount + 1}" />
                            </c:if>
                        </c:forEach>
                        ${ratedCount}
                    </div>
                    <div class="stat-label">Rated</div>
                </div>
                <div class="stat-card unrated">
                    <div class="stat-icon">
                        <i class="fas fa-star-half-alt"></i>
                    </div>
                    <div class="stat-number">
                        <c:set var="unratedCount" value="0" />
                        <c:forEach var="booking" items="${feedbackBookings}">
                            <c:if test="${booking.status == 'COMPLETED' && (booking.rating == null || booking.rating == 0)}">
                                <c:set var="unratedCount" value="${unratedCount + 1}" />
                            </c:if>
                        </c:forEach>
                        ${unratedCount}
                    </div>
                    <div class="stat-label">Unrated</div>
                </div>
            </div>

            <!-- Filter Section -->
            <div class="filter-section">
                <form method="get" class="filter-row">
                    <div class="filter-group">
                        <label for="filterSelect">Filter by Status:</label>
                        <select name="filter" id="filterSelect" onchange="this.form.submit()">
                            <option value="all" ${param.filter == 'all' ? 'selected' : ''}>All Completed</option>
                            <option value="rated" ${param.filter == 'rated' ? 'selected' : ''}>Rated Only</option>
                            <option value="unrated" ${param.filter == 'unrated' ? 'selected' : ''}>Unrated Only</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label for="sortSelect">Sort by:</label>
                        <select name="sort" id="sortSelect" onchange="this.form.submit()">
                            <option value="date" ${param.sort == 'date' ? 'selected' : ''}>Date (Latest First)</option>
                            <option value="rating" ${param.sort == 'rating' ? 'selected' : ''}>Rating (Highest First)</option>
                        </select>
                    </div>
                </form>
            </div>

            <!-- Feedback Cards -->
            <div class="feedback-list">
                <c:set var="hasVisibleBookings" value="false" />
                <c:forEach var="booking" items="${feedbackBookings}">
                    <!-- Only show COMPLETED bookings -->
                    <c:if test="${booking.status == 'COMPLETED'}">
                        <c:set var="showBooking" value="true" />
                        <!-- Apply filter -->
                        <c:if test="${param.filter == 'rated' && (booking.rating == null || booking.rating == 0)}">
                            <c:set var="showBooking" value="false" />
                        </c:if>
                        <c:if test="${param.filter == 'unrated' && booking.rating > 0}">
                            <c:set var="showBooking" value="false" />
                        </c:if>
                        <c:if test="${showBooking}">
                            <c:set var="hasVisibleBookings" value="true" />
                            <div class="feedback-card">
                                <div class="card-header">
                                    <h4 class="booking-id">Booking #${booking.id}</h4>
                                    <span class="badge completed">
                                        <i class="fas fa-check-circle"></i>
                                        Completed
                                    </span>
                                </div>
                                
                                <div class="card-details">
                                    <div class="detail-item">
                                        <i class="fas fa-bed"></i>
                                        <span class="detail-label">Room:</span>
                                        <span class="detail-value">${booking.roomNumber}</span>
                                    </div>
                                    <div class="detail-item">
                                        <i class="fas fa-calendar-alt"></i>
                                        <span class="detail-label">Check-in:</span>
                                        <span class="detail-value">
                                            <fmt:formatDate value="${booking.checkIn}" pattern="dd/MM/yyyy"/>
                                        </span>
                                    </div>
                                    <div class="detail-item">
                                        <i class="fas fa-calendar-check"></i>
                                        <span class="detail-label">Check-out:</span>
                                        <span class="detail-value">
                                            <fmt:formatDate value="${booking.checkOut}" pattern="dd/MM/yyyy"/>
                                        </span>
                                    </div>
                                    <div class="detail-item">
                                        <i class="fas fa-clock"></i>
                                        <span class="detail-label">Duration:</span>
                                        <span class="detail-value">
                                            <c:set var="duration" value="${(booking.checkOut.time - booking.checkIn.time) / (1000 * 60 * 60 * 24)}" />
                                            ${duration} night(s)
                                        </span>
                                    </div>
                                </div>
                                
                                <div class="rating-section">
                                    <c:choose>
                                        <c:when test="${booking.rating > 0}">
                                            <div class="rating-display">
                                                <div class="rating-stars">
                                                    <c:forEach begin="1" end="5" var="i">
                                                        <c:choose>
                                                            <c:when test="${i <= booking.rating}">
                                                                <i class="fas fa-star"></i>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="far fa-star"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:forEach>
                                                </div>
                                                <span class="rating-number">${booking.rating}</span>
                                                <span class="rating-badge">${booking.rating}/5 Stars</span>
                                            </div>
                                            
                                            <c:if test="${not empty booking.comment}">
                                                <div class="comment-section">
                                                    <h6 style="margin-bottom: 10px; color: #495057; font-weight: 600;">
                                                        <i class="fas fa-comment-dots"></i> Your Comment:
                                                    </h6>
                                                    <p class="comment-text">"${booking.comment}"</p>
                                                </div>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="rating-display">
                                                <div class="rating-stars" style="color: #ccc;">
                                                    <i class="far fa-star"></i>
                                                    <i class="far fa-star"></i>
                                                    <i class="far fa-star"></i>
                                                    <i class="far fa-star"></i>
                                                    <i class="far fa-star"></i>
                                                </div>
                                                <span class="unrated-badge">
                                                    <i class="fas fa-exclamation-triangle"></i>
                                                    Not Yet Rated
                                                </span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                
                                <div class="card-actions">
                                    <c:choose>
                                        <c:when test="${booking.rating > 0}">
                                            <button type="button" class="btn btn-info"
                                                data-rating="${booking.rating}"
                                                data-comment="${fn:escapeXml(booking.comment)}"
                                                onclick="showFeedbackModal(this)">
                                                <i class="fas fa-eye"></i>
                                                View Full Feedback
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/customer/feedback?action=view&id=${booking.id}" 
                                               class="btn btn-warning">
                                                <i class="fas fa-star"></i>
                                                Rate This Booking
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:if>
                    </c:if>
                </c:forEach>
                
                <!-- Empty State -->
                <c:if test="${not hasVisibleBookings}">
                    <div class="empty-message">
                        <div class="empty-icon">
                            <i class="fas fa-clipboard-list"></i>
                        </div>
                        <h3 class="empty-title">No Feedback Available</h3>
                        <p class="empty-text">
                            <c:choose>
                                <c:when test="${param.filter == 'rated'}">
                                    You haven't rated any bookings yet. Complete a booking and share your experience!
                                </c:when>
                                <c:when test="${param.filter == 'unrated'}">
                                    All your completed bookings have been rated. Thank you for your feedback!
                                </c:when>
                                <c:otherwise>
                                    You don't have any completed bookings to rate yet. Book a room and share your experience!
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </c:if>
            </div>
        </main>
    </div>

    <!-- Feedback Modal -->
    <div class="modal fade" id="feedbackModal" tabindex="-1" aria-labelledby="feedbackModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header" style="background: linear-gradient(135deg, #667eea, #764ba2); color: white;">
                    <h5 class="modal-title" id="feedbackModalLabel">
                        <i class="fas fa-star"></i> Feedback Details
                    </h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color: white;">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="padding: 30px;">
                    <div style="margin-bottom: 25px;">
                        <h6 style="color: #495057; font-weight: 600; margin-bottom: 15px;">
                            <i class="fas fa-star" style="color: #ffc107;"></i> Rating:
                        </h6>
                        <div style="display: flex; align-items: center;">
                            <div id="modalRatingStars" class="rating-stars" style="margin-right: 15px; font-size: 1.5rem;"></div>
                            <span id="modalRating" style="font-size: 1.2rem; font-weight: 600; color: #495057;"></span>
                            <span style="color: #6c757d; margin-left: 5px;">/ 5</span>
                        </div>
                    </div>
                    
                    <div>
                        <h6 style="color: #495057; font-weight: 600; margin-bottom: 15px;">
                            <i class="fas fa-comment-dots" style="color: #667eea;"></i> Comment:
                        </h6>
                        <div id="modalComment" style="background: rgba(102, 126, 234, 0.05); padding: 20px; border-radius: 10px; border-left: 4px solid #667eea; white-space: pre-line; color: #495057; font-style: italic; line-height: 1.6;"></div>
                    </div>
                </div>
                <div class="modal-footer" style="background: #f8f9fa;">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">
                        <i class="fas fa-times"></i> Close
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Mobile Toggle Button -->
    <button class="mobile-toggle" id="mobileToggle">
        <i class="fas fa-bars"></i>
    </button>

    <!-- Sidebar Overlay -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function showFeedbackModal(button) {
            var rating = button.getAttribute('data-rating');
            var comment = button.getAttribute('data-comment');
            document.getElementById('modalRating').textContent = rating;
            document.getElementById('modalComment').textContent = comment || 'No comment provided.';
            
            // Generate stars for modal
            const starsContainer = document.getElementById('modalRatingStars');
            starsContainer.innerHTML = '';
            for (let i = 1; i <= 5; i++) {
                const star = document.createElement('i');
                star.className = i <= rating ? 'fas fa-star' : 'far fa-star';
                starsContainer.appendChild(star);
            }
            
            $('#feedbackModal').modal('show');
        }

        // Mobile sidebar toggle
        document.getElementById('mobileToggle').addEventListener('click', function() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.getElementById('sidebarOverlay');
            
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        });

        // Close sidebar when clicking overlay
        document.getElementById('sidebarOverlay').addEventListener('click', function() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.getElementById('sidebarOverlay');
            
            sidebar.classList.remove('active');
            overlay.classList.remove('active');
        });

        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function(event) {
            const sidebar = document.getElementById('sidebar');
            const mobileToggle = document.getElementById('mobileToggle');
            
            if (window.innerWidth <= 768 && 
                !sidebar.contains(event.target) && 
                !mobileToggle.contains(event.target) &&
                sidebar.classList.contains('active')) {
                sidebar.classList.remove('active');
                document.getElementById('sidebarOverlay').classList.remove('active');
            }
        });

        // Add smooth scrolling for better UX
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                document.querySelector(this.getAttribute('href')).scrollIntoView({
                    behavior: 'smooth'
                });
            });
        });
    </script>
</body>
</html>
