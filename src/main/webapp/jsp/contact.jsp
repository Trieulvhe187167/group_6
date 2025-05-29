<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="keywords" content="" />
    <meta name="author" content="" />
    <meta name="robots" content="" />

    <meta name="description" content="Luxury Hotel" />
    <meta property="og:title" content="Luxury Hotel" />
    <meta property="og:description" content="Luxury Hotel" />
    <meta property="og:image" content="" />
    <meta name="format-detection" content="telephone=no">

    <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" type="image/x-icon" />

    <title>Contact Us – Luxury Hotel</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link class="skin" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
</head>
<body id="bg">
    <div class="page-wraper">

        <%-- Shared Header --%>
        <jsp:include page="/jsp/header.jsp" flush="true" />

        <!-- Page Content -->
        <div class="page-content bg-white">

            <!-- Banner & Breadcrumb -->
            <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                <div class="container">
                    <div class="page-banner-entry">
                        <h1 class="text-white">Contact Us</h1>
                    </div>
                </div>
            </div>
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li>Contact Us</li>
                    </ul>
                </div>
            </div>

            <!-- Contact Section: Map Only & Combined Layout -->
<div class="section-sp2 contact-page">
    <div class="container-fluid">
        <!-- Map Row: centered -->
        <div class="row justify-content-center mb-5">
            <div class="col-lg-10 p-lr0">
                <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d4214.3175813667085!2d105.52271427566788!3d21.01242168833868!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3135abc60e7d3f19%3A0x2be9d7d0b5abcbf4!2zVHLGsOG7nW5nIMSQ4bqhaSBo4buNYyBGUFQgSMOgIE7hu5lp!5e1!3m2!1svi!2s!4v1748368574780!5m2!1svi!2s" 
                        class="align-self-stretch d-flex mx-auto" style="width:100%; min-height:350px; border:0;" allowfullscreen>
                </iframe>
            </div>
        </div>
        <!-- Combined Row: Info + Form styled -->
<div class="row justify-content-center">
    <div class="col-lg-10">
        <div class="row m-lr0 align-items-stretch">
            <!-- Contact Information -->
            <div class="col-lg-5 col-md-6 mb-4 d-flex">
                <div class="contact-info-bx bg-primary text-white p-5 w-100 h-100">
                    <h3 class="text-white mb-3">Contact <span>Information</span></h3>
                    <p>Luxury Hotel Located in a prime location in the heart of a bustling urban area, Luxury Hotel offers guests a top-class resort experience. With an architectural design that harmonizes classic and modern features, every detail from the spacious lobby to the cozy hallway is meticulously cared for, expressing a noble and sophisticated style.</p>
                    <div class="widget_getintuch border-top border-bottom py-3 mb-3">
                        <ul class="list-unstyled mb-0">
                            <li class="mb-2"><i class="ti-location-pin mr-2"></i> 123 Luxury St., Downtown, Hanoi</li>
                            <li class="mb-2"><i class="ti-mobile mr-2"></i>(+84) 3 1234 5678</li>     
  <li><a class="text-white" href="https://mail.google.com/mail/?view=cm&fs=1&to=luxuryhotel999@gmail.com&su=Feedback%20from%20Website&body=Hello%20Luxury%20Hotel," target="_blank" rel="noopener">
    <i class="fab fa-google text-white mr-2"></i>
    luxuryhotel999@gmail.com
</a></li>                     </ul>
                        
                    </div>
                    <h5 class="mb-3">Follow Us</h5>
                    <ul class="contact-social-bx list-inline mb-0">
                        <li class="list-inline-item mr-2"><a href="#" class="btn outline radius-xl"><i class="fa fa-facebook"></i></a></li>
                        <li class="list-inline-item mr-2"><a href="#" class="btn outline radius-xl"><i class="fa fa-twitter"></i></a></li>
                        <li class="list-inline-item mr-2"><a href="#" class="btn outline radius-xl"><i class="fa fa-linkedin"></i></a></li>
                        <li class="list-inline-item"><a href="#" class="btn outline radius-xl"><i class="fa fa-google-plus"></i></a></li>
                    </ul>
                </div>
            </div>
            <!-- Contact Form -->
           <div class="col-lg-7 col-md-6 mb-4 d-flex">
                <div class="contact-bx bg-white p-5 w-100 h-100 d-flex flex-column">
                    <div class="heading-bx left mb-4">
                        <h1 class="title-head display-4">Get <span>In</span> Touch</h1>
                    </div>
                    <form action="${pageContext.request.contextPath}/assets/script/contact.php" method="post" class="flex-grow-1">
                        <div class="form-row">
                            <div class="form-group col-md-6">
                                <label for="name">Your Name</label>
                                <input id="name" name="name" type="text" class="form-control mb-4" placeholder="Enter your name" required>
                            </div>
                            <div class="form-group col-md-6">
                                <label for="email">Your Email Address</label>
                                <input id="email" name="email" type="email" class="form-control mb-4" placeholder="Enter your email" required>
                            </div>
                            <div class="form-group col-md-6">
                                <label for="phone">Your Phone</label>
                                <input id="phone" name="phone" type="text" class="form-control mb-4" placeholder="Enter your phone" required>
                            </div>
<!--                            <div class="form-group col-md-6">
                                <label for="subject">Type Room</label>
                                <input id="subject" name="subject" type="text" class="form-control mb-4" placeholder="Type room you want booking" required>
                            </div>-->
                            <div class="form-group col-12">
                                <label for="message">Type Message</label>
                                <textarea id="message" name="message" rows="5" class="form-control mb-4" placeholder="Enter your message" required></textarea>
                            </div>
                        </div>
                        <div class="form-group text-center mt-4">
                            <button type="submit" class="btn btn-primary px-4">Send Message</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<!-- End Contact Section -->

        </div>
        <!-- End Page Content -->

  

    </div>
      <%-- Shared Footer --%>
        <jsp:include page="/jsp/footer.jsp" flush="true" />
    <!-- External JS -->
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
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>
</body>
</html>
