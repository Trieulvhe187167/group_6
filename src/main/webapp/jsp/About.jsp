<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">

<head>
    <!-- META ============================================= -->
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="keywords" content="Luxury Hotel, About Us" />
    <meta name="author" content="Luxury Hotel" />
    <meta name="robots" content="index, follow" />

    <!-- DESCRIPTION -->
    <meta name="description" content="Learn more about Luxury Hotel – our mission, vision and values." />

    <!-- OG -->
    <meta property="og:title" content="About Us – Luxury Hotel" />
    <meta property="og:description" content="Discover Luxury Hotel: excellence in hospitality." />
    <meta property="og:image" content="../assets/images/banner/banner2.jpg" />
    <meta name="format-detection" content="telephone=no" />

    <!-- FAVICONS ICON ============================================= -->
    <link rel="icon" href="../assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" href="../assets/images/favicon.png" type="image/x-icon" />

    <!-- PAGE TITLE HERE ============================================= -->
    <title>About Us – Luxury Hotel</title>

    <!-- MOBILE SPECIFIC ============================================= -->
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <!-- PLUGINS CSS ============================================= -->
    <link rel="stylesheet" href="../assets/css/assets.css" />
    <link rel="stylesheet" href="../assets/css/typography.css" />
    <link rel="stylesheet" href="../assets/css/shortcodes/shortcodes.css" />
    <link rel="stylesheet" href="../assets/css/style.css" />
    <link rel="stylesheet" href="../assets/css/color/color-1.css" />
</head>

<body id="bg">
    <div class="page-wraper">
        <!-- Include chung header.jsp -->
       <%@ include file="/jsp/header.jsp" %>


        <!-- Inner Content Box ==== -->
        <div class="page-content">
            <!-- Page Heading Box ==== -->
            <div class="page-banner ovbl-dark"
                style="background-image:url('../assets/images/banner/banner2.jpg');">
                <div class="container">
                    <div class="page-banner-entry">
                        <h1 class="text-white">About Us</h1>
                    </div>
                </div>
            </div>
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="../">Home</a></li>
                        <li>About Us</li>
                    </ul>
                </div>
            </div>
            <!-- Page Content Box ==== -->
            <div class="content-block">
                <!-- About Us ==== -->
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
                <!-- About Us END ==== -->

                <!-- Our Story ==== -->
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
                                    <img src="../assets/images/about/pic1.jpg" alt="" />
                                    <a href="https://www.youtube.com/watch?v=x_sJzVe9P_8"
                                        class="popup-youtube video"><i class="fa fa-play"></i></a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Our Story END ==== -->

                <!-- Contact Info ==== -->
                <div class="section-area section-sp1">
                    <div class="container">
                        <h3 class="title-head">Contact Us</h3>
                        <p><i class="fa fa-envelope"></i> info@luxuryhotel.com</p>
                        <p><i class="fa fa-phone"></i> +84 24 1234 5678</p>
                        <p><i class="fa fa-map-marker"></i> 123 Luxury St., Downtown, Hanoi, Vietnam</p>
                    </div>
                </div>
                <!-- Contact Info END ==== -->
            </div>
            <!-- Page Content Box END ==== -->
        </div>
        <!-- Inner Content Box END ==== -->

        <!-- Include chung footer.jsp -->
        <%@ include file="/jsp/footer.jsp" %>
    </div>
    <!-- page-wraper END ==== -->

    <!-- External JavaScripts -->
    <script src="../assets/js/jquery.min.js"></script>
    <script src="../assets/vendors/bootstrap/js/popper.min.js"></script>
    <script src="../assets/vendors/bootstrap/js/bootstrap.min.js"></script>
    <script src="../assets/vendors/owl-carousel/owl.carousel.js"></script>
    <script src="../assets/js/functions.js"></script>
    <script src="../assets/vendors/switcher/switcher.js"></script>
</body>

</html>
