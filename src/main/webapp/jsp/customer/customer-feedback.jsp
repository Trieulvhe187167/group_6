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
    <title>Customer Feedback</title>
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
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            width: 100%;
        }

        .content-header {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            position: relative;
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

        .back-button {
            position: absolute;
            top: 20px;
            right: 20px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 25px;
            padding: 10px 20px;
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

        .back-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
            color: white;
            text-decoration: none;
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

        .form-group {
            margin-bottom: 25px;
            width: 100%;
        }
        /* Make select booking full width and readable */
        #reservationId.form-control {
            width: 100% !important;
            min-width: 400px;
            font-size: 1.1rem;
            padding: 14px 18px;
            box-sizing: border-box;
            white-space: normal;
            overflow: visible;
            line-height: 1.5;
        }
        #reservationId.form-control option {
            white-space: normal;
            font-size: 1.1rem;
            line-height: 1.5;
            overflow: visible;
        }

        /* Make rating groups inline and stars aligned horizontally */
        .rating-group {
            display: flex;
            align-items: center;
            gap: 20px;
            margin-bottom: 15px;
            padding: 10px 0;
            flex-direction: row;
        }
        .rating-group label {
            min-width: 120px;
            margin-bottom: 0;
        }
        .star-rating {
            display: flex;
            flex-direction: row;
            gap: 5px;
        }
        .selected-rating {
            margin-left: 10px;
            font-weight: 500;
            color: #495057;
        }

        .form-label {
            display: flex;
            align-items: center;
            font-weight: 600;
            color: #495057;
            margin-bottom: 10px;
            font-size: 1rem;
        }

        .form-label i {
            margin-right: 8px;
            color: #667eea;
            width: 20px;
        }

        .form-control, .form-select {
            padding: 12px 15px;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: white;
        }

        .form-control:focus, .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
            outline: none;
        }

        .rating-section {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 25px;
            border: 1px solid rgba(102, 126, 234, 0.1);
        }

        .rating-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: #495057;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
        }

        .rating-title i {
            margin-right: 10px;
            color: #667eea;
        }

        .rating-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding: 10px 0;
        }

        .rating-group:last-child {
            margin-bottom: 0;
        }

        .rating-label {
            font-weight: 500;
            color: #495057;
            min-width: 150px;
        }

        .star-rating {
            display: flex;
            gap: 5px;
        }

        .star {
            font-size: 1.5rem;
            color: #ddd;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .star:hover {
            color: #ffc107;
            transform: scale(1.1);
        }

        .star.active {
            color: #ffc107;
        }

        .form-check {
            margin-bottom: 10px;
        }

        .form-check-input {
            margin-right: 10px;
        }

        .form-check-label {
            color: #495057;
            font-weight: 500;
        }

        .character-count {
            text-align: right;
            font-size: 0.9rem;
            color: #6c757d;
            margin-top: 5px;
        }

        .form-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }

        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            font-size: 1rem;
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

        .btn-secondary {
            background: linear-gradient(135deg, #6c757d, #5a6268);
            color: white;
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(108, 117, 125, 0.3);
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            body {
                padding: 10px;
            }

            .container {
                max-width: 100%;
            }

            .content-header {
                padding: 25px 20px;
                text-align: center;
            }

            .content-header h2 {
                font-size: 1.6rem;
            }

            .back-button {
                position: static;
                margin-top: 15px;
                width: 100%;
                justify-content: center;
            }

            .feedback-card {
                padding: 25px 20px;
            }

            .rating-group {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .rating-label {
                min-width: auto;
            }

            .form-buttons {
                flex-direction: column;
                align-items: center;
            }

            .btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const reservationId = urlParams.get('id');
        window.reservationId = reservationId;
    </script>
</head>
<body>
    <!-- Đặt selectedId từ URL -->
<c:set var="selectedId" value="${param.id}" />

<div class="container">
    <div class="content-header">
        <h2><i class="fas fa-comments"></i> Customer Feedback</h2>
        <p>Share your experience and help us improve our service</p>
        <a href="${pageContext.request.contextPath}/customer/feedback?action=list" class="back-button">
            <i class="fas fa-arrow-left"></i> Back to Booking History
        </a>
    </div>

    <!-- Success Message -->
    <div class="alert alert-success" id="successAlert" style="display: none;">
        <i class="fas fa-check-circle"></i> Thank you for your feedback! We appreciate your input.
    </div>

    <c:if test="${not empty param.success}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i> Thank you for your feedback! We appreciate your input.
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle"></i> ${error}
        </div>
    </c:if>

    <div class="feedback-card">
        <form id="feedbackForm" method="post" action="${pageContext.request.contextPath}/customer/feedback">
            <input type="hidden" name="action" value="submit" />
            <input type="hidden" id="averageRating" name="rating" value="0">

            <!-- Booking Selection -->
            <div class="form-group">
                <label class="form-label" for="reservationId">
                    <i class="fas fa-bed"></i> Select Booking
                </label>
                <c:choose>
                    <c:when test="${not empty selectedId}">
                        <c:forEach var="r" items="${reservations}">
                            <c:if test="${r.id == selectedId}">
                                <div class="form-control" style="background:#f8f9fa;pointer-events:none;">Room ${r.roomNumber} (${r.checkIn} - ${r.checkOut})</div>
                                <input type="hidden" name="reservationId" value="${r.id}" />
                            </c:if>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <select id="reservationId" name="reservationId" class="form-control" required>
                            <option value="">Select a booking...</option>
                            <c:forEach var="r" items="${reservations}">
                                <option value="${r.id}" <c:if test="${selectedId == r.id}">selected</c:if>>
                                    Room ${r.roomNumber} (${r.checkIn} - ${r.checkOut})
                                </option>
                            </c:forEach>
                        </select>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Rating Section -->
           <div class="rating-section">
    <h3 class="rating-title"><i class="fas fa-star"></i> Rate Your Experience</h3>

    <div class="rating-group" data-category="cleanliness">
        <label>Cleanliness:</label>
        <div class="star-rating">
            <span class="star" data-value="1" title="Very Poor">★</span>
            <span class="star" data-value="2" title="Poor">★</span>
            <span class="star" data-value="3" title="Average">★</span>
            <span class="star" data-value="4" title="Good">★</span>
            <span class="star" data-value="5" title="Excellent">★</span>
        </div>
        <span class="selected-rating"></span>
    </div>

    <div class="rating-group" data-category="service">
        <label>Service:</label>
        <div class="star-rating">
            <span class="star" data-value="1">★</span>
            <span class="star" data-value="2">★</span>
            <span class="star" data-value="3">★</span>
            <span class="star" data-value="4">★</span>
            <span class="star" data-value="5">★</span>
        </div>
        <span class="selected-rating"></span>
    </div>

    <div class="rating-group" data-category="comfort">
        <label>Comfort:</label>
        <div class="star-rating">
            <span class="star" data-value="1">★</span>
            <span class="star" data-value="2">★</span>
            <span class="star" data-value="3">★</span>
            <span class="star" data-value="4">★</span>
            <span class="star" data-value="5">★</span>
        </div>
        <span class="selected-rating"></span>
    </div>

    <div class="rating-group" data-category="location">
        <label>Location:</label>
        <div class="star-rating">
            <span class="star" data-value="1">★</span>
            <span class="star" data-value="2">★</span>
            <span class="star" data-value="3">★</span>
            <span class="star" data-value="4">★</span>
            <span class="star" data-value="5">★</span>
        </div>
        <span class="selected-rating"></span>
    </div>

    <div class="rating-group" data-category="value">
        <label>Value for Money:</label>
        <div class="star-rating">
            <span class="star" data-value="1">★</span>
            <span class="star" data-value="2">★</span>
            <span class="star" data-value="3">★</span>
            <span class="star" data-value="4">★</span>
            <span class="star" data-value="5">★</span>
        </div>
        <span class="selected-rating"></span>
    </div>

    <!-- Hidden input to store average rating -->
    <input type="hidden" id="averageRating" name="rating" value="0">
</div>

            <!-- Comment -->
            <div class="form-group">
                <label class="form-label">
                    <i class="fas fa-comment-alt"></i> Feedback
                </label>
                <textarea name="comment" id="feedbackMessage" class="form-control" rows="6" maxlength="1000" placeholder="Write your feedback..." required></textarea>
                <div class="character-count">
                    <span id="charCount">0</span>/1000 characters
                </div>
            </div>

            <!-- Buttons -->
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
</div>


    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    // Star Rating Handler
   document.querySelectorAll('.star-rating .star').forEach(star => {
    star.addEventListener('click', function () {
        const group = this.closest('.rating-group');
        const stars = group.querySelectorAll('.star');
        const value = parseInt(this.dataset.value);

        // Highlight selected stars
        stars.forEach((s, index) => {
            s.classList.toggle('selected', index < value);
        });

        // Store rating value in group
        group.setAttribute('data-selected', value);

        // Show selected value
        const selectedRating = group.querySelector('.selected-rating');
        if (selectedRating) {
            selectedRating.textContent = value + '/5';
        }

        // Update average rating
        updateAverageRating();
    });
});

function updateAverageRating() {
    const groups = document.querySelectorAll('.rating-group');
    let total = 0, count = 0;

    groups.forEach(group => {
        const rating = parseInt(group.getAttribute('data-selected') || 0);
        if (rating > 0) {
            total += rating;
            count++;
        }
    });

    const avg = count > 0 ? (total / count).toFixed(1) : 0;
    document.getElementById('averageRating').value = avg;
}

    // Character Counter
    const messageTextarea = document.getElementById('feedbackMessage');
    const charCount = document.getElementById('charCount');
    messageTextarea.addEventListener('input', function () {
        const count = this.value.length;
        charCount.textContent = count;
        charCount.style.color = count > 900 ? '#dc3545' : count > 750 ? '#ffc107' : '#6c757d';
    });

    // Reset function
    function resetForm() {
        document.getElementById('feedbackForm').reset();
        document.getElementById('averageRating').value = '0';
        document.querySelectorAll('.star').forEach(star => {
            star.classList.remove('active');
            star.style.color = '#ddd';
        });
        document.getElementById('charCount').textContent = '0';
        document.getElementById('charCount').style.color = '#6c757d';
        document.getElementById('successAlert').style.display = 'none';
    }
</script>
<script>
    function setupRatingStars() {
        const ratingSections = document.querySelectorAll('.star-rating');
        ratingSections.forEach(section => {
            const stars = section.querySelectorAll('.star');
            stars.forEach(star => {
                star.addEventListener('click', () => {
                    const value = parseInt(star.getAttribute('data-value'));
                    section.setAttribute('data-rating', value);
                    stars.forEach((s, index) => {
                        s.classList.toggle('selected', index < value);
                    });
                });
            });
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        setupRatingStars();
    });
</script>

<style>
    .star {
        font-size: 2rem;
        color: #ccc;
        cursor: pointer;
    }

    .star.selected {
        color: gold;
    }
</style>
</body>
</html>
