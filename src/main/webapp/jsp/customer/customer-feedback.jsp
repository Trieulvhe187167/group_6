<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Submit Feedback</title>
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

        /* Feedback Form */
        .feedback-form-container {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            max-width: 800px;
            margin: 0 auto;
        }

        .form-group {
            margin-bottom: 30px;
        }

        .form-group label {
            display: block;
            margin-bottom: 10px;
            font-weight: 600;
            color: #495057;
            font-size: 1.1rem;
        }

        .form-control {
            width: 100%;
            padding: 15px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .rating-section {
            margin-bottom: 30px;
        }

        .rating-stars {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }

        .star {
            font-size: 2rem;
            color: #ddd;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .star:hover,
        .star.active {
            color: #ffc107;
        }

        .star.filled {
            color: #ffc107;
        }

        .rating-text {
            margin-top: 10px;
            font-weight: 600;
            color: #495057;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            padding: 15px 30px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            font-size: 1rem;
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

        .btn-secondary {
            background: linear-gradient(135deg, #6c757d, #495057);
            color: white;
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(108, 117, 125, 0.3);
            color: white;
        }

        .btn i {
            margin-right: 8px;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            border: none;
        }

        .alert-success {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
        }

        .alert-danger {
            background: linear-gradient(135deg, #dc3545, #c82333);
            color: white;
        }

        .reservation-info {
            background: rgba(102, 126, 234, 0.05);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            border-left: 4px solid #667eea;
        }

        .reservation-info h5 {
            color: #495057;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .info-item {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }

        .info-item i {
            color: #667eea;
            margin-right: 10px;
            width: 20px;
        }

        .info-label {
            font-weight: 600;
            color: #495057;
            margin-right: 8px;
        }

        .info-value {
            color: #6c757d;
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

            .feedback-form-container {
                padding: 25px 20px;
            }

            .content-header {
                padding: 25px 20px;
            }

            .content-header h2 {
                font-size: 1.6rem;
            }

            .rating-stars {
                justify-content: center;
            }

            .star {
                font-size: 1.8rem;
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
                    <a href="${pageContext.request.contextPath}/customer/your-feedback" class="active">
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
                <h2><i class="fas fa-star"></i> Submit Feedback</h2>
                <p>Share your experience and help us improve our services</p>
            </div>

            <!-- Success/Error Messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> ${success}
                </div>
            </c:if>
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle"></i> ${error}
                </div>
            </c:if>

            <div class="feedback-form-container">
                <c:choose>
                    <c:when test="${empty reservations}">
                        <div style="text-align: center; padding: 40px;">
                            <i class="fas fa-clipboard-list" style="font-size: 4rem; color: #667eea; margin-bottom: 20px;"></i>
                            <h3 style="color: #495057; margin-bottom: 15px;">No Bookings Available for Feedback</h3>
                            <p style="color: #6c757d; margin-bottom: 25px;">
                                You don't have any completed bookings that need feedback yet. 
                                Complete a booking and check back here to share your experience!
                            </p>
                            <a href="${pageContext.request.contextPath}/customer/your-feedback" class="btn btn-primary">
                                <i class="fas fa-arrow-left"></i> Back to My Feedback
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <form method="post" action="${pageContext.request.contextPath}/customer/feedback">
                            <input type="hidden" name="action" value="submit">
                            
                            <div class="form-group">
                                <label for="reservationId">
                                    <i class="fas fa-calendar-check"></i> Select Booking to Rate:
                                </label>
                                <select name="reservationId" id="reservationId" class="form-control" required>
                                    <option value="">Choose a completed booking...</option>
                                    <c:forEach var="reservation" items="${reservations}">
                                        <option value="${reservation.id}" ${selectedId == reservation.id ? 'selected' : ''}>
                                            Booking #${reservation.id} - Room ${reservation.roomNumber} 
                                            (<fmt:formatDate value="${reservation.checkIn}" pattern="dd/MM/yyyy"/> - 
                                            <fmt:formatDate value="${reservation.checkOut}" pattern="dd/MM/yyyy"/>)
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="form-group">
                                <label>
                                    <i class="fas fa-star"></i> Your Rating:
                                </label>
                                <div class="rating-section">
                                    <div class="rating-stars" id="ratingStars">
                                        <i class="star fas fa-star" data-rating="1"></i>
                                        <i class="star fas fa-star" data-rating="2"></i>
                                        <i class="star fas fa-star" data-rating="3"></i>
                                        <i class="star fas fa-star" data-rating="4"></i>
                                        <i class="star fas fa-star" data-rating="5"></i>
                                    </div>
                                    <div class="rating-text" id="ratingText">Click on a star to rate</div>
                                    <input type="hidden" name="rating" id="ratingInput" required>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="comment">
                                    <i class="fas fa-comment-dots"></i> Your Feedback (minimum 5 characters):
                                </label>
                                <textarea name="comment" id="comment" class="form-control" rows="6" 
                                          placeholder="Please share your experience with us. What did you like? What could we improve? (minimum 5 characters)" 
                                          required minlength="5"></textarea>
                            </div>

                            <div style="display: flex; gap: 15px; justify-content: center;">
                                <a href="${pageContext.request.contextPath}/customer/your-feedback" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Cancel
                                </a>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-paper-plane"></i> Submit Feedback
                                </button>
                            </div>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
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
        // Rating functionality
        const stars = document.querySelectorAll('.star');
        const ratingText = document.getElementById('ratingText');
        const ratingInput = document.getElementById('ratingInput');
        const ratingMessages = [
            'Click on a star to rate',
            'Poor - 1 star',
            'Fair - 2 stars',
            'Good - 3 stars',
            'Very Good - 4 stars',
            'Excellent - 5 stars'
        ];

        stars.forEach(star => {
            star.addEventListener('click', function() {
                const rating = this.getAttribute('data-rating');
                setRating(rating);
            });

            star.addEventListener('mouseenter', function() {
                const rating = this.getAttribute('data-rating');
                highlightStars(rating);
                ratingText.textContent = ratingMessages[rating];
            });

            star.addEventListener('mouseleave', function() {
                const currentRating = ratingInput.value || 0;
                highlightStars(currentRating);
                ratingText.textContent = currentRating > 0 ? ratingMessages[currentRating] : ratingMessages[0];
            });
        });

        function setRating(rating) {
            ratingInput.value = rating;
            highlightStars(rating);
            ratingText.textContent = ratingMessages[rating];
        }

        function highlightStars(rating) {
            stars.forEach((star, index) => {
                if (index < rating) {
                    star.classList.add('filled');
                } else {
                    star.classList.remove('filled');
                }
            });
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

        // Form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const rating = document.getElementById('ratingInput').value;
            const comment = document.getElementById('comment').value.trim();
            
            if (!rating) {
                e.preventDefault();
                alert('Please select a rating before submitting.');
                return;
            }
            
            if (comment.length < 5) {
                e.preventDefault();
                alert('Please provide a more detailed feedback comment (at least 5 characters).');
                return;
            }
        });
    </script>
</body>
</html>
