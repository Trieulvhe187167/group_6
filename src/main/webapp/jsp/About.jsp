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
            <%@ include file="/jsp/header.jsp" %>

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
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                            <li>About Us</li>
                        </ul>
                    </div>
                </div>

                <!-- Content Block -->
                <div class="content-block">
                    <!-- Features -->
                    <div class="section-area section-sp1">
                        <div class="container">
                            <div class="row">
                                <div class="col-lg-3 col-md-6 col-sm-6 m-b30">
                                    <div class="feature-container text-center">
                                        <div class="feature-md text-primary m-b20">
                                            <i class="fa fa-gem fa-2x"></i>
                                        </div>
                                        <div class="icon-content">
                                            <h5 class="ttr-tilte">Our Philosophy</h5>
                                            <p>We blend timeless elegance with modern comfort for every guest.</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-3 col-md-6 col-sm-6 m-b30">
                                    <div class="feature-container text-center">
                                        <div class="feature-md text-primary m-b20">
                                            <i class="fa fa-bed fa-2x"></i>
                                        </div>
                                        <div class="icon-content">
                                            <h5 class="ttr-tilte">Luxurious Rooms</h5>
                                            <p>Sumptuous suites and rooms appointed with premium amenities.</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-3 col-md-6 col-sm-6 m-b30">
                                    <div class="feature-container text-center">
                                        <div class="feature-md text-primary m-b20">
                                            <i class="fa fa-cutlery fa-2x"></i>
                                        </div>
                                        <div class="icon-content">
                                            <h5 class="ttr-tilte">World-class Service</h5>
                                            <p>Personalized service from check-in to check-out, every time.</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-3 col-md-6 col-sm-6 m-b30">
                                    <div class="feature-container text-center">
                                        <div class="feature-md text-primary m-b20">
                                            <i class="fa fa-leaf fa-2x"></i>
                                        </div>
                                        <div class="icon-content">
                                            <h5 class="ttr-tilte">Sustainable Luxury</h5>
                                            <p>Committed to eco-friendly practices and community support.</p>
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
                                    <a href="#" class="btn">Read More</a>
                                </div>
                                <div class="col-lg-7 col-md-12 heading-bx p-lr">
                                    <div class="video-bx">
                                        <img src="${pageContext.request.contextPath}/assets/images/about/pic1.jpg" alt="Our Story" />
                                        <a href="https://www.youtube.com/watch?v=x_sJzVe9P_8" class="popup-youtube video">
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
                            <p><i class="fa fa-envelope"></i> info@luxuryhotel.com</p>
                            <p><i class="fa fa-phone"></i> +84 24 1234 5678</p>
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
        <script src='${pageContext.request.contextPath}/assets/vendors/switcher/switcher.js'></script>
    </body>
</html>
