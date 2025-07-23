<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <!-- META -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="keywords" content="" />
        <meta name="author" content="" />
        <meta name="robots" content="" />
        <meta name="description" content="Events - Luxury Hotel" />
        <meta property="og:title" content="Events - Luxury Hotel" />
        <meta property="og:description" content="Discover our upcoming events and activities" />
        <meta property="og:image" content="" />
        <meta name="format-detection" content="telephone=no">
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />
        <title>Events - Luxury Hotel</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- All PLUGINS CSS -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/assets.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/vendors/typography.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">

        
        <style>
            
            .event-card {
                border: none;
                border-radius: 15px;
                overflow: hidden;
                box-shadow: 0 5px 20px rgba(0,0,0,0.1);
                transition: all 0.3s ease;
                height: 100%;
                background: white;
            }
            .event-card:hover {
                transform: translateY(-10px);
                box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            }
            .event-image {
                width: 100%;
                height: 250px;
                object-fit: cover;
                position: relative;
            }
            .event-date-badge {
                position: absolute;
                top: 20px;
                left: 20px;
                background: rgba(255,255,255,0.95);
                padding: 10px 15px;
                border-radius: 10px;
                text-align: center;
                box-shadow: 0 3px 10px rgba(0,0,0,0.2);
            }
            .event-date-badge .date-day {
                font-size: 24px;
                font-weight: bold;
                color: #5a2b81;
                line-height: 1;
            }
            .event-date-badge .date-month {
                font-size: 14px;
                text-transform: uppercase;
                color: #666;
            }
            .event-status {
                position: absolute;
                top: 20px;
                right: 20px;
                padding: 5px 15px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 600;
                text-transform: uppercase;
            }
            .status-upcoming {
                background: #17a2b8;
                color: white;
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
            .event-content {
                padding: 25px;
            }
            .event-title {
                font-size: 22px;
                margin-bottom: 15px;
                color: #333;
                font-weight: 600;
                line-height: 1.3;
            }
            .event-info {
                margin-bottom: 10px;
                color: #666;
                font-size: 14px;
            }
            .event-info i {
                width: 20px;
                color: #5a2b81;
                margin-right: 8px;
            }
            .event-description {
                color: #777;
                font-size: 15px;
                line-height: 1.6;
                margin: 15px 0;
                display: -webkit-box;
                -webkit-line-clamp: 3;
                -webkit-box-orient: vertical;
                overflow: hidden;
            }
            .event-footer {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-top: 20px;
                padding-top: 20px;
                border-top: 1px solid #eee;
            }
            .event-duration {
                font-size: 13px;
                color: #999;
            }
            .filter-tabs {
                display: flex;
                justify-content: center;
                margin-bottom: 40px;
                flex-wrap: wrap;
                gap: 10px;
            }
            .filter-tab {
                padding: 10px 25px;
                border: 2px solid #5a2b81;
                background: white;
                color: #5a2b81;
                border-radius: 30px;
                cursor: pointer;
                transition: all 0.3s;
                font-weight: 500;
            }
            .filter-tab:hover,
            .filter-tab.active {
                background: #5a2b81;
                color: white;
            }
            .search-event-box {
                max-width: 600px;
                margin: 0 auto 40px;
            }
            .no-events {
                text-align: center;
                padding: 60px 20px;
            }
            .no-events i {
                font-size: 80px;
                color: #ddd;
                margin-bottom: 20px;
            }
            .date-filter {
                background: #f8f9fa;
                padding: 20px;
                border-radius: 10px;
                margin-bottom: 30px;
            }
            .hero-section {
                background: linear-gradient(135deg, #5a2b81 0%, #764ba2 100%);
                padding: 60px 0;
                color: white;
                margin-bottom: 50px;
            }
            .hero-section h1 {
                font-size: 48px;
                margin-bottom: 20px;
            }
            .hero-section p {
                font-size: 20px;
                opacity: 0.9;
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
    <div class="page-wraper">
        <div id="loading-icon-bx"></div>
        <!-- Header - FIXED: Added header-transparent class -->
  
                <%@ include file="header.jsp" %>
     
 

            <!-- Inner Content Box -->
            <div class="page-content bg-white">
                <!-- Page Heading -->
                <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Events & Activities</h1>
                        </div>
                         <div class="search-bar-on-banner mt-4">
                            <%@ include file="searchRoom.jsp" %>
                        </div>
                    </div>
                </div>
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                            <li>Events</li>
                        </ul>
                    </div>
                </div>

                <!-- Hero Section -->
                <div class="hero-section">
                    <div class="container text-center">
                        <h1 class="wow fadeInUp" data-wow-delay="0.1s">Discover Amazing Events</h1>
                        <p class="wow fadeInUp" data-wow-delay="0.2s">
                            Join us for exclusive experiences, workshops, and celebrations at Luxury Hotel
                        </p>
                    </div>
                </div>

                <!-- Events Content -->
                <div class="content-block">
                    <div class="section-area section-sp1">
                        <div class="container">
                            <!-- Search Box -->
                            <div class="search-event-box wow fadeInUp" data-wow-delay="0.3s">
                                <form action="${pageContext.request.contextPath}/events" method="get">
                                    <input type="hidden" name="action" value="search">
                                    <div class="input-group input-group-lg">
                                        <input type="text" name="q" class="form-control" 
                                               placeholder="Search events by title, location..." 
                                               value="${param.q}">
                                        <div class="input-group-append">
                                            <button class="btn btn-primary" type="submit">
                                                <i class="fa fa-search"></i> Search Events
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                            
                            <!-- Filter Tabs -->
                            <div class="filter-tabs wow fadeInUp" data-wow-delay="0.4s">
                                <button class="filter-tab ${empty param.status || param.status == 'all' ? 'active' : ''}" 
                                        onclick="filterEvents('all')">All Events</button>
                                <button class="filter-tab ${param.status == 'upcoming' ? 'active' : ''}" 
                                        onclick="filterEvents('upcoming')">Upcoming</button>
                                <button class="filter-tab ${param.status == 'ongoing' ? 'active' : ''}" 
                                        onclick="filterEvents('ongoing')">Ongoing</button>
                                <button class="filter-tab ${param.status == 'past' ? 'active' : ''}" 
                                        onclick="filterEvents('past')">Past Events</button>
                            </div>
                            
                            <!-- Search Results Message -->
                            <c:if test="${not empty param.q}">
                                <div class="alert alert-info">
                                    <c:choose>
                                        <c:when test="${not empty events}">
                                            Found ${events.size()} event(s) for "<strong>${param.q}</strong>"
                                        </c:when>
                                        <c:otherwise>
                                            No events found for "<strong>${param.q}</strong>"
                                        </c:otherwise>
                                    </c:choose>
                                                                                        <a href="${pageContext.request.contextPath}/events" class="float-right">Clear search</a>
                                </div>
                            </c:if>
                            
                            <!-- Events Grid -->
                            <div class="row">
                                <c:forEach var="event" items="${events}" varStatus="status">
                                    <div class="col-lg-4 col-md-6 m-b40 wow fadeInUp" data-wow-delay="0.${status.index + 1}s">
                                        <div class="event-card">
                                            <div class="event-image-wrapper" style="position: relative;">
                                                <c:choose>
                                                    <c:when test="${not empty event.imageUrl}">
                                                        <img src="${pageContext.request.contextPath}/assets/images/uploads/events/${event.imageUrl}"
                                                             alt="${event.title}" class="event-image" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="${pageContext.request.contextPath}/assets/images/event/default-event.jpg"
                                                             alt="${event.title}" class="event-image" />
                                                    </c:otherwise>
                                                </c:choose>
                                                
                                                <!-- Date Badge -->
                                                <div class="event-date-badge">
                                                    <div class="date-day">
                                                        <fmt:formatDate value="${event.startAt}" pattern="dd"/>
                                                    </div>
                                                    <div class="date-month">
                                                        <fmt:formatDate value="${event.startAt}" pattern="MMM"/>
                                                    </div>
                                                </div>
                                                
                                                <!-- Status Badge -->
                                                <c:choose>
                                                    <c:when test="${event.status == 'SCHEDULED'}">
                                                        <span class="event-status status-upcoming">Upcoming</span>
                                                    </c:when>
                                                    <c:when test="${event.status == 'ONGOING'}">
                                                        <span class="event-status status-ongoing">Ongoing</span>
                                                    </c:when>
                                                    <c:when test="${event.status == 'COMPLETED'}">
                                                        <span class="event-status status-completed">Completed</span>
                                                    </c:when>
                                                    <c:when test="${event.status == 'CANCELLED'}">
                                                        <span class="event-status status-cancelled">Cancelled</span>
                                                    </c:when>
                                                </c:choose>
                                            </div>
                                            
                                            <div class="event-content">
                                                <h4 class="event-title">
                                                    <a href="${pageContext.request.contextPath}/event/detail/${event.id}">
                                                        ${event.title}
                                                    </a>
                                                </h4>
                                                
                                                <div class="event-info">
                                                    <i class="fa fa-clock"></i>
                                                    <fmt:formatDate value="${event.startAt}" pattern="h:mm a"/> - 
                                                    <fmt:formatDate value="${event.endAt}" pattern="h:mm a"/>
                                                </div>
                                                
                                                <c:if test="${not empty event.location}">
                                                    <div class="event-info">
                                                        <i class="fa fa-map-marker-alt"></i>
                                                        ${event.location}
                                                    </div>
                                                </c:if>
                                                
                                                <c:if test="${not empty event.description}">
                                                    <div class="event-description">
                                                        ${fn:substring(fn:replace(event.description, '<[^>]*>', ''), 0, 150)}...
                                                    </div>
                                                </c:if>
                                                
                                                <div class="event-footer">
                                                    <span class="event-duration">
                                                        <c:set var="duration" value="${(event.endAt.time - event.startAt.time) / (1000 * 60)}" />
                                                        <c:choose>
                                                            <c:when test="${duration < 60}">
                                                                ${duration} mins
                                                            </c:when>
                                                            <c:when test="${duration < 1440}">
                                                                <fmt:formatNumber value="${duration / 60}" maxFractionDigits="1"/> hours
                                                            </c:when>
                                                            <c:otherwise>
                                                                <fmt:formatNumber value="${duration / 1440}" maxFractionDigits="1"/> days
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <a href="${pageContext.request.contextPath}/event/detail/${event.id}"
                                                       class="btn btn-sm btn-primary">
                                                        View Details <i class="fa fa-arrow-right"></i>
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <!-- No events message -->
                            <c:if test="${empty events}">
                                <div class="no-events">
                                    <i class="fa fa-calendar-times"></i>
                                    <h3>No events found</h3>
                                    <p class="text-muted">Check back later for upcoming events!</p>
                                    <a href="${pageContext.request.contextPath}/events" class="btn btn-primary mt-3">
                                        View All Events
                                    </a>
                                </div>
                            </c:if>

                            <!-- Pagination -->
                            <c:if test="${totalPages > 1}">
                                <div class="pagination-bx rounded-sm gray clearfix">
                                    <ul class="pagination justify-content-center">
                                        <c:if test="${currentPage > 1}">
                                            <li class="previous">
                                                <a href="?page=${currentPage - 1}<c:if test="${not empty param.q}">&q=${param.q}</c:if><c:if test="${not empty param.status}">&status=${param.status}</c:if>">
                                                    <i class="ti-arrow-left"></i> Prev
                                                </a>
                                            </li>
                                        </c:if>
                                        
                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                            <li class="${i == currentPage ? 'active' : ''}">
                                                <a href="?page=${i}<c:if test="${not empty param.q}">&q=${param.q}</c:if><c:if test="${not empty param.status}">&status=${param.status}</c:if>">${i}</a>
                                            </li>
                                        </c:forEach>
                                        
                                        <c:if test="${currentPage < totalPages}">
                                            <li class="next">
                                                <a href="?page=${currentPage + 1}<c:if test="${not empty param.q}">&q=${param.q}</c:if><c:if test="${not empty param.status}">&status=${param.status}</c:if>">
                                                    Next <i class="ti-arrow-right"></i>
                                                </a>
                                            </li>
                                        </c:if>
                                    </ul>
                                </div>
                            </c:if>
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
            // Initialize WOW.js if it exists
            if (typeof WOW !== 'undefined') {
                new WOW().init();
            }
            
            // Filter events function
            function filterEvents(status) {
                var url = '${pageContext.request.contextPath}/events';
                if (status !== 'all') {
                    url += '?status=' + status;
                }
                window.location.href = url;
            }
            
            // Fix sticky header issue
            $(document).ready(function() {
                // Function to handle sticky header
                var handleStickyHeader = function() {
                    var header = $('.sticky-header');
                    var scrollTop = $(window).scrollTop();
                    
                    if (scrollTop > 100) {
                        header.addClass('is-fixed');
                    } else {
                        header.removeClass('is-fixed');
                    }
                };
                
                // Bind scroll event
                $(window).on('scroll', function() {
                    handleStickyHeader();
                });
                
                // Run on page load
                handleStickyHeader();
                
                // Trigger scroll event after page fully loads
                $(window).on('load', function() {
                    $(window).trigger('scroll');
                });
                
                // Fallback: ensure it runs after other scripts
                setTimeout(function() {
                    handleStickyHeader();
                    $(window).trigger('scroll');
                }, 1000);
            });
        </script>
    </body>
</html>