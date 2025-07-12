<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<!-- Bootstrap CSS -->
<link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">

<!-- jQuery (phải có trước Bootstrap JS) -->
<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>

<!-- Bootstrap JS -->
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
<!-- Bootstrap 5 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Bootstrap 5 Bundle JS (includes Popper) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
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
            padding: 0;
            position: fixed;
            height: 100vh;
            z-index: 1000;
            transition: transform 0.3s ease;
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
        }

        /* Alert Messages */
        .alert {
            padding: 15px 20px;
            margin-bottom: 20px;
            border-radius: 10px;
            border: none;
            font-weight: 500;
        }

        .alert-success {
            background: linear-gradient(135deg, #d4edda, #c3e6cb);
            color: #155724;
            border-left: 4px solid #28a745;
        }

        .alert-error {
            background: linear-gradient(135deg, #f8d7da, #f5c6cb);
            color: #721c24;
            border-left: 4px solid #dc3545;
        }

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
        }

        .booking-id {
            font-size: 0.9rem;
            color: #6c757d;
            background: #f8f9fa;
            padding: 5px 12px;
            border-radius: 20px;
        }

        .booking-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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

        .badge.confirmed {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
        }

        .badge.pending {
            background: linear-gradient(135deg, #ffc107, #fd7e14);
            color: white;
        }

        .badge.cancelled {
            background: linear-gradient(135deg, #dc3545, #e83e8c);
            color: white;
        }

        .note {
            margin-top: 20px;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
            padding: 20px;
            border-radius: 15px;
            border-left: 4px solid #667eea;
        }

        .note-title {
            font-weight: 600;
            color: #495057;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
        }

        .note-title i {
            margin-right: 8px;
            color: #667eea;
        }

        /* Action Buttons */
        .booking-actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            flex-wrap: wrap;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 25px;
            font-size: 0.9rem;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
        }

        .btn-danger {
            background: linear-gradient(135deg, #dc3545, #e83e8c);
            color: white;
        }

        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(220, 53, 69, 0.3);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #6c757d, #5a6268);
            color: white;
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(108, 117, 125, 0.3);
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

            .booking-actions {
                flex-direction: column;
            }

            .btn {
                justify-content: center;
            }

            .modal-content {
                width: 95%;
                margin: 10% auto;
            }

            .modal-body {
                padding: 20px;
            }

            .modal-actions {
                flex-direction: column;
            }
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
                    <a href="#" class="active">
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
                <div class="menu-divider"></div>
                <li>
                    <a href="user-profile.jsp">
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
                <h2><i class="fas fa-calendar-check"></i> My Bookings</h2>
                <p>Manage and view your current hotel reservations</p>
            </div>

            <!-- Alert Messages -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> ${successMessage}
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-triangle"></i> ${errorMessage}
                </div>
            </c:if>
            <c:if test="${param.cancel == 'success'}">
            <div class="alert alert-success">
             <i class="fas fa-check-circle"></i> Your booking was cancelled successfully.
             </div>
            </c:if>

            <c:if test="${param.cancel == 'failed'}">
    <div class="alert alert-error">
        <i class="fas fa-exclamation-triangle"></i> Failed to cancel booking. Please try again later.
    </div>
            </c:if>

            <c:if test="${empty bookings}">
                <div class="empty-message">
                    <div class="empty-icon">
                        <i class="fas fa-calendar-times"></i>
                    </div>
                    <div class="empty-title">No Bookings Found</div>
                    <div class="empty-text">You don't have any current bookings. Ready to plan your next stay?</div>
                </div>
            </c:if>

            <c:forEach var="booking" items="${bookings}">
    <div class="booking-card">
        <div class="booking-header">
            <div class="booking-title">
                <i class="fas fa-bed"></i> Room ${booking.roomName} - ${booking.roomTypeName}
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
                <span class="detail-label">Total Amount:</span>
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

        <!-- Action Buttons -->
        <div class="booking-actions">
            <a href="${pageContext.request.contextPath}/customer/booking-detail?id=${booking.id}" class="btn btn-primary">
                <i class="fas fa-eye"></i> View Details
            </a>

          <fmt:formatDate value="${booking.checkIn}" pattern="yyyy-MM-dd" var="checkInISO" />
<c:set var="checkInISO" value="${empty checkInISO ? 'N/A' : checkInISO}" />
<c:set var="safeRoomName" value="${empty booking.roomName ? 'Unknown' : booking.roomName}" />

<c:if test="${booking.status == 'PENDING' || booking.status == 'CONFIRMED'}">
    <button type="button" class="btn btn-danger"
            data-id="${booking.id}"
            data-room="${fn:escapeXml(safeRoomName)}"
            data-status="${booking.status}"
            data-checkin="${checkInISO}"
            onclick="openCancelModal(this)">
        <i class="fas fa-times"></i> Cancel Booking
    </button>
</c:if>

        </div>
    </div>
</c:forEach>

        </main>
    </div>

    <!-- Cancel Confirmation Modal -->
    <!-- Cancel Confirmation Modal -->
<div class="modal fade" id="confirmCancelModal" tabindex="-1" aria-labelledby="cancelModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-danger">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title" id="cancelModalLabel">Cancel Booking Confirmation</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="cancelModalMessage">Are you sure you want to cancel this booking?</p>
                
                <!-- Check-in Date Section -->
                <div id="checkInDateDiv" style="background-color: #e3f2fd; padding: 10px; border-radius: 5px; border-left: 4px solid #2196f3; margin: 15px 0;">
                    <strong>📅 Check-in Date:</strong> 
                    <span style="color: #1976d2; font-weight: bold; font-size: 1.2em;">Loading...</span>
                </div>
                
                <div id="cancelWarningText" class="alert alert-warning d-none mt-2"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <a id="confirmCancelBtn" href="#" class="btn btn-danger">Yes, Cancel Booking</a>
            </div>
        </div>
    </div>
</div>

    <script>
        // Get context path for JavaScript
        const contextPath = '${pageContext.request.contextPath}';
        
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.querySelector('.sidebar-overlay');
            
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        }

       

        // Close sidebar when clicking on overlay
        document.querySelector('.sidebar-overlay').addEventListener('click', function() {
            toggleSidebar();
        });

        // Auto-hide alerts after 5 seconds
        setTimeout(function () {
            const alerts = document.querySelectorAll('.alert:not(#cancelWarningText)');
            alerts.forEach(function (alert) {
                alert.style.opacity = '0';
                setTimeout(function () {
                    alert.style.display = 'none';
                }, 300);
            });
        }, 5000);
   function openCancelModal(button) {
    const id = button.getAttribute("data-id");
    const roomName = button.getAttribute("data-room");
    const status = button.getAttribute("data-status");
    const checkInRaw = button.getAttribute("data-checkin");

    // Debug: Log tất cả các giá trị
    console.log("=== MODAL DEBUG ===");
    console.log("ID:", id);
    console.log("Room:", roomName);
    console.log("Status:", status);
    console.log("Check-in raw:", checkInRaw);
    
    // Format ngày check-in
    let checkInDisplay = "Not available";
    
    if (checkInRaw && checkInRaw !== 'N/A' && checkInRaw !== 'null' && checkInRaw !== 'undefined') {
        console.log("Processing date:", checkInRaw);
        
        try {
            let dateObj = null;
            
            // Nếu là định dạng yyyy-mm-dd
            if (checkInRaw.includes('-')) {
                const parts = checkInRaw.split('-');
                if (parts.length === 3) {
                    const year = parseInt(parts[0]);
                    const month = parseInt(parts[1]) - 1; // Month is 0-based
                    const day = parseInt(parts[2]);
                    dateObj = new Date(year, month, day);
                }
            } else {
                // Thử parse trực tiếp
                dateObj = new Date(checkInRaw);
            }
            
            if (dateObj && !isNaN(dateObj.getTime())) {
                checkInDisplay = dateObj.toLocaleDateString('en-US', {
                    year: 'numeric',
                    month: 'short',
                    day: '2-digit'
                });
                console.log("Formatted date:", checkInDisplay);
            }
        } catch (e) {
            console.log("Date parsing failed:", e);
        }
    }
    
    console.log("Final check-in display:", checkInDisplay);

    const safeRoomName = roomName && roomName !== 'null' && roomName !== 'undefined'
        ? `"${roomName}"`
        : '(unknown room)';

    // Cập nhật message chính
    document.getElementById("cancelModalMessage").innerHTML =
        `Are you sure you want to cancel your booking for <strong>${safeRoomName}</strong>?`;

    // Cập nhật check-in date trong div riêng biệt
    const checkInDiv = document.getElementById("checkInDateDiv");
    if (checkInDiv) {
        checkInDiv.innerHTML = `
            <strong>📅 Check-in Date:</strong> 
            <span style="color: #1976d2; font-weight: bold; font-size: 1.2em;">${checkInDisplay}</span>
        `;
    }

    // Xử lý warning text
    const warningEl = document.getElementById("cancelWarningText");
    if (warningEl) {
        warningEl.classList.remove("d-none");
        
        if (status === "CONFIRMED") {
            warningEl.innerHTML = `
                <strong>⚠️ Warning:</strong> Your booking is already confirmed.<br>
                You may lose your deposit depending on how close it is to the check-in time.
            `;
            warningEl.className = "alert alert-warning mt-2";
        } else if (status === "PENDING") {
            warningEl.innerHTML = `
                <strong>📅 Note:</strong> This booking is still pending confirmation.
            `;
            warningEl.className = "alert alert-info mt-2";
        } else {
            warningEl.innerHTML = `
                <strong>ℹ️ Info:</strong> Booking status: ${status}
            `;
            warningEl.className = "alert alert-secondary mt-2";
        }
    }

    // Set href cho nút confirm
    const confirmBtn = document.getElementById("confirmCancelBtn");
    if (confirmBtn) {
        confirmBtn.href = `${contextPath}/customer/cancel-booking?id=${id}`;
    }

    // Hiển thị modal
    const modal = new bootstrap.Modal(document.getElementById('confirmCancelModal'));
    modal.show();

    console.log("=== END DEBUG ===");
}

    </script>
    <!-- Debug info - bỏ sau khi test xong -->

</body>
</html>
