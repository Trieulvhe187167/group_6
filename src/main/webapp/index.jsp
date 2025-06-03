<%@ page language="java" contentType="text/html; charset=UTF-8"
         import="java.util.List, dal.RoomTypeDAO, model.RoomType, dal.EventDAO, model.Event, dal.BlogDAO, model.Blog" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    // Load RoomTypes
    RoomTypeDAO dao = new RoomTypeDAO();
    List<RoomType> roomTypes = dao.getAllRoomTypes();
    request.setAttribute("roomTypes", roomTypes);
    
    // Load Events
    List<Event> events = new EventDAO().getAllEvents();
    request.setAttribute("events", events);
    
    // Load Recent Blogs (3 newest published blogs)
    BlogDAO blogDao = new BlogDAO();
    List<Blog> recentBlogs = blogDao.getPublishedBlogs();
    if (recentBlogs.size() > 3) {
        recentBlogs = recentBlogs.subList(0, 3);
    }
    request.setAttribute("recentBlogs", recentBlogs);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>LUXURY HOTEL</title>
    <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon">
    <!-- Main CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css" class="skin">
    <!-- Vendor CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendors/revolution/css/layers.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendors/revolution/css/settings.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendors/revolution/css/navigation.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />

    <style>
        #loading-icon-bx {
            position: fixed;
            width: 100%;
            height: 100%;
            background: #fff;
            top: 0;
            left: 0;
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
        }
    </style>
</head>
<body id="bg">
    <%@ include file="/jsp/header.jsp" %>
    
    <div class="page-wraper">
        <!-- Revolution Slider -->
        <div class="rev-slider">
            <div id="rev_slider_486_1_wrapper" class="rev_slider_wrapper fullwidthbanner-container" 
                 data-alias="news-gallery36" data-source="gallery" 
                 style="margin:0px auto;background-color:#ffffff;padding:0px;margin-top:0px;margin-bottom:0px;">
                <div id="rev_slider_486_1" class="rev_slider fullwidthabanner" style="display:none;" data-version="5.3.0.2">
                    <ul>
                        <!-- SLIDE 1 -->
                        <li data-index="rs-100" 
                            data-transition="parallaxvertical" 
                            data-slotamount="default" 
                            data-hideafterloop="0" 
                            data-hideslideonmobile="off" 
                            data-easein="default" 
                            data-easeout="default" 
                            data-masterspeed="default" 
                            data-thumb="error-404.html" 
                            data-rotate="0" 
                            data-fstransition="fade" 
                            data-fsmasterspeed="1500" 
                            data-fsslotamount="7" 
                            data-saveperformance="off">
                            
                            <img src="assets/images/slider/slide1.jpg" alt="" 
                                 data-bgposition="center center" 
                                 data-bgfit="cover" 
                                 data-bgrepeat="no-repeat" 
                                 data-bgparallax="10" 
                                 class="rev-slidebg" 
                                 data-no-retina />

                            <!-- Dark Overlay -->
                            <div class="tp-caption tp-shape tp-shapewrapper" 
                                 id="slide-100-layer-1" 
                                 data-x="['center','center','center','center']" data-hoffset="['0','0','0','0']" 
                                 data-y="['middle','middle','middle','middle']" data-voffset="['0','0','0','0']" 
                                 data-width="full"
                                 data-height="full"
                                 data-whitespace="nowrap"
                                 data-type="shape" 
                                 data-basealign="slide" 
                                 data-responsive_offset="off" 
                                 data-responsive="off"
                                 data-frames='[{"from":"opacity:0;","speed":1,"to":"o:1;","delay":0,"ease":"Power4.easeOut"},{"delay":"wait","speed":1,"to":"opacity:0;","ease":"Power4.easeOut"}]'
                                 style="z-index: 5;background-color:rgba(2, 0, 11, 0.80);"> 
                            </div>
                            
                            <!-- Title -->
                            <div class="tp-caption Newspaper-Title tp-resizeme" 
                                 id="slide-100-layer-2" 
                                 data-x="['center','center','center','center']" 
                                 data-hoffset="['0','0','0','0']" 
                                 data-y="['top','top','top','top']" 
                                 data-voffset="['250','250','250','240']" 
                                 data-fontsize="['50','50','50','30']"
                                 data-lineheight="['55','55','55','35']"
                                 data-width="full"
                                 data-height="none"
                                 data-whitespace="normal"
                                 data-type="text" 
                                 data-responsive_offset="on" 
                                 data-frames='[{"from":"y:[-100%];z:0;rX:0deg;rY:0;rZ:0;sX:1;sY:1;skX:0;skY:0;","mask":"x:0px;y:0px;s:inherit;e:inherit;","speed":1500,"to":"o:1;","delay":1000,"ease":"Power3.easeInOut"},{"delay":"wait","speed":1000,"to":"auto:auto;","mask":"x:0;y:0;s:inherit;e:inherit;","ease":"Power3.easeInOut"}]'
                                 data-textAlign="['center','center','center','center']"
                                 style="z-index: 6; font-family:rubik; font-weight:700; text-align:center; white-space: normal;">
                                Welcome To Luxury Hotel
                            </div>

                            <!-- Subtitle -->
                            <div class="tp-caption Newspaper-Subtitle tp-resizeme" 
                                 id="slide-100-layer-4" 
                                 data-x="['center','center','center','center']" 
                                 data-hoffset="['0','0','0','0']" 
                                 data-y="['top','top','top','top']" 
                                 data-voffset="['320','320','320','290']" 
                                 data-width="['800','800','700','420']"
                                 data-height="['100','100','100','120']"
                                 data-whitespace="unset"
                                 data-type="text" 
                                 data-responsive_offset="on"
                                 data-frames='[{"from":"y:[-100%];z:0;rX:0deg;rY:0;rZ:0;sX:1;sY:1;skX:0;skY:0;","mask":"x:0px;y:0px;s:inherit;e:inherit;","speed":1500,"to":"o:1;","delay":1000,"ease":"Power3.easeInOut"},{"delay":"wait","speed":1000,"to":"auto:auto;","mask":"x:0;y:0;s:inherit;e:inherit;","ease":"Power3.easeInOut"}]'
                                 data-textAlign="['center','center','center','center']"
                                 style="z-index: 7; text-transform:capitalize; white-space: unset; color:#fff; font-family:rubik; font-size:18px; line-height:28px; font-weight:400;">
                                A place that offers a classy accommodation experience with perfect service and sophisticated space.
                            </div>
                            
                            <!-- Buttons -->
                            <div class="tp-caption Newspaper-Button rev-btn" 
                                 id="slide-100-layer-5" 
                                 data-x="['center','center','center','center']" 
                                 data-hoffset="['90','80','75','90']" 
                                 data-y="['top','top','top','top']" 
                                 data-voffset="['400','400','400','420']" 
                                 data-width="none"
                                 data-height="none"
                                 data-whitespace="nowrap"
                                 data-type="button" 
                                 data-responsive_offset="on" 
                                 data-responsive="off"
                                 data-actions='[{"event":"click","action":"simplelink","url":"jsp/About.jsp","target":"_self"}]'
                                 data-frames='[{"from":"y:[-100%];z:0;rX:0deg;rY:0;rZ:0;sX:1;sY:1;skX:0;skY:0;","mask":"x:0px;y:0px;","speed":1500,"to":"o:1;","delay":1000,"ease":"Power3.easeInOut"},{"delay":"wait","speed":1000,"to":"auto:auto;","mask":"x:0;y:0;","ease":"Power3.easeInOut"},{"frame":"hover","speed":"300","ease":"Power1.easeInOut","to":"o:1;rX:0;rY:0;rZ:0;z:0;","style":"c:rgba(0, 0, 0, 1.00);bg:rgba(255, 255, 255, 1.00);bc:rgba(255, 255, 255, 1.00);bw:1px 1px 1px 1px;"}]'
                                 data-textAlign="['center','center','center','center']"
                                 data-paddingtop="[12,12,12,12]"
                                 data-paddingright="[30,35,35,15]"
                                 data-paddingbottom="[12,12,12,12]"
                                 data-paddingleft="[30,35,35,15]"
                                 style="z-index: 8; white-space: nowrap; outline:none;box-shadow:none;box-sizing:border-box;-moz-box-sizing:border-box;-webkit-box-sizing:border-box;cursor:pointer; background-color:var(--primary) !important; border:0; border-radius:30px; margin-right:5px;">
                                READ MORE 
                            </div>
                            
                            <div class="tp-caption Newspaper-Button rev-btn" 
                                 id="slide-100-layer-6" 
                                 data-x="['center','center','center','center']" 
                                 data-hoffset="['-90','-80','-75','-90']" 
                                 data-y="['top','top','top','top']" 
                                 data-voffset="['400','400','400','420']" 
                                 data-width="none"
                                 data-height="none"
                                 data-whitespace="nowrap"
                                 data-type="button" 
                                 data-responsive_offset="on" 
                                 data-responsive="off"
                                 data-actions='[{"event":"click","action":"simplelink","url":"RoomListServlet","target":"_self"}]'
                                 data-frames='[{"from":"y:[-100%];z:0;rX:0deg;rY:0;rZ:0;sX:1;sY:1;skX:0;skY:0;","mask":"x:0px;y:0px;","speed":1500,"to":"o:1;","delay":1000,"ease":"Power3.easeInOut"},{"delay":"wait","speed":1000,"to":"auto:auto;","mask":"x:0;y:0;","ease":"Power3.easeInOut"},{"frame":"hover","speed":"300","ease":"Power1.easeInOut","to":"o:1;rX:0;rY:0;rZ:0;z:0;","style":"c:rgba(0, 0, 0, 1.00);bg:rgba(255, 255, 255, 1.00);bc:rgba(255, 255, 255, 1.00);bw:1px 1px 1px 1px;"}]'
                                 data-textAlign="['center','center','center','center']"
                                 data-paddingtop="[12,12,12,12]"
                                 data-paddingright="[30,35,35,15]"
                                 data-paddingbottom="[12,12,12,12]"
                                 data-paddingleft="[30,35,35,15]"
                                 style="z-index: 8; white-space: nowrap; outline:none;box-shadow:none;box-sizing:border-box;-moz-box-sizing:border-box;-webkit-box-sizing:border-box;cursor:pointer; border-radius:30px;">
                                BOOKING
                            </div>
                        </li>
                        
                        <!-- SLIDE 2 (similar structure) -->
                        <li data-index="rs-200" 
                            data-transition="parallaxvertical" 
                            data-slotamount="default" 
                            data-hideafterloop="0" 
                            data-hideslideonmobile="off" 
                            data-easein="default" 
                            data-easeout="default" 
                            data-masterspeed="default" 
                            data-thumb="assets/images/slider/slide1.jpg" 
                            data-rotate="0" 
                            data-fstransition="fade" 
                            data-fsmasterspeed="1500" 
                            data-fsslotamount="7" 
                            data-saveperformance="off">
                            
                            <img src="assets/images/slider/slide2.jpg" alt="" 
                                 data-bgposition="center center" 
                                 data-bgfit="cover" 
                                 data-bgrepeat="no-repeat" 
                                 data-bgparallax="10" 
                                 class="rev-slidebg" 
                                 data-no-retina />
                            
                            <!-- Similar layers as slide 1... -->
                        </li>
                    </ul>
                </div>
            </div>  
        </div>  

        <!-- Our Services -->
        <section class="our-services section-sp2">
            <div class="content-block">
                <div class="section-area content-inner service-info-bx">
                    <div class="container">
                        <div class="row">
                            <div class="col-lg-4 col-md-4 col-sm-6">
                                <div class="service-bx">
                                    <div class="action-box">
                                        <img src="assets/images/our-services/pic1.jpg" alt="">
                                    </div>
                                    <div class="info-bx text-center">
                                        <div class="feature-box-sm radius bg-white">
                                            <i class="fa fa-utensils text-primary"></i>
                                        </div>
                                        <h4><a href="#">Restaurant</a></h4>
                                        <p>Enjoy world-class cuisine from a 5-star chef with exquisite Asian - European dishes, served 24/7 at our luxurious restaurant.</p>
                                        <a href="#" class="btn radius-xl">View More</a>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-4 col-md-4 col-sm-6">
                                <div class="service-bx">
                                    <div class="action-box">
                                        <img src="assets/images/our-services/pic2.jpg" alt="">
                                    </div>
                                    <div class="info-bx text-center">
                                        <div class="feature-box-sm radius bg-white">
                                            <i class="fa fa-spa text-primary"></i>
                                        </div>
                                        <h4><a href="#">Spa & Wellness</a></h4>
                                        <p>Relax and rejuvenate with premium spa treatments, saunas, and professional massage services from leading brands.</p>
                                        <a href="#" class="btn radius-xl">View More</a>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-4 col-md-4 col-sm-12">
                                <div class="service-bx m-b0">
                                    <div class="action-box">
                                        <img src="assets/images/our-services/pic3.jpg" alt="">
                                    </div>
                                    <div class="info-bx text-center">
                                        <div class="feature-box-sm radius bg-white">
                                            <i class="fa fa-swimmer text-primary"></i>
                                        </div>
                                        <h4><a href="#">Infinity swimming pool</a></h4>
                                        <p>Immerse yourself in the infinity pool with stunning panoramic views, where you can relax and enjoy premium drinks.</p>
                                        <a href="#" class="btn radius-xl">View More</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Rooms Available -->
                <div class="section-area section-sp2 popular-courses-bx">
                    <div class="container">
                        <div class="row">
                            <div class="col-md-12 heading-bx left">
                                <h2 class="title-head">Rooms <span>Available</span></h2>
                            </div>
                        </div>

                        <div class="row">
                            <div class="courses-carousel owl-carousel owl-btn-1 col-12 p-lr0">
                                <c:if test="${empty roomTypes}">
                                    <p style="color:red">No room types found. Please check RoomTypes table!</p>
                                </c:if>

                                <c:forEach var="type" items="${roomTypes}">
                                    <div class="item">
                                        <div class="cours-bx">
                                            <div class="action-box">
                                                <img src="${pageContext.request.contextPath}/assets/images/uploads/${type.imageUrl}"
                                                     alt="${type.name}"
                                                     class="img-fluid" />
                                                <a href="RoomDetailServlet?id=${type.id}" class="btn">Booking Room</a>
                                            </div>

                                            <div class="info-bx text-center">
                                                <h5>
                                                    <a href="RoomDetailServlet?id=${type.id}">
                                                        RoomType: ${type.name}
                                                    </a>
                                                </h5>
                                                <span>
                                                    Capacity: ${type.capacity}
                                                    <svg xmlns="http://www.w3.org/2000/svg"
                                                         fill="none"
                                                         viewBox="0 0 24 24"
                                                         stroke-width="1.5"
                                                         stroke="currentColor"
                                                         class="size-6"
                                                         style="width:1.5em; height:1.5em; vertical-align:middle;">
                                                        <path stroke-linecap="round" stroke-linejoin="round"
                                                              d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"/>
                                                    </svg>
                                                </span>
                                            </div>

                                            <div class="cours-more-info price-row">
                                                <fmt:formatNumber value="${type.basePrice}" 
                                                                  pattern="#,##0" 
                                                                  var="rawPrice"/>
                                                <span class="price-text">${fn:replace(rawPrice, ',', '.')}₫/Night</span>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Upcoming Events -->
                <div class="upcoming-events section-sp2">
                    <div class="container">
                        <div class="row">
                            <div class="col-md-12 heading-bx left">
                                <h2 class="title-head m-b0">HOTEL LUXURY <span>Events</span></h2>
                                <p class="m-b0">Experience and use luxury services</p>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="upcoming-event-carousel owl-carousel owl-btn-center-lr owl-btn-1 col-12 p-lr0 m-b30">
                                <c:forEach var="e" items="${events}">
                                    <div class="item">
                                        <div class="event-bx">
                                            <div class="action-box">
                                                <img src="${pageContext.request.contextPath}/uploads/events/${e.imageUrl}"
                                                     alt="${e.title}" />
                                            </div>
                                            <div class="info-bx d-flex">
                                                <div>
                                                    <div class="event-time">
                                                        <div class="event-date">
                                                            <fmt:formatDate value="${e.startAt}" pattern="dd" />
                                                        </div>
                                                        <div class="event-month">
                                                            <fmt:formatDate value="${e.startAt}" pattern="MMMM" />
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="event-info">
                                                    <h4 class="event-title"><a href="#">${e.title}</a></h4>
                                                    <ul class="media-post">
                                                        <li>
                                                            <a href="#"><i class="fa fa-clock-o"></i>
                                                                <fmt:formatDate value="${e.startAt}" pattern="h:mma" />
                                                                –
                                                                <fmt:formatDate value="${e.endAt}" pattern="h:mma" />
                                                            </a>
                                                        </li>
                                                        <li>
                                                            <a href="#"><i class="fa fa-map-marker"></i> ${e.location}</a>
                                                        </li>
                                                    </ul>
                                                    <p>${e.description}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                        
                        <div class="text-center">
                            <a href="#" class="btn">View All Event</a>
                        </div>
                    </div>
                </div>

                <!-- Testimonials -->
                <div class="section-area section-sp2 bg-fix ovbl-dark" style="background-image:url(assets/images/background/bg1.jpg);">
                    <div class="container">
                        <div class="row">
                            <div class="col-md-12 text-white heading-bx left">
                                <h2 class="title-head text-uppercase">what people <span>say</span></h2>
                                <p>Hear from our satisfied guests about their experiences</p>
                            </div>
                        </div>
                        <div class="testimonial-carousel owl-carousel owl-btn-1 col-12 p-lr0">
                            <div class="item">
                                <div class="testimonial-bx">
                                    <div class="testimonial-thumb">
                                        <img src="assets/images/testimonials/pic1.jpg" alt="">
                                    </div>
                                    <div class="testimonial-info">
                                        <h5 class="name">Sarah Johnson</h5>
                                        <p>-Business Executive</p>
                                    </div>
                                    <div class="testimonial-content">
                                        <p>The Executive Suite exceeded all expectations. Perfect for business trips with excellent facilities and impeccable service. Will definitely return!</p>
                                    </div>
                                </div>
                            </div>
                            <div class="item">
                                <div class="testimonial-bx">
                                    <div class="testimonial-thumb">
                                        <img src="assets/images/testimonials/pic2.jpg" alt="">
                                    </div>
                                    <div class="testimonial-info">
                                        <h5 class="name">Michael Chen</h5>
                                        <p>-Travel Blogger</p>
                                    </div>
                                    <div class="testimonial-content">
                                        <p>Stunning views from the Penthouse! The infinity pool and spa services are world-class. A true luxury experience in the heart of the city.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent News -->
                <div class="section-area section-sp2">
                    <div class="container">
                        <div class="row">
                            <div class="col-md-12 heading-bx left">
                                <h2 class="title-head">Recent <span>News</span></h2>
                                <p>Stay updated with our latest news and insights about luxury hospitality</p>
                            </div>
                        </div>
                        
                        <div class="recent-news-carousel owl-carousel owl-btn-1 col-12 p-lr0">
                            <c:choose>
                                <c:when test="${not empty recentBlogs}">
                                    <c:forEach var="blog" items="${recentBlogs}">
                                        <div class="item">
                                            <div class="recent-news">
                                                <div class="action-box">
                                                    <c:choose>
                                                        <c:when test="${not empty blog.imageUrl}">
                                                            <img src="${pageContext.request.contextPath}/assets/images/blog/${blog.imageUrl}" 
                                                                 alt="${blog.title}" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="${pageContext.request.contextPath}/assets/images/blog/default-blog.jpg" 
                                                                 alt="${blog.title}" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="info-bx">
                                                    <ul class="media-post">
                                                        <li>
                                                            <a href="#"><i class="fa fa-calendar"></i>
                                                                <fmt:formatDate value="${blog.createdAt}" pattern="MMM dd yyyy"/>
                                                            </a>
                                                        </li>
                                                        <li>
                                                            <a href="#"><i class="fa fa-user"></i>By ${blog.authorName}</a>
                                                        </li>
                                                    </ul>
                                                    <h5 class="post-title">
                                                        <a href="${pageContext.request.contextPath}/BlogDetailServlet?id=${blog.id}">
                                                            ${blog.title}
                                                        </a>
                                                    </h5>
                                                    <p>
                                                        <c:choose>
                                                            <c:when test="${fn:length(blog.content) > 100}">
                                                                ${fn:substring(blog.content, 0, 100)}...
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${blog.content}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </p>
                                                    <div class="post-extra">
                                                        <a href="${pageContext.request.contextPath}/BlogDetailServlet?id=${blog.id}" 
                                                           class="btn-link">READ MORE</a>
                                                        <a href="#" class="comments-bx">
                                                            <i class="fa fa-comments-o"></i>${blog.commentCount} Comment
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="item">
                                        <div class="recent-news">
                                            <div class="action-box">
                                                <img src="assets/images/blog/latest-blog/pic1.jpg" alt="">
                                            </div>
                                            <div class="info-bx">
                                                <ul class="media-post">
                                                    <li><a href="#"><i class="fa fa-calendar"></i>Jan 02 2025</a></li>
                                                    <li><a href="#"><i class="fa fa-user"></i>By Admin</a></li>
                                                </ul>
                                                <h5 class="post-title">
                                                    <a href="#">Welcome to Luxury Hotel Blog</a>
                                                </h5>
                                                <p>Discover the latest updates and stories from our luxury hotel.</p>
                                                <div class="post-extra">
                                                    <a href="#" class="btn-link">READ MORE</a>
                                                    <a href="#" class="comments-bx"><i class="fa fa-comments-o"></i>0 Comment</a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <div class="text-center mt-4">
                            <a href="${pageContext.request.contextPath}/jsp/blog.jsp" class="btn">View All News</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/jsp/footer.jsp" %>
    
    <!-- JS Files -->
    <script src="assets/js/jquery.min.js"></script>
    <script src="assets/vendors/bootstrap/js/popper.min.js"></script>
    <script src="assets/vendors/bootstrap/js/bootstrap.min.js"></script>
    <script src="assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
    <script src="assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
    <script src="assets/vendors/magnific-popup/magnific-popup.js"></script>
    <script src="assets/vendors/counter/waypoints-min.js"></script>
    <script src="assets/vendors/counter/counterup.min.js"></script>
    <script src="assets/vendors/imagesloaded/imagesloaded.js"></script>
    <script src="assets/vendors/masonry/masonry.js"></script>
    <script src="assets/vendors/masonry/filter.js"></script>
    <script src="assets/vendors/owl-carousel/owl.carousel.js"></script>
    <script src="assets/js/functions.js"></script>
    <script src="assets/js/contact.js"></script>

    <!-- Revolution Slider JS -->
    <script src="assets/vendors/revolution/js/jquery.themepunch.tools.min.js"></script>
    <script src="assets/vendors/revolution/js/jquery.themepunch.revolution.min.js"></script>
    <script src="assets/vendors/revolution/js/extensions/revolution.extension.actions.min.js"></script>
    <script src="assets/vendors/revolution/js/extensions/revolution.extension.carousel.min.js"></script>
    <script src="assets/vendors/revolution/js/extensions/revolution.extension.kenburn.min.js"></script>
    <script src="assets/vendors/revolution/js/extensions/revolution.extension.layeranimation.min.js"></script>
    <script src="assets/vendors/revolution/js/extensions/revolution.extension.migration.min.js"></script>
    <script src="assets/vendors/revolution/js/extensions/revolution.extension.navigation.min.js"></script>
    <script src="assets/vendors/revolution/js/extensions/revolution.extension.parallax.min.js"></script>
    <script src="assets/vendors/revolution/js/extensions/revolution.extension.slideanims.min.js"></script>
    <script src="assets/vendors/revolution/js/extensions/revolution.extension.video.min.js"></script>
    
    <script>
        jQuery(document).ready(function () {
            var ttrevapi;
            var tpj = jQuery;
            if (tpj("#rev_slider_486_1").revolution == undefined) {
                revslider_showDoubleJqueryError("#rev_slider_486_1");
            } else {
                ttrevapi = tpj("#rev_slider_486_1").show().revolution({
                    sliderType: "standard",
                    jsFileLocation: "assets/vendors/revolution/js/",
                    sliderLayout: "fullwidth",
                    dottedOverlay: "none",
                    delay: 9000,
                    navigation: {
                        keyboardNavigation: "on",
                        keyboard_direction: "horizontal",
                        mouseScrollNavigation: "off",
                        mouseScrollReverse: "default",
                        onHoverStop: "on",
                        touch: {
                            touchenabled: "on",
                            swipe_threshold: 75,
                            swipe_min_touches: 1,
                            swipe_direction: "horizontal",
                            drag_block_vertical: false
                        },
                        arrows: {
                            style: "uranus",
                            enable: true,
                            hide_onmobile: false,
                            hide_onleave: false,
                            tmp: '',
                            left: {
                                h_align: "left",
                                v_align: "center",
                                h_offset: 10,
                                v_offset: 0
                            },
                            right: {
                                h_align: "right",
                                v_align: "center",
                                h_offset: 10,
                                v_offset: 0
                            }
                        }
                    },
                    viewPort: {
                        enable: true,
                        outof: "pause",
                        visible_area: "80%",
                        presize: false
                    },
                    responsiveLevels: [1240, 1024, 778, 480],
                    visibilityLevels: [1240, 1024, 778, 480],
                    gridwidth: [1240, 1024, 778, 480],
                    gridheight: [768, 600, 600, 600],
                    lazyType: "none",
                    parallax: {
                        type: "scroll",
                        origo: "enterpoint",
                        speed: 400,
                        levels: [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 46, 47, 48, 49, 50, 55]
                    },
                    shadow: 0,
                    spinner: "off",
                    stopLoop: "off",
                    stopAfterLoops: -1,
                    stopAtSlide: -1,
                    shuffle: "off",
                    autoHeight: "off",
                    hideThumbsOnMobile: "off",
                    hideSliderAtLimit: 0,
                    hideCaptionAtLimit: 0,
                    hideAllCaptionAtLilmit: 0,
                    debugMode: false,
                    fallbacks: {
                        simplifyAll: "off",
                        nextSlideOnWindowFocus: "off",
                        disableFocusListener: false
                    }
                });
            }
        });
    </script>
</body>
</html>