<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="keywords" content="" />
    <meta name="author" content="" />
    <meta name="robots" content="" />
    <meta name="description" content="${event.title} - Luxury Hotel Event" />
    <meta property="og:title" content="${event.title} - Luxury Hotel" />
    <meta property="og:description" content="${event.description}" />
    <meta property="og:image" content="${pageContext.request.contextPath}/uploads/${event.imageUrl}" />
    <meta name="format-detection" content="telephone=no">
    <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />
    <title>${event.title} - Luxury Hotel Event</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link class="skin" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
    
    <style>
        .event-detail-header {
            background: linear-gradient(135deg, #5a2b81 0%, #764ba2 100%);
            padding: 60px 0;
            color: white;
            position: relative;
            overflow: hidden;
        }
        .event-detail-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('${pageContext.request.contextPath}/assets/images/pattern.png');
            opacity: 0.1;
        }
        .event-status-badge {
            display: inline-block;
            padding: 8px 20px;
            border-radius: 25px;
            font-size: 14px;
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 20px;
        }
        .status-upcoming {
            background: rgba(255,255,255,0.2);
            border: 2px solid white;
        }
        .status-ongoing {
            background: #ffc107;
            color: #333;
        }
        .status-completed {
            background: #28a745;
            color: white;
        }
        .status-cancelled {
            background: #6c757d;
            color: white;
        }
        .event-detail-image {
            width: 100%;
            max-height: 500px;
            object-fit: cover;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .event-info-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .event-info-item {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        .event-info-item:last-child {
            margin-bottom: 0;
            padding-bottom: 0;
            border-bottom: none;
        }
        .event-info-icon {
            width: 50px;
            height: 50px;
            background: #f8f9fa;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 20px;
            color: #5a2b81;
            font-size: 20px;
        }
        .event-info-content h5 {
            margin: 0 0 5px 0;
            color: #666;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .event-info-content p {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
            color: #333;
        }
        .register-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            margin-bottom: 30px;
        }
        .register-card h3 {
            color: white;
            margin-bottom: 15px;
        }
        .register-card p {
            margin-bottom: 20px;
            opacity: 0.9;
        }
        .countdown-timer {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin: 30px 0;
        }
        .countdown-item {
            text-align: center;
            background: rgba(255,255,255,0.1);
            padding: 15px;
            border-radius: 10px;
            min-width: 80px;
        }
        .countdown-number {
            font-size: 36px;
            font-weight: bold;
            line-height: 1;
        }
        .countdown-label {
            font-size: 12px;
            text-transform: uppercase;
            opacity: 0.8;
            margin-top: 5px;
        }
        .other-events {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 30px;
            margin-top: 30px;
        }
        .other-event-item {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s;
            border: 1px solid #eee;
        }
        .other-event-item:hover {
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transform: translateY(-3px);
        }
        .social-share {
            margin-top: 30px;
            text-align: center;
        }
        .social-share h5 {
            margin-bottom: 20px;
            color: #333;
        }
        .social-share-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
        }
        .social-share-btn {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            transition: all 0.3s;
            text-decoration: none;
        }
        .social-share-btn.facebook {
            background: #3b5998;
            color: white;
        }
        .social-share-btn.twitter {
            background: #1da1f2;
            color: white;
        }
        .social-share-btn.linkedin {
            background: #0077b5;
            color: white;
        }
        .social-share-btn.whatsapp {
            background: #25d366;
            color: white;
        }
        .social-share-btn:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        .description-content {
            font-size: 18px;
            line-height: 1.8;
            color: #555;
        }
        .event-gallery {
            margin-top: 30px;
        }
        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        .gallery-item {
            border-radius: 10px;
            overflow: hidden;
            height: 200px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .gallery-item:hover {
            transform: scale(1.05);
        }
        .gallery-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
         .page-banner {
                position: relative;
            }
            .search-bar-on-banner {
                position: absolute;
                left: 50%;
                bottom: -30px;        /* đẩy xuống mép dưới banner */
                transform: translateX(-50%);
                width: 100%;
                max-width: 1100px;
                padding-bottom: 10px;
            }
    </style>
    
</head>
    
<body id="bg">
      <%@ include file="header.jsp" %>
    <div class="page-wraper">     
        <!-- Event Details Page -->
        <div class="page-content bg-white">
             <!-- Page Heading -->
                <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Events Detail</h1>
                        </div>
                         <div class="search-bar-on-banner mt-4">
                            <%@ include file="searchRoom.jsp" %>
                        </div>
                    </div>
                </div>
  <!-- Breadcrumb -->
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/events">Events</a></li>
                        <li>${event.title}</li>
                    </ul>
                </div>
            </div>
            
            <div class="content-block">
                <div class="section-area section-sp1">
                    <div class="container">
                        <div class="row">
                            <!-- Event Main Content -->
                            <div class="col-lg-8">
                                <!-- Event Image -->
                                <c:choose>
                                    <c:when test="${not empty event.imageUrl}">
                                        <img src="${pageContext.request.contextPath}/assets/images/uploads/events/${event.imageUrl}"
                                             alt="${event.title}" class="event-detail-image mb-4" />
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/assets/images/event/default-event-large.jpg"
                                             alt="${event.title}" class="event-detail-image mb-4" />
                                    </c:otherwise>
                                </c:choose>
                                
                                <!-- Event Description -->
                                <div class="event-description-section">
                                    <h2 class="mb-4">About This Event</h2>
                                    <div class="description-content">
                                        <c:choose>
                                            <c:when test="${not empty event.description}">
                                                ${event.description}
                                            </c:when>
                                            <c:otherwise>
                                                <p>Join us for this exciting event at Luxury Hotel. More details coming soon!</p>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                
                                <!-- Social Share -->
                                <div class="social-share">
                                    <h5>Share This Event</h5>
                                    <div class="social-share-buttons">
                                        <a href="https://www.facebook.com/sharer/sharer.php?u=${pageContext.request.scheme}://${pageContext.request.serverName}${pageContext.request.contextPath}/event/detail/${event.id}" 
                                           target="_blank" class="social-share-btn facebook">
                                            <i class="fab fa-facebook-f"></i>
                                        </a>
                                        <a href="https://twitter.com/intent/tweet?text=${event.title}&url=${pageContext.request.scheme}://${pageContext.request.serverName}${pageContext.request.contextPath}/event/detail/${event.id}" 
                                           target="_blank" class="social-share-btn twitter">
                                            <i class="fab fa-twitter"></i>
                                        </a>
                                        <a href="https://www.linkedin.com/shareArticle?mini=true&url=${pageContext.request.scheme}://${pageContext.request.serverName}${pageContext.request.contextPath}/event/detail/${event.id}&title=${event.title}" 
                                           target="_blank" class="social-share-btn linkedin">
                                            <i class="fab fa-linkedin-in"></i>
                                        </a>
                                        <a href="https://wa.me/?text=${event.title} - ${pageContext.request.scheme}://${pageContext.request.serverName}${pageContext.request.contextPath}/event/detail/${event.id}" 
                                           target="_blank" class="social-share-btn whatsapp">
                                            <i class="fab fa-whatsapp"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <!-- Event Sidebar -->
                            <div class="col-lg-4">
                                <!-- Event Info Card -->
                                <div class="event-info-card">
                                    <h3 class="mb-4">Event Details</h3>
                                    
                                    <!-- Date & Time -->
                                    <div class="event-info-item">
                                        <div class="event-info-icon">
                                            <i class="fa fa-calendar-alt"></i>
                                        </div>
                                        <div class="event-info-content">
                                            <h5>Date & Time</h5>
                                            <p>
                                                <fmt:formatDate value="${event.startAt}" pattern="MMM dd, yyyy"/>
                                                <br>
                                                <fmt:formatDate value="${event.startAt}" pattern="h:mm a"/> - 
                                                <fmt:formatDate value="${event.endAt}" pattern="h:mm a"/>
                                            </p>
                                        </div>
                                    </div>
                                    
                                    <!-- Duration -->
                                    <div class="event-info-item">
                                        <div class="event-info-icon">
                                            <i class="fa fa-clock"></i>
                                        </div>
                                        <div class="event-info-content">
                                            <h5>Duration</h5>
                                            <p>
                                                <c:set var="duration" value="${(event.endAt.time - event.startAt.time) / (1000 * 60)}" />
                                                <c:choose>
                                                    <c:when test="${duration < 60}">
                                                        ${duration} minutes
                                                    </c:when>
                                                    <c:when test="${duration < 1440}">
                                                        <fmt:formatNumber value="${duration / 60}" maxFractionDigits="1"/> hours
                                                    </c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${duration / 1440}" maxFractionDigits="1"/> days
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                        </div>
                                    </div>
                                    
                                    <!-- Location -->
                                    <c:if test="${not empty event.location}">
                                        <div class="event-info-item">
                                            <div class="event-info-icon">
                                                <i class="fa fa-map-marker-alt"></i>
                                            </div>
                                            <div class="event-info-content">
                                                <h5>Location</h5>
                                                <p>${event.location}</p>
                                            </div>
                                        </div>
                                    </c:if>
                                    
                                    <!-- Status -->
                                    <div class="event-info-item">
                                        <div class="event-info-icon">
                                            <i class="fa fa-info-circle"></i>
                                        </div>
                                        <div class="event-info-content">
                                            <h5>Status</h5>
                                            <p>
                                                <c:choose>
                                                    <c:when test="${event.status == 'SCHEDULED'}">
                                                        Upcoming Event
                                                    </c:when>
                                                    <c:when test="${event.status == 'ONGOING'}">
                                                        Currently Ongoing
                                                    </c:when>
                                                    <c:when test="${event.status == 'COMPLETED'}">
                                                        Event Completed
                                                    </c:when>
                                                    <c:when test="${event.status == 'CANCELLED'}">
                                                        Event Cancelled
                                                    </c:when>
                                                </c:choose>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Registration Card (for upcoming events) -->
                                <c:if test="${event.status == 'SCHEDULED'}">
                                    <div class="register-card">
                                        <h3>Don't Miss Out!</h3>
                                        <p>Reserve your spot for this amazing event</p>
                                        
                                        <!-- Countdown Timer -->
                                        <div id="countdown" class="countdown-timer"></div>
                                        
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.user}">
                                                <button class="btn btn-white btn-lg" onclick="registerForEvent()">
                                                    <i class="fa fa-check-circle"></i> Register Now
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/jsp/login.jsp?redirect=event/detail/${event.id}" 
                                                   class="btn btn-white btn-lg">
                                                    <i class="fa fa-sign-in-alt"></i> Login to Register
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:if>
                                
                                <!-- Other Events -->
                                <div class="other-events">
                                    <h4 class="mb-3">Other Events</h4>
                                    <c:forEach var="otherEvent" items="${otherEvents}" varStatus="status">
                                        <c:if test="${status.index < 3}">
                                            <a href="${pageContext.request.contextPath}/event/detail/${otherEvent.id}" 
                                               class="other-event-item d-block text-decoration-none">
                                                <h6 class="mb-2">${otherEvent.title}</h6>
                                                <p class="mb-1 text-muted">
                                                    <i class="fa fa-calendar mr-1"></i>
                                                    <fmt:formatDate value="${otherEvent.startAt}" pattern="MMM dd, yyyy"/>
                                                </p>
                                                <c:if test="${not empty otherEvent.location}">
                                                    <p class="mb-0 text-muted">
                                                        <i class="fa fa-map-marker-alt mr-1"></i>
                                                        ${otherEvent.location}
                                                    </p>
                                                </c:if>
                                            </a>
                                        </c:if>
                                    </c:forEach>
                                    <a href="${pageContext.request.contextPath}/events" 
                                       class="btn btn-primary btn-block mt-3">
                                        View All Events
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%@ include file="footer.jsp" %>
    </div> 
    
    <!-- JS -->
    <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/magnific-popup/magnific-popup.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/counter/waypoints-min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/counter/counterup.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/imagesloaded/imagesloaded.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/masonry/masonry.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/masonry/filter.js"></script>
    <script src="${pageContext.request.contextPath}/assets/vendors/owl-carousel/owl.carousel.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/contact.js"></script>
    
    <script>
        // Countdown Timer for upcoming events
        <c:if test="${event.status == 'SCHEDULED'}">
        function startCountdown() {
            var eventDate = new Date('${event.startAt}').getTime();
            
            var countdown = setInterval(function() {
                var now = new Date().getTime();
                var distance = eventDate - now;
                
                if (distance < 0) {
                    clearInterval(countdown);
                    document.getElementById("countdown").innerHTML = "Event has started!";
                    return;
                }
                
                var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                
                var html = '';
                if (days > 0) {
                    html += '<div class="countdown-item"><div class="countdown-number">' + days + '</div><div class="countdown-label">Days</div></div>';
                }
                html += '<div class="countdown-item"><div class="countdown-number">' + hours + '</div><div class="countdown-label">Hours</div></div>';
                html += '<div class="countdown-item"><div class="countdown-number">' + minutes + '</div><div class="countdown-label">Minutes</div></div>';
                html += '<div class="countdown-item"><div class="countdown-number">' + seconds + '</div><div class="countdown-label">Seconds</div></div>';
                
                document.getElementById("countdown").innerHTML = html;
            }, 1000);
        }
        
        startCountdown();
        </c:if>
        
        // Register for event function
        function registerForEvent() {
            // You can implement actual registration logic here
            alert('Thank you for your interest! Registration feature coming soon.');
            // Or redirect to a registration form
            // window.location.href = '${pageContext.request.contextPath}/EventRegistrationServlet?eventId=${event.id}';
        }
    </script>
</body>
</html>