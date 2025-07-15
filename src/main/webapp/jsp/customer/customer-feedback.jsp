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
        .feedback-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            padding: 30px;
            margin-bottom: 25px;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .feedback-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
        }
        </style>
        <script>
    const urlParams = new URLSearchParams(window.location.search);
    const reservationId = urlParams.get('id');
    window.reservationId = reservationId;
</script>

</head>
<body>
     <!-- Mobile Toggle Button -->
    <button class="mobile-toggle" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </button>

    <!-- Sidebar Overlay -->
    
    <main class="main-content">
        <div class="content-header">
            <h2><i class="fas fa-comments"></i> Customer Feedback</h2>
            <p>Share your experience and help us improve our service</p>
        </div>

        <!-- Success Message -->
        <div class="alert alert-success" id="successAlert" style="display: none;">
            <i class="fas fa-check-circle"></i> Thank you for your feedback! We appreciate your input.
        </div>

        <div class="feedback-card">
            <form id="feedbackForm">
                <!-- Booking Selection -->
                <div class="form-group">
                    <label class="form-label">
                        <i class="fas fa-bed"></i>
                        Select Booking
                    </label>
                    <c:forEach var="booking" items="${completedBookings}">
    <option value="${booking.id}" ${booking.id == param.id ? 'selected' : ''}>
        Room ${booking.roomName} - ${booking.roomTypeName}
        (<fmt:formatDate value="${booking.checkIn}" pattern="MMM dd" /> -
        <fmt:formatDate value="${booking.checkOut}" pattern="MMM dd, yyyy" />)
    </option>
</c:forEach>

                </div>

                <!-- Rating Section -->
                <div class="rating-section">
                    <div class="rating-title">
                        <i class="fas fa-star"></i>
                        Rate Your Experience
                    </div>
                    
                    <div class="rating-group">
                        <div class="rating-label">Overall Experience</div>
                        <div class="star-rating" data-rating="overall">
                            <span class="star" data-value="1">★</span>
                            <span class="star" data-value="2">★</span>
                            <span class="star" data-value="3">★</span>
                            <span class="star" data-value="4">★</span>
                            <span class="star" data-value="5">★</span>
                        </div>
                    </div>

                    <div class="rating-group">
                        <div class="rating-label">Room Quality</div>
                        <div class="star-rating" data-rating="room">
                            <span class="star" data-value="1">★</span>
                            <span class="star" data-value="2">★</span>
                            <span class="star" data-value="3">★</span>
                            <span class="star" data-value="4">★</span>
                            <span class="star" data-value="5">★</span>
                        </div>
                    </div>

                    <div class="rating-group">
                        <div class="rating-label">Staff Service</div>
                        <div class="star-rating" data-rating="service">
                            <span class="star" data-value="1">★</span>
                            <span class="star" data-value="2">★</span>
                            <span class="star" data-value="3">★</span>
                            <span class="star" data-value="4">★</span>
                            <span class="star" data-value="5">★</span>
                        </div>
                    </div>

                    <div class="rating-group">
                        <div class="rating-label">Value for Money</div>
                        <div class="star-rating" data-rating="value">
                            <span class="star" data-value="1">★</span>
                            <span class="star" data-value="2">★</span>
                            <span class="star" data-value="3">★</span>
                            <span class="star" data-value="4">★</span>
                            <span class="star" data-value="5">★</span>
                        </div>
                    </div>
                </div>

                <!-- Feedback Category -->
                <div class="form-group">
                    <label class="form-label">
                        <i class="fas fa-tags"></i>
                        Feedback Category
                    </label>
                    <select class="form-select" id="feedbackCategory" required>
                        <option value="">Select category...</option>
                        <option value="general">General Feedback</option>
                        <option value="complaint">Complaint</option>
                        <option value="compliment">Compliment</option>
                        <option value="suggestion">Suggestion</option>
                    </select>
                </div>

                <!-- Subject -->
                <div class="form-group">
                    <label class="form-label">
                        <i class="fas fa-heading"></i>
                        Subject
                    </label>
                    <input type="text" class="form-control" id="feedbackSubject" placeholder="Brief summary of your feedback" required>
                </div>

                <!-- Detailed Feedback -->
                <div class="form-group">
                    <label class="form-label">
                        <i class="fas fa-comment-alt"></i>
                        Detailed Feedback
                    </label>
                    <textarea class="form-control" id="feedbackMessage" rows="6" placeholder="Please share your detailed feedback, suggestions, or concerns..." maxlength="1000" required></textarea>
                    <div class="character-count">
                        <span id="charCount">0</span>/1000 characters
                    </div>
                </div>

                <!-- Would Recommend -->
                <div class="form-group">
                    <label class="form-label">
                        <i class="fas fa-thumbs-up"></i>
                        Would you recommend us to others?
                    </label>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="recommend" id="recommendYes" value="yes">
                        <label class="form-check-label" for="recommendYes">
                            Yes, definitely
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="recommend" id="recommendMaybe" value="maybe">
                        <label class="form-check-label" for="recommendMaybe">
                            Maybe
                        </label>
                    </div>
                    <div class="form-check">
                        <input class="form-check-input" type="radio" name="recommend" id="recommendNo" value="no">
                        <label class="form-check-label" for="recommendNo">
                            No, not likely
                        </label>
                    </div>
                </div>

                <!-- Contact Information -->
                <div class="form-group">
                    <label class="form-label">
                        <i class="fas fa-envelope"></i>
                        Contact Email (Optional)
                    </label>
                    <input type="email" class="form-control" id="contactEmail" placeholder="Your email if you want a response">
                </div>

                <!-- Form Buttons -->
                <div class="form-buttons">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-paper-plane"></i> Submit Feedback
                    </button>
                    <button type="button" class="btn btn-secondary" onclick="resetForm()">
                        <i class="fas fa-redo"></i> Reset Form
                    </button>
                </div>
            </form>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Star Rating System
        document.querySelectorAll('.star-rating').forEach(rating => {
            const stars = rating.querySelectorAll('.star');
            
            stars.forEach((star, index) => {
                star.addEventListener('click', () => {
                    const value = parseInt(star.getAttribute('data-value'));
                    const ratingType = rating.getAttribute('data-rating');
                    
                    // Update visual stars
                    stars.forEach((s, i) => {
                        if (i < value) {
                            s.classList.add('active');
                        } else {
                            s.classList.remove('active');
                        }
                    });
                    
                    // Store rating value
                    rating.setAttribute('data-selected', value);
                });
                
                star.addEventListener('mouseenter', () => {
                    const value = parseInt(star.getAttribute('data-value'));
                    stars.forEach((s, i) => {
                        if (i < value) {
                            s.style.color = '#ffc107';
                        } else {
                            s.style.color = '#ddd';
                        }
                    });
                });
            });
            
            rating.addEventListener('mouseleave', () => {
                const selected = rating.getAttribute('data-selected');
                stars.forEach((s, i) => {
                    if (selected && i < parseInt(selected)) {
                        s.style.color = '#ffc107';
                    } else {
                        s.style.color = '#ddd';
                    }
                });
            });
        });

        // Character Counter
        const messageTextarea = document.getElementById('feedbackMessage');
        const charCount = document.getElementById('charCount');

        messageTextarea.addEventListener('input', function() {
            const count = this.value.length;
            charCount.textContent = count;
            
            if (count > 900) {
                charCount.style.color = '#dc3545';
            } else if (count > 750) {
                charCount.style.color = '#ffc107';
            } else {
                charCount.style.color = '#6c757d';
            }
        });

        // Form Submission
        document.getElementById('feedbackForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Get all ratings
            const ratings = {};
            document.querySelectorAll('.star-rating').forEach(rating => {
                const type = rating.getAttribute('data-rating');
                const value = rating.getAttribute('data-selected');
                ratings[type] = value || 0;
            });

            // Validate that at least overall rating is provided
            if (!ratings.overall || ratings.overall === '0') {
                alert('Please provide an overall rating before submitting.');
                return;
            }

            // Collect form data
            const formData = {
                booking: document.getElementById('bookingSelect').value,
                category: document.getElementById('feedbackCategory').value,
                subject: document.getElementById('feedbackSubject').value,
                message: document.getElementById('feedbackMessage').value,
                recommend: document.querySelector('input[name="recommend"]:checked')?.value,
                email: document.getElementById('contactEmail').value,
                ratings: ratings
            };

            // Simulate form submission
            console.log('Feedback submitted:', formData);
            
            // Show success message
            document.getElementById('successAlert').style.display = 'block';
            
            // Scroll to top
            window.scrollTo({ top: 0, behavior: 'smooth' });
            
            // Reset form after short delay
            setTimeout(() => {
                resetForm();
            }, 2000);
        });

        function resetForm() {
            document.getElementById('feedbackForm').reset();
            
            // Reset star ratings
            document.querySelectorAll('.star-rating').forEach(rating => {
                rating.removeAttribute('data-selected');
                rating.querySelectorAll('.star').forEach(star => {
                    star.classList.remove('active');
                    star.style.color = '#ddd';
                });
            });
            
            // Reset character counter
            document.getElementById('charCount').textContent = '0';
            document.getElementById('charCount').style.color = '#6c757d';
            
            // Hide success message
            document.getElementById('successAlert').style.display = 'none';
        }
    </script>
</body>
</html>
