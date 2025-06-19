<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>About Us – Luxury Hotel</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!-- Favicon -->
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon">

        <!-- PLUGINS CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
        <!-- 1. jQuery chỉ import 1 lần ở đây -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script>
            // 2. Khi window.load xong thì fadeOut spinner
            $(window).on('load', function () {
                $('#loading-icon-bx').fadeOut();
            });
        </script>

        <!-- Spinner CSS -->
        <style>

            #loading-icon-bx {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: #fff url('${pageContext.request.contextPath}/assets/images/loading.gif') no-repeat center;
                z-index: 9999;
            }
        </style>
    </head>
    <body id="bg">
        <!-- Spinner -->
        <div id="loading-icon-bx"></div>

        <div class="page-wraper">
            <!-- Include phần header (chỉ chứa nav/menu) -->
            <jsp:include page="header.jsp" />
            <!-- Nội dung chính -->
            <div class="page-content">
                <!-- Banner -->
                <div class="page-banner ovbl-dark"
                     style="background-image:url('${pageContext.request.contextPath}/assets/images/banner/banner2.jpg');">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">About - Luxury Hotel</h1>
                        </div>
                    </div>
                </div>

                <!-- Breadcrumb -->
                <!-- Breadcrumb row -->
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="/index.jsp">Home</a></li>
                            <li>About</li>
                        </ul>
                    </div>
                </div>
                <!-- Content Block -->
                <div class="content-block">
                    <!-- Features -->
                    <div class="section-area section-sp1">
                        <div class="container">
                            <div class="row">
                                <!-- Rooms & Amenities -->
                                <div class="col-lg-3 col-md-6 col-sm-6 m-b30">
                                    <div class="feature-container text-center">
                                        <div class="feature-md text-primary m-b20">
                                            <i class="fa fa-bed fa-2x"></i>
                                        </div>
                                        <div class="icon-content">
                                            <h5 class="ttr-tilte">Rooms &amp; Amenities</h5>
                                            <ul class="feature-list text-left" style="display: inline-block; margin: 0; padding: 0; list-style: disc;">
                                                <li>Over 200 premium rooms &amp; suites with imported furnishings</li>
                                                <li>Central A/C, 55″ flat-screen TV, minibar &amp; electronic safe</li>
                                                <li>Complimentary high-speed Wi-Fi throughout the property</li>
                                                <li>24/7 room service, à la carte breakfast &amp; prompt laundry</li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>

                                <!-- Culinary Excellence -->
                                <div class="col-lg-3 col-md-6 col-sm-6 m-b30">
                                    <div class="feature-container text-center">
                                        <div class="feature-md text-primary m-b20">
                                            <i class="fa fa-utensils fa-2x"></i>
                                        </div>
                                        <div class="icon-content">
                                            <h5 class="ttr-tilte">Culinary Excellence</h5>
                                            <p>Signature Restaurant offering Asian–European fusion, fresh seafood, Wagyu beef &amp; inventive vegetarian dishes. Rooftop Sky Bar with exclusive cocktails &amp; lounge music.</p>
                                        </div>
                                    </div>
                                </div>

                                <!-- Spa & Leisure -->
                                <div class="col-lg-3 col-md-6 col-sm-6 m-b30">
                                    <div class="feature-container text-center">
                                        <div class="feature-md text-primary m-b20">
                                            <i class="fa fa-spa fa-2x"></i>
                                        </div>
                                        <div class="icon-content">
                                            <h5 class="ttr-tilte">Spa &amp; Leisure</h5>
                                            <p>Spa Serenity with steam baths, hot-stone massages &amp; facial treatments. Fitness center, yoga studio &amp; infinity pool (6 AM–10 PM daily).</p>
                                        </div>
                                    </div>
                                </div>

                                <!-- Meetings & Events -->
                                <div class="col-lg-3 col-md-6 col-sm-6 m-b30">
                                    <div class="feature-container text-center">
                                        <div class="feature-md text-primary m-b20">
                                            <i class="fa fa-calendar-alt fa-2x"></i>
                                        </div>
                                        <div class="icon-content">
                                            <h5 class="ttr-tilte">Meetings &amp; Events</h5>
                                            <p>Three modern rooms for 20–300 guests, full AV, lighting &amp; sound. Ideal for weddings, gala dinners &amp; corporate seminars with flawless execution.</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Our Story -->
                    <div class="section-area bg-gray section-sp1 our-story">
                        <div class="container">
                            <div class="row align-items-center d-flex">
                                <div class="col-lg-5 col-md-12 heading-bx">
                                    <h2 class="m-b10">Our Story</h2>
                                    <h5 class="fw4">Where luxury meets heartfelt hospitality</h5>
                                    <p>Since opening in 2025, Luxury Hotel has set the standard for refined elegance in the city centre. Born from a vision to create an urban oasis, today we welcome discerning travelers from around the globe.</p>
                                    <a href="contact.jsp" class="btn">Read More</a>
                                </div>
                                <div class="col-lg-7 col-md-12 heading-bx p-lr">
                                    <div class="video-bx">
                                        <img src="${pageContext.request.contextPath}/assets/images/slider/slide1.jpg" alt="Our Story" />
                                        <a href="https://www.youtube.com/watch?v=cQfMOJ1yoGU" class="popup-youtube video">
                                            <i class="fa fa-play"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Contact Info -->
                    <div class="section-area section-sp1">
                        <div class="container">
                            <h3 class="title-head">Contact Us</h3>
                            <a href="https://mail.google.com/mail/?view=cm&fs=1&to=luxuryhotel999@gmail.com&su=Feedback%20from%20Website&body=Hello%20Luxury%20Hotel," target="_blank" rel="noopener">
                                <i class="fab fa-google"></i>
                                luxuryhotel999@gmail.com
                            </a>
                            <p><i class="fa fa-phone"></i> (+84) 3 1234 5678</p>
                            <p><i class="fa fa-map-marker"></i> 123 Luxury St., Downtown, Hanoi, Vietnam</p>
                        </div>
                    </div>
                </div>
                <!-- .content-block END -->
            </div>
            <!-- .page-content END -->

            <!-- Include footer -->
            <%@ include file="footer.jsp" %>
        </div>
        <!-- .page-wraper END -->

        <!-- EXTERNAL SCRIPTS (không include lại jQuery) -->
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
      
    </body>
</html>
